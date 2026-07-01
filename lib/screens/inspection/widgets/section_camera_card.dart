import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

/// Module-level guard shared by every camera card in the app so that switching
/// between photo and video mode properly waits for the previous controller to
/// release the camera hardware before the next one initialises.
///
/// Without this, disposing one [CameraController] while another initialises on
/// the same hardware triggers "CameraController used after being disposed"
/// platform-channel crashes.
Future<void>? cameraCardPendingDisposal;

/// Fills the parent box with the live preview, scaled to **cover** (no portrait
/// letterbox bars) and clipped — instead of [CameraPreview]'s default contain
/// fit which leaves black bars when the preview aspect ≠ the box aspect.
Widget _coveredPreview(CameraController controller) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isLandscape =
          MediaQuery.orientationOf(context) == Orientation.landscape;
      // Mirror CameraPreview's own AspectRatio: portrait inverts the ratio.
      final previewAspect = isLandscape
          ? controller.value.aspectRatio
          : 1 / controller.value.aspectRatio;
      final boxAspect = constraints.maxWidth / constraints.maxHeight;
      var scale = boxAspect / previewAspect;
      if (scale < 1) scale = 1 / scale;
      return ClipRect(
        child: Transform.scale(
          scale: scale,
          child: Center(child: CameraPreview(controller)),
        ),
      );
    },
  );
}

/// A self-contained camera card with a live preview, flash/torch toggle, a
/// fullscreen view, and a capture → review → rotate → accept/retake overlay.
///
/// On accept the captured [XFile] is emitted through [onCapture]. Rotation is
/// surfaced in the review UI but is not baked into the file — the caller keeps
/// ownership of any pixel rotation it wants to apply.
class SectionCameraCard extends StatefulWidget {
  const SectionCameraCard({
    super.key,
    this.height,
    required this.onCapture,
    this.onPickFromGallery,
    this.instructionText,
    this.showControls = true,
    this.onCaptureReady,
    this.onFlashReady,
    this.onFlashModeChanged,
  });

  /// Card height. Falls back to a sensible default when null.
  final double? height;

  /// Called with the captured [XFile]. With [showControls] true this fires once
  /// the user accepts in the review overlay; with it false (embedded HUD mode)
  /// it fires straight after capture, with no review overlay.
  final void Function(XFile file) onCapture;

  /// Optional gallery picker. When null the gallery button is hidden.
  final VoidCallback? onPickFromGallery;

  /// Shown above the preview so users know what this photo is for.
  final String? instructionText;

  /// When false the card is a pure live viewfinder — no instruction overlay, no
  /// bottom shutter/gallery row, no border. Drive capture/torch from an external
  /// button via [onCaptureReady] / [onFlashReady]. Used by the inline inspection
  /// HUD so the camera is live the whole time.
  final bool showControls;

  /// Called once the camera initialises, with a callback that captures a photo.
  /// Only useful when [showControls] is false.
  final void Function(VoidCallback captureNow)? onCaptureReady;

  /// Called once the camera initialises, with a callback that toggles the torch.
  /// Only useful when [showControls] is false.
  final void Function(VoidCallback toggleFlash)? onFlashReady;

  /// Called whenever the torch turns on/off so an external button can reflect it.
  final void Function(bool isOn)? onFlashModeChanged;

  @override
  State<SectionCameraCard> createState() => _SectionCameraCardState();
}

