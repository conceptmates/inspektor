import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

// Reuses the library-level [cameraCardPendingDisposal] defined in the photo
// card so switching between photo and video mode waits for the previous
// controller to release the camera hardware before the next one initialises.
// Do NOT declare a second guard here.
import 'section_camera_card.dart' show cameraCardPendingDisposal;

/// A self-contained live video-capture card: shows a live preview, records with
/// an elapsed timer, lets the user review the recording, then calls
/// [onCaptured] with the recorded video file when accepted.
class SectionVideoCameraCard extends StatefulWidget {
  const SectionVideoCameraCard({
    super.key,
    this.height,
    required this.onCaptured,
    this.instructionText,
  });

  final double? height;
  final void Function(XFile file) onCaptured;
  final String? instructionText;

  @override
  State<SectionVideoCameraCard> createState() => _SectionVideoCameraCardState();
}

class _SectionVideoCameraCardState extends State<SectionVideoCameraCard>
    with WidgetsBindingObserver {
  // Uses the library-level [cameraCardPendingDisposal] shared with
  // SectionCameraCard so mode switches don't conflict on hardware.
  static Future<void>? get _pendingDisposal => cameraCardPendingDisposal;
  static set _pendingDisposal(Future<void>? v) => cameraCardPendingDisposal = v;

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isDisposePending = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentCameraIndex = 0;

  bool _isRecording = false;
  bool _isToggling = false;
  bool _flashOn = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  // Incremented on every inactive/paused and widget-dispose to cancel in-flight inits.
  int _initGeneration = 0;

  // The captured recording awaiting accept/retake review.
  XFile? _capturedFile;

  double get _height => widget.height ?? 220.h;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Cancel any in-flight init (e.g. waiting for iOS permission dialog).
      _initGeneration++;
      _isInitializing = false;
      _stopRecordingIfActive();
      _disposeController();
      if (mounted) setState(() => _isInitialized = false);
    } else if (state == AppLifecycleState.resumed && mounted) {
      // Don't re-init the live camera while the user is reviewing a recording.
      if (_capturedFile == null) _initCamera();
    }
  }

  void _disposeController() {
    if (_isInitializing) {
      _isDisposePending = true;
      return;
    }
    _isDisposePending = false;
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      _pendingDisposal = controller.dispose();
    }
  }

  Future<void> _initCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;
    final myGen = ++_initGeneration;

    try {
      // Yield one tick so Flutter finishes reconciliation before touching hardware.
      await Future<void>.delayed(Duration.zero);
      if (!mounted || _initGeneration != myGen) return;

      // Wait for the previous card's camera controller to fully release.
      final disposal = _pendingDisposal;
      if (disposal != null) {
        _pendingDisposal = null;
        await disposal.timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
      }
      if (!mounted || _initGeneration != myGen) return;

      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = '';
          _isInitialized = false;
        });
      }

      final hasCamPerm = await _ensurePermission(
        Permission.camera,
        'Camera permission is required to record inspection videos',
      );
      // On iOS the permission dialog causes a brief inactive→resumed cycle.
      // Re-wait for any disposal that occurred during the dialog.
      if (!mounted || _initGeneration != myGen) return;
      final postCamDisposal = _pendingDisposal;
      if (postCamDisposal != null) {
        _pendingDisposal = null;
        await postCamDisposal.timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
      }
      if (!mounted || _initGeneration != myGen) return;
      if (!hasCamPerm) return;

      final hasMicPerm = await _ensurePermission(
        Permission.microphone,
        'Microphone permission is required to record inspection videos',
      );
      if (!mounted || _initGeneration != myGen) return;
      final postMicDisposal = _pendingDisposal;
      if (postMicDisposal != null) {
        _pendingDisposal = null;
        await postMicDisposal.timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
      }
      if (!mounted || _initGeneration != myGen) return;
      if (!hasMicPerm) return;

      _cameras = await availableCameras();
      if (!mounted || _initGeneration != myGen) return;
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'No cameras available';
          });
        }
        return;
      }

      final backIdx = _cameras!
          .indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      _currentCameraIndex = backIdx >= 0 ? backIdx : 0;

      for (int attempt = 0; attempt < 3; attempt++) {
        if (!mounted || _initGeneration != myGen) return;

        if (attempt > 0) {
          final prev = _pendingDisposal;
          _pendingDisposal = null;
          if (prev != null) {
            await prev.timeout(
              const Duration(seconds: 1),
              onTimeout: () {},
            );
          } else {
            await Future<void>.delayed(const Duration(milliseconds: 600));
          }
          if (!mounted || _initGeneration != myGen) return;
        }

        final ok = await _tryStartCamera(_cameras![_currentCameraIndex]);
        if (ok) return;
      }

      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Camera unavailable. Tap to retry.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to initialize camera';
        });
      }
    } finally {
      if (_initGeneration == myGen) _isInitializing = false;
    }
  }

  Future<bool> _tryStartCamera(CameraDescription camera) async {
    final old = _controller;
    _controller = null;
    if (old != null) {
      final f = old.dispose();
      _pendingDisposal = f;
      await f.timeout(const Duration(seconds: 1), onTimeout: () {});
      _pendingDisposal = null;
    }

    if (!mounted) return false;

    final controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: true,
    );
    _controller = controller;

    try {
      await controller.initialize();
      if (_isDisposePending || !mounted || _controller != controller) {
        _isDisposePending = false;
        _pendingDisposal = controller.dispose();
        _controller = null;
        return false;
      }
      setState(() {
        _isInitialized = true;
        _hasError = false;
        _flashOn = false;
      });
      return true;
    } on CameraException {
      _isDisposePending = false;
      _pendingDisposal = _controller?.dispose();
      _controller = null;
      return false;
    } catch (_) {
      _isDisposePending = false;
      _pendingDisposal = _controller?.dispose();
      _controller = null;
      return false;
    }
  }

  Future<bool> _ensurePermission(Permission perm, String errorMsg) async {
    if (!(Platform.isIOS || Platform.isAndroid)) return true;
    var status = await perm.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied || status.isRestricted) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = errorMsg;
        });
      }
      return false;
    }
    status = await perm.request();
    if (!status.isGranted && mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = errorMsg;
      });
    }
    return status.isGranted;
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final next = _flashOn ? FlashMode.off : FlashMode.torch;
    try {
      await _controller!.setFlashMode(next);
      if (mounted) setState(() => _flashOn = !_flashOn);
    } catch (_) {}
  }

  Future<void> _toggleRecording() async {
    if (_isToggling ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }
    _isToggling = true;
    try {
      if (_isRecording) {
        await _stopRecording();
      } else {
        await _startRecording();
      }
    } finally {
      _isToggling = false;
    }
  }

  Future<void> _startRecording() async {
    // Guard against the camera already recording at the native level.
    if (_controller!.value.isRecordingVideo) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording already started')),
        );
      }
      return;
    }
    try {
      await _controller!.startVideoRecording();
      _elapsed = Duration.zero;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
      if (mounted) setState(() => _isRecording = true);
    } on CameraException catch (e) {
      if (mounted) {
        final msg = e.description?.toLowerCase() ?? '';
        final friendly = msg.contains('already')
            ? 'Recording already started'
            : 'Failed to start recording';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendly)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _timer = null;

    // Guard against the native layer not actually recording.
    if (!(_controller?.value.isRecordingVideo ?? false)) {
      if (mounted) setState(() => _isRecording = false);
      return;
    }

    try {
      final file = await _controller!.stopVideoRecording();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _capturedFile = file;
        });
      }
      // Release the live camera while the user reviews the recording.
      _disposeController();
      if (mounted) setState(() => _isInitialized = false);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        final msg = e.description?.toLowerCase() ?? '';
        final friendly =
            msg.contains('assertwriter') || msg.contains('assetwriter')
                ? 'Recording was too short. Please try again.'
                : 'Failed to save recording';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendly)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecordingIfActive() async {
    if (_isRecording || (_controller?.value.isRecordingVideo ?? false)) {
      _timer?.cancel();
      _timer = null;
      try {
        await _controller?.stopVideoRecording();
      } catch (_) {}
      if (mounted) setState(() => _isRecording = false);
    }
  }

  void _acceptRecording() {
    final file = _capturedFile;
    if (file == null) return;
    widget.onCaptured(file);
  }

  void _retakeRecording() {
    setState(() {
      _capturedFile = null;
      _elapsed = Duration.zero;
    });
    _initCamera();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _initGeneration++;
    _timer?.cancel();
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);

    if (_capturedFile != null) {
      return _buildReview(radius);
    }

    if (_hasError) {
      return _buildError(radius);
    }

    if (!_isInitialized || _controller == null) {
      return _buildLoading(radius);
    }

    return _buildPreview(radius);
  }

  Widget _buildError(BorderRadius radius) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: radius,
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam_off_outlined,
                  color: Colors.redAccent,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.sp,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (Platform.isIOS) {
                      await openAppSettings();
                      return;
                    }
                    final camStatus = await Permission.camera.status;
                    final micStatus = await Permission.microphone.status;
                    if (camStatus.isPermanentlyDenied ||
                        micStatus.isPermanentlyDenied) {
                      await openAppSettings();
                      return;
                    }
                    _initCamera();
                  },
                  icon: Icon(Icons.videocam_outlined, size: 18.sp),
                  label: const Text('Allow Camera & Microphone'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BorderRadius radius) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: radius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white70,
              strokeWidth: 2,
            ),
            SizedBox(height: 12.h),
            Text(
              'Starting camera...',
              style: TextStyle(color: Colors.white54, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(BorderRadius radius) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: radius,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.4),
          width: 1.5.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // A neutral backdrop for the captured recording. We avoid spinning
            // up a video player here to keep the camera hardware free; the
            // recorded duration is shown as confirmation.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 44.sp,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Recording captured · ${_formatDuration(_elapsed)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ReviewButton(
                        icon: Icons.replay,
                        label: 'Retake',
                        onTap: _retakeRecording,
                        background: Colors.black.withValues(alpha: 0.47),
                        foreground: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _ReviewButton(
                        icon: Icons.check,
                        label: 'Use video',
                        onTap: _acceptRecording,
                        background: colors.primary,
                        foreground: colors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BorderRadius radius) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: radius,
        border: Border.all(
          color: _isRecording
              ? Colors.red.withValues(alpha: 0.78)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          width: _isRecording ? 2.w : 1.5.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(child: CameraPreview(_controller!)),
            // Top bar: recording timer or instruction.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    if (_isRecording) ...[
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _formatDuration(_elapsed),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.videocam_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.instructionText ??
                              'Tap the button below to start recording',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Bottom bar: flash + record/stop.
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: SizedBox()),
                    Tooltip(
                      message: _flashOn ? 'Turn flash off' : 'Turn flash on',
                      child: _VideoActionButton(
                        icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                        onTap: _isRecording ? null : _toggleFlash,
                        size: 40.w,
                        isActive: _flashOn,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Tooltip(
                      message:
                          _isRecording ? 'Stop recording' : 'Start recording',
                      child: _VideoActionButton(
                        icon: _isRecording
                            ? Icons.stop
                            : Icons.fiber_manual_record,
                        onTap: _toggleRecording,
                        size: 56.w,
                        isPrimary: true,
                        isRecording: _isRecording,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoActionButton extends StatelessWidget {
  const _VideoActionButton({
    required this.icon,
    this.onTap,
    this.size = 32,
    this.isPrimary = false,
    this.isRecording = false,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool isPrimary;
  final bool isRecording;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    if (isPrimary) {
      bgColor = isRecording ? Colors.red : Colors.white.withValues(alpha: 0.9);
      iconColor = isRecording ? Colors.white : Colors.black87;
    } else if (isActive) {
      bgColor = const Color(0xFFFFC107);
      iconColor = Colors.black87;
    } else {
      bgColor = Colors.black.withValues(alpha: 0.47);
      iconColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border:
              isPrimary ? Border.all(color: Colors.white, width: 2.w) : null,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}

class _ReviewButton extends StatelessWidget {
  const _ReviewButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
