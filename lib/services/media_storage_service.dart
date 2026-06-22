import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Persists captured media into app storage (so it survives until upload).
/// Images are compressed; other media are copied as-is.
class MediaStorageService {
  const MediaStorageService();

  static const _uuid = Uuid();

  Future<String> _dir(String sub) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$sub');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  Future<String> saveImage(String srcPath) async {
    final dir = await _dir('inspection_images');
    final target = '$dir/${_uuid.v4()}.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      srcPath,
      target,
      quality: 80,
    );
    if (result != null) return result.path;
    return (await File(srcPath).copy(target)).path;
  }

  Future<String> saveMedia(String srcPath, String sub) async {
    final dir = await _dir(sub);
    final ext = srcPath.contains('.') ? srcPath.split('.').last : 'bin';
    final target = '$dir/${_uuid.v4()}.$ext';
    return (await File(srcPath).copy(target)).path;
  }
}

final mediaStorageServiceProvider =
    Provider<MediaStorageService>((ref) => const MediaStorageService());
