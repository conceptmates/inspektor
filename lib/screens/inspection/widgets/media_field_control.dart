import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../controllers/media_capture_controller.dart';
import '../../../data/inspection_submission_builder.dart';
import '../../../models/inspection_template_model.dart';
import '../../../models/local_inspection.dart';
import 'section_camera_card.dart';
import 'section_video_camera_card.dart';

const _maxMultiImages = 11;

/// Capture control for media fields (image / multi-image / video / audio / file).
class MediaFieldControl extends ConsumerWidget {
  const MediaFieldControl({
    super.key,
    required this.field,
    required this.sectionName,
    required this.draft,
  });

  final InspectionField field;
  final String sectionName;
  final LocalInspection draft;

  bool get _isMulti =>
      field.hasMultipleImages ||
      (field.fieldType == 'text' && field.hasImage);
  bool get _isVideo => field.fieldType == 'video' || field.hasVideo;
  bool get _isAudio => field.fieldType == 'audio';
  bool get _isFile => field.fieldType == 'file' || field.hasFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = fieldKey(field);
    final busy = ref.watch(mediaCaptureControllerProvider
        .select((m) => m[key] ?? false));
    final capture = ref.read(mediaCaptureControllerProvider.notifier);

    if (busy) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isMulti) return _multi(context, ref, key, capture);
    if (_isVideo) return _video(context, key, capture);
    if (_isAudio) return _audio(context, key, capture);
    if (_isFile) return _file(context, key, capture);
    return _single(context, key, capture);
  }

  Widget _single(BuildContext context, String key, MediaCaptureController c) {
    final path = draft.itemImages[key];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (path != null) _thumb(path, height: 180.w),
        SizedBox(height: 12.w),
        OutlinedButton.icon(
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(path == null ? 'Capture photo' : 'Retake'),
          onPressed: () async {
            final file = await _openCamera(context, field.title);
            if (file != null) {
              await c.captureImage(
                  key: key, section: sectionName, savedOrRawPath: file.path);
            }
          },
        ),
      ],
    );
  }

  Widget _multi(
      BuildContext context, WidgetRef ref, String key, MediaCaptureController c) {
    final images = draft.itemMultiImages[key] ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: [
              for (final p in images) _thumb(p, height: 80.w, width: 80.w),
            ],
          ),
        SizedBox(height: 12.w),
        Text('${images.length}/$_maxMultiImages',
            style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: 8.w),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Add photo'),
          onPressed: images.length >= _maxMultiImages
              ? null
              : () async {
                  final file = await _openCamera(context, field.title);
                  if (file != null) {
                    await c.addImageToMulti(
                        key: key, section: sectionName, rawPath: file.path);
                  }
                },
        ),
      ],
    );
  }

  Widget _video(BuildContext context, String key, MediaCaptureController c) {
    final captured = draft.itemVideos[key] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (captured) _statusRow(context, Icons.videocam, 'Video captured'),
        SizedBox(height: 12.w),
        OutlinedButton.icon(
          icon: const Icon(Icons.videocam_outlined),
          label: Text(captured ? 'Re-record video' : 'Record video'),
          onPressed: () async {
            final file = await _openVideo(context, field.title);
            if (file != null) {
              await c.captureVideo(
                  key: key, section: sectionName, rawPath: file.path);
            }
          },
        ),
      ],
    );
  }

  Widget _audio(BuildContext context, String key, MediaCaptureController c) {
    final captured = draft.itemAudios[key] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (captured) _statusRow(context, Icons.audiotrack, 'Audio captured'),
        SizedBox(height: 12.w),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.mic_none),
                label: const Text('Record'),
                onPressed: () async {
                  final path = await showModalBottomSheet<String>(
                    context: context,
                    isDismissible: false,
                    builder: (_) => const _AudioRecorderSheet(),
                  );
                  if (path != null) {
                    await c.captureAudio(
                        key: key, section: sectionName, rawPath: path);
                  }
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: const Text('Browse'),
                onPressed: () async {
                  final res = await FilePicker.platform
                      .pickFiles(type: FileType.audio);
                  final p = res?.files.single.path;
                  if (p != null) {
                    await c.captureAudio(
                        key: key, section: sectionName, rawPath: p);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _file(BuildContext context, String key, MediaCaptureController c) {
    final captured = draft.itemFiles[key] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (captured)
          _statusRow(context, Icons.insert_drive_file, 'File attached'),
        SizedBox(height: 12.w),
        OutlinedButton.icon(
          icon: const Icon(Icons.attach_file),
          label: Text(captured ? 'Replace file' : 'Choose file'),
          onPressed: () async {
            final res = await FilePicker.platform.pickFiles();
            final p = res?.files.single.path;
            if (p != null) {
              await c.captureFile(
                  key: key, section: sectionName, rawPath: p);
            }
          },
        ),
      ],
    );
  }

  Widget _thumb(String path, {double? height, double? width}) {
    final img = path.startsWith('http')
        ? Image.network(path, height: height, width: width, fit: BoxFit.cover)
        : Image.file(File(path), height: height, width: width, fit: BoxFit.cover);
    return ClipRRect(borderRadius: BorderRadius.circular(8.r), child: img);
  }

  Widget _statusRow(BuildContext context, IconData icon, String label) {
    final colors = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(icon, color: colors.primary, size: 20.sp),
      SizedBox(width: 8.w),
      Text(label, style: TextStyle(color: colors.primary)),
    ]);
  }

  Future<XFile?> _openCamera(BuildContext context, String? instruction) {
    return Navigator.of(context).push<XFile>(MaterialPageRoute(
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: SafeArea(
          child: SectionCameraCard(
            height: MediaQuery.sizeOf(ctx).height,
            instructionText: instruction,
            onCapture: (f) => Navigator.of(ctx).pop(f),
          ),
        ),
      ),
    ));
  }

  Future<XFile?> _openVideo(BuildContext context, String? instruction) {
    return Navigator.of(context).push<XFile>(MaterialPageRoute(
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: SafeArea(
          child: SectionVideoCameraCard(
            height: MediaQuery.sizeOf(ctx).height,
            instructionText: instruction,
            onCaptured: (f) => Navigator.of(ctx).pop(f),
          ),
        ),
      ),
    ));
  }
}

/// Minimal in-app audio recorder (record + stop + elapsed). Pops the saved path.
class _AudioRecorderSheet extends StatefulWidget {
  const _AudioRecorderSheet();

  @override
  State<_AudioRecorderSheet> createState() => _AudioRecorderSheetState();
}

class _AudioRecorderSheetState extends State<_AudioRecorderSheet> {
  final _recorder = AudioRecorder();
  bool _recording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _path;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    _path = '${dir.path}/${const Uuid().v4()}.m4a';
    await _recorder.start(const RecordConfig(), path: _path!);
    setState(() => _recording = true);
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) => setState(() => _elapsed += const Duration(seconds: 1)));
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (mounted) Navigator.of(context).pop(path ?? _path);
  }

  @override
  Widget build(BuildContext context) {
    final mm = _elapsed.inMinutes.toString().padLeft(2, '0');
    final ss = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$mm:$ss',
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: Icon(_recording ? Icons.stop : Icons.mic),
                label: Text(_recording ? 'Stop' : 'Record'),
                onPressed: _recording ? _stop : _start,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