class _SectionCameraCardState extends State<SectionCameraCard>
    with WidgetsBindingObserver {
  // Bridges to the library-level [cameraCardPendingDisposal] so mode switches
  // across different camera cards don't conflict on hardware.
  static Future<void>? get _pendingDisposal => cameraCardPendingDisposal;
  static set _pendingDisposal(Future<void>? v) => cameraCardPendingDisposal = v;

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isInitializing = false;
  // When dispose() is called while _isInitializing, we can't safely call
  // controller.dispose() yet — doing so while initialize() is in-flight causes
  // "CameraController used after being disposed" unhandled exceptions from the
  // platform channel callback. Set this flag instead and let _tryStartCamera
  // do the actual disposal once initialize() resolves.
  bool _isDisposePending = false;
  // The current controller's in-flight initialize() future. A controller must
  // never be disposed until this settles (see _disposeWhenSettled).
  Future<void>? _initInFlight;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isCapturing = false;
  int _currentCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  // Incremented on every inactive/paused and widget-dispose to cancel
  // in-flight inits.
  int _initGeneration = 0;

  double get _cardHeight => widget.height ?? 220.h;

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
      // Do NOT clear _isInitializing here: _disposeController must still see it
      // set so it DEFERS disposal while initialize() is in flight — disposing a
      // controller mid-initialize crashes the platform channel. _tryStartCamera
      // performs the single safe disposal once init resolves.
      _initGeneration++;
      _disposeController();
      if (mounted) {
        setState(() => _isInitialized = false);
      }
    } else if (state == AppLifecycleState.resumed && mounted) {
      // The cancelled in-flight init won't reset its own flag (generation
      // mismatch), so clear it here or _initCamera's guard would block re-init.
      _isInitializing = false;
      _initCamera();
    }
  }

  void _disposeController() {
    if (_isInitializing) {
      // Defer: calling controller.dispose() while initialize() is in-flight
      // causes an unhandled platform-channel callback to fire on the disposed
      // controller. Mark the flag and let _tryStartCamera dispose it after init.
      _isDisposePending = true;
      return;
    }
    _isDisposePending = false;
    final controller = _controller;
    final init = _initInFlight;
    _controller = null;
    _initInFlight = null;
    if (controller != null) {
      // Store the async disposal future so the next card can await it.
      _pendingDisposal = _disposeWhenSettled(controller, init);
    }
  }

  /// Disposes [c], but only AFTER its in-flight [init] future settles. Disposing
  /// a CameraController while initialize() is still running makes the package set
  /// `value` on a disposed controller → "used after disposed". Errors (incl. a
  /// double-dispose race between two init generations) are swallowed.
  Future<void> _disposeWhenSettled(
      CameraController c, Future<void>? init) async {
    if (init != null) {
      try {
        await init;
      } catch (_) {}
    }
    try {
      await c.dispose();
    } catch (_) {}
  }

  Future<void> _initCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;
    final myGen = ++_initGeneration;

    try {
      // Yield one tick so Flutter finishes reconciliation before we touch
      // hardware (the old card's dispose() sets _pendingDisposal).
      await Future<void>.delayed(Duration.zero);
      if (!mounted || _initGeneration != myGen) return;

      // Wait for the previous card's camera controller to fully release.
      final disposal = _pendingDisposal;
      if (disposal != null) {
        _pendingDisposal = null;
        await disposal.timeout(const Duration(seconds: 2), onTimeout: () {});
      }
      if (!mounted || _initGeneration != myGen) return;

      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = '';
          _isInitialized = false;
        });
      }

      final hasPermission = await _ensureCameraPermission();

      // On iOS the permission dialog causes a brief inactive→resumed cycle
      // which disposes our controller. Re-wait for that disposal first.
      if (!mounted || _initGeneration != myGen) return;
      final postPermDisposal = _pendingDisposal;
      if (postPermDisposal != null) {
        _pendingDisposal = null;
        await postPermDisposal.timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
      }
      if (!mounted || _initGeneration != myGen) return;

      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isInitialized = false;
            _errorMessage =
                'Camera permission is required to capture inspection photos';
          });
        }
        return;
      }

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

      final backCameraIndex = _cameras!.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _currentCameraIndex = backCameraIndex >= 0 ? backCameraIndex : 0;

      for (var attempt = 0; attempt < 3; attempt++) {
        if (!mounted || _initGeneration != myGen) return;

        if (attempt > 0) {
          final prev = _pendingDisposal;
          _pendingDisposal = null;
          if (prev != null) {
            await prev.timeout(const Duration(seconds: 1), onTimeout: () {});
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
    } catch (_) {
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

  /// Attempts to open [camera]. Disposes any existing [_controller] first,
  /// waits for that disposal, then initialises a fresh controller.
  /// Returns `true` on success, `false` on failure.
  Future<bool> _tryStartCamera(CameraDescription camera) async {
    // Release the current (possibly-failed) controller and wait.
    final old = _controller;
    final oldInit = _initInFlight;
    _controller = null;
    _initInFlight = null;
    if (old != null) {
      // Dispose the previous controller only after ITS initialize() settles —
      // a paused→resumed cycle can land here while the old controller is still
      // initializing, and disposing mid-init crashes the camera package.
      final f = _disposeWhenSettled(old, oldInit);
      _pendingDisposal = f;
      await f.timeout(const Duration(seconds: 2), onTimeout: () {});
      _pendingDisposal = null;
    }

    if (!mounted) return false;

    final controller = CameraController(
      camera,
      // veryHigh (1080p), not max: inspection photos get downscaled to 1920px
      // on save anyway, so capturing at sensor-max (e.g. 48MP) only adds 1-2s of
      // takePicture encode for pixels we throw away.
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;

    try {
      final initFuture = controller.initialize();
      _initInFlight = initFuture;
      await initFuture;
      _initInFlight = null;
      // If a dispose() arrived while we were awaiting init, honour it now that
      // the platform callback has completed (so no "used after disposed" crash).
      if (_isDisposePending || !mounted || _controller != controller) {
        _isDisposePending = false;
        _pendingDisposal = _disposeWhenSettled(controller, null);
        _controller = null;
        return false;
      }
      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
      widget.onCaptureReady?.call(_captureImage);
      widget.onFlashReady?.call(_toggleFlash);
      return true;
    } on CameraException {
      _initInFlight = null;
      _isDisposePending = false;
      _pendingDisposal = _disposeWhenSettled(controller, null);
      _controller = null;
      return false;
    } catch (_) {
      _initInFlight = null;
      _isDisposePending = false;
      _pendingDisposal = _disposeWhenSettled(controller, null);
      _controller = null;
      return false;
    }
  }

  Future<bool> _ensureCameraPermission() async {
    if (!(Platform.isIOS || Platform.isAndroid)) return true;

    var status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      return false;
    }

    status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _captureImage() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final file = await _controller!.takePicture();
      if (!mounted) return;
      // Embedded HUD mode skips the in-card review overlay — the inspection HUD
      // shows the captured photo with its own Retake action.
      if (widget.showControls) {
        await _openReviewOverlay(file);
      } else {
        widget.onCapture(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  /// Shows the in-app review overlay (rotate + accept/retake). On accept the
  /// captured [XFile] is emitted through [widget.onCapture].
  Future<void> _openReviewOverlay(XFile file) async {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _PhotoReviewView(file: file),
        fullscreenDialog: true,
      ),
    );
    if (accepted == true) {
      widget.onCapture(file);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final next = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller!.setFlashMode(next);
      if (mounted) {
        setState(() => _flashMode = next);
        widget.onFlashModeChanged?.call(next != FlashMode.off);
      }
    } catch (_) {
      // Ignore — some devices/lenses don't support a torch.
    }
  }

  void _openFullscreenPreview() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenCameraView(
          controller: _controller!,
          onCaptured: (file) async {
            Navigator.of(context).pop();
            if (mounted) await _openReviewOverlay(file);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _initGeneration++; // Invalidate any in-flight _initCamera call.
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(12.r);

    if (_hasError) {
      return Container(
        height: _cardHeight,
        decoration: BoxDecoration(color: Colors.black, borderRadius: radius),
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
                    color: colorScheme.error.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.no_photography_outlined,
                    color: colorScheme.error,
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
                        // On iOS, after the first denial the system will not
                        // re-prompt — the user must grant access via Settings.
                        await openAppSettings();
                        return;
                      }
                      final status = await Permission.camera.status;
                      if (status.isPermanentlyDenied || status.isRestricted) {
                        await openAppSettings();
                        return;
                      }
                      _initCamera();
                    },
                    icon: Icon(Icons.camera_alt_outlined, size: 18.sp),
                    label: const Text('Allow Camera Access'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
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

    if (!_isInitialized || _controller == null) {
      return Container(
        height: _cardHeight,
        decoration: BoxDecoration(color: Colors.black, borderRadius: radius),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 2,
                ),
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

    return Container(
      height: _cardHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: radius,
        border: widget.showControls
            ? Border.all(color: colorScheme.primary.withAlpha(100), width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _coveredPreview(_controller!),
            if (widget.showControls) ...[
              _buildInstructionBar(),
              _buildControlBar(),
            ],
            if (_isCapturing)
              ColoredBox(
                color: Colors.white.withAlpha(100),
                child: Center(
                  child: SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withAlpha(200), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.photo_camera_outlined,
              color: Colors.white.withAlpha(230),
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                widget.instructionText ??
                    'Center the subject in the frame, then tap Take photo',
                style: TextStyle(
                  color: Colors.white.withAlpha(242),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withAlpha(200), Colors.transparent],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 6.h, right: 6.w),
                  child: widget.onPickFromGallery != null
                      ? Tooltip(
                          message: 'Pick photo from gallery',
                          child: Semantics(
                            button: true,
                            label: 'Pick from gallery',
                            child: _CameraActionButton(
                              icon: Icons.photo_library_outlined,
                              onTap: widget.onPickFromGallery,
                              size: 44.w,
                            ),
                          ),
                        )
                      : SizedBox(width: 44.w, height: 44.w),
                ),
              ),
            ),
            Tooltip(
              message: 'Take photo',
              child: Semantics(
                button: true,
                label: 'Take photo',
                child: _CameraActionButton(
                  icon: Icons.camera_alt,
                  onTap: _isCapturing ? null : _captureImage,
                  size: 56.w,
                  isPrimary: true,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 6.h, left: 6.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: _flashMode == FlashMode.off
                            ? 'Turn torch on'
                            : 'Turn torch off',
                        child: Semantics(
                          button: true,
                          label: 'Toggle flash',
                          child: _CameraActionButton(
                            icon: _flashMode == FlashMode.off
                                ? Icons.flash_off
                                : Icons.flash_on,
                            onTap: _toggleFlash,
                            size: 44.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Tooltip(
                        message: 'Open a larger view (same camera)',
                        child: Semantics(
                          button: true,
                          label: 'Larger preview',
                          child: _CameraActionButton(
                            icon: Icons.open_in_full,
                            onTap: _openFullscreenPreview,
                            size: 44.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraActionButton extends StatelessWidget {
  const _CameraActionButton({
    required this.icon,
    this.onTap,
    this.size = 32,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white.withAlpha(230)
              : Colors.black.withAlpha(120),
          shape: BoxShape.circle,
          border: isPrimary ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.black87 : Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

/// Fullscreen viewfinder for a larger framing view. Captures the photo and
/// hands it back through [onCaptured]; the caller drives the review overlay.
class _FullscreenCameraView extends StatefulWidget {
  const _FullscreenCameraView({
    required this.controller,
    required this.onCaptured,
  });

  final CameraController controller;
  final void Function(XFile file) onCaptured;

  @override
  State<_FullscreenCameraView> createState() => _FullscreenCameraViewState();
}

class _FullscreenCameraViewState extends State<_FullscreenCameraView> {
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _capture() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final file = await widget.controller.takePicture();
      widget.onCaptured(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _coveredPreview(widget.controller),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Tap the white button below to take the photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 36.h,
            left: 0,
            right: 0,
            child: Center(
              child: Tooltip(
                message: 'Take photo',
                child: Semantics(
                  button: true,
                  label: 'Take photo',
                  child: GestureDetector(
                    onTap: _isCapturing ? null : _capture,
                    child: Container(
                      width: 76.w,
                      height: 76.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: _isCapturing ? Colors.grey : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: _isCapturing
                            ? Center(
                                child: SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// In-app review overlay shown after a capture. Lets the user rotate the
/// preview and accept or retake. Returns `true` from the route on accept.
///
/// Rotation here is preview-only: the original [XFile] is returned unchanged so
/// the caller can decide how to persist any rotation.
class _PhotoReviewView extends StatefulWidget {
  const _PhotoReviewView({required this.file});

  final XFile file;

  @override
  State<_PhotoReviewView> createState() => _PhotoReviewViewState();
}

class _PhotoReviewViewState extends State<_PhotoReviewView> {
  int _quarterTurns = 0;

  void _rotate() {
    setState(() => _quarterTurns = (_quarterTurns + 1) % 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () => Navigator.of(context).pop(false),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Review photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: _quarterTurns,
                    child: Image.file(
                      File(widget.file.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
              child: Row(
                children: [
                  _ReviewButton(
                    icon: Icons.refresh,
                    label: 'Retake',
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                  SizedBox(width: 12.w),
                  _ReviewButton(
                    icon: Icons.rotate_right,
                    label: 'Rotate',
                    onTap: _rotate,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ReviewButton(
                      icon: Icons.check,
                      label: 'Use photo',
                      isPrimary: true,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewButton extends StatelessWidget {
  const _ReviewButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = isPrimary ? colorScheme.primary : Colors.white.withAlpha(30);
    final fg = isPrimary ? colorScheme.onPrimary : Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
