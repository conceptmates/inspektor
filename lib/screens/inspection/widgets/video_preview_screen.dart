import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fullscreen player for a captured (or already-uploaded) inspection video.
/// Accepts a local file path or an http(s) URL; chewie supplies play/scrub/
/// fullscreen controls.
class VideoPreviewScreen extends StatefulWidget {
  const VideoPreviewScreen({super.key, required this.path});

  final String path;

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = widget.path.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
          : VideoPlayerController.file(File(widget.path));
      _video = c;
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _chewie = ChewieController(
          videoPlayerController: c,
          autoPlay: true,
          looping: false,
          aspectRatio:
              c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
        );
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not play this video.');
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: _error != null
            ? Text(_error!, style: const TextStyle(color: Colors.white70))
            : _chewie != null
                ? Chewie(controller: _chewie!)
                : const CircularProgressIndicator(color: Colors.white70),
      ),
    );
  }
}
