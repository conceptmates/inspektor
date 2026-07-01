import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../utils/logger.dart';

/// Persists captured media + a JSON mirror into a **user-visible** local folder
/// so files show up in any file explorer:
///   `/storage/emulated/0/Inspektor/{inspection_images,..,json}` on Android.
/// Falls back to app-private documents storage when the public folder is
/// unavailable (iOS, or all-files permission denied) so capture never fails.
class MediaStorageService {
  MediaStorageService();

  static const _uuid = Uuid();
  static const appFolder = 'Inspektor';

  // Resolved once per session: avoids re-running the permission check +
  // getExternalStorageDirectory() platform calls on every single capture.
  Directory? _cachedBase;

  /// Volume root from path_provider's external-files path: strips the
  /// `/Android/data/<pkg>/files` suffix.
  /// `/storage/emulated/0/Android/data/x/files` → `/storage/emulated/0`.
  static String volumeRoot(String externalFilesPath) =>
      externalFilesPath.split('/Android/').first;

  /// Android 11+ → all-files access; older → legacy storage perm.
  Future<bool> _ensurePermission() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    if ((await Permission.manageExternalStorage.request()).isGranted) {
      return true;
    }
    return (await Permission.storage.request()).isGranted;
  }

  /// Resolve (and create) the `Inspektor` base dir. Public top-level on Android
  /// when permitted, else app-private documents dir.
  Future<Directory> _baseDir() async {
    final cached = _cachedBase;
    if (cached != null) return cached;
    if (Platform.isAndroid && await _ensurePermission()) {
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final dir = Directory('${volumeRoot(ext.path)}/$appFolder');
        try {
          if (!dir.existsSync()) dir.createSync(recursive: true);
          return _cachedBase = dir;
        } catch (_) {
          /* not writable → fall through to private storage */
        }
      }
    }
    final base = await getApplicationDocumentsDirectory();
    return _cachedBase =
        Directory('${base.path}/$appFolder')..createSync(recursive: true);
  }

  Future<String> _dir(String sub) async {
    final dir = Directory('${(await _baseDir()).path}/$sub');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  Future<String> saveImage(String srcPath) async {
    final dir = await _dir('inspection_images');
    final target = '$dir/${_uuid.v4()}.jpg';
    // Cap to 1920px (longest-side downscale) before re-encoding. Without this
    // it decodes + re-encodes the full max-res capture (~12-48MP), which is the
    // 2-3s "saving" lag; the cap also shrinks the upload payload. Matches the
    // old app's setting.
    final result = await FlutterImageCompress.compressAndGetFile(
      srcPath,
      target,
      quality: 80,
      minWidth: 1920,
      minHeight: 1920,
      keepExif: false,
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

  /// Mirror the inspection JSON next to its media (Hive stays source of truth).
  /// Best-effort: a failed mirror never breaks the Hive save.
  /// ponytail: writes on every draft mutation; add a debounce in the session
  /// controller if it lags with many keystrokes.
  Future<void> writeJson(String id, String json) async {
    try {
      await File('${await _dir('json')}/$id.json').writeAsString(json);
    } catch (e, st) {
      // Mirror is best-effort (Hive stays source of truth), but log so a
      // silently-failing mirror is visible instead of looking like it saved.
      AppLogger.error(
        'JSON mirror write failed for $id',
        error: e,
        stackTrace: st,
        name: 'MediaStorage',
      );
    }
  }

  Future<void> deleteJson(String id) async {
    try {
      final f = File('${await _dir('json')}/$id.json');
      if (f.existsSync()) await f.delete();
    } catch (_) {
      /* best-effort */
    }
  }
}

final mediaStorageServiceProvider = Provider<MediaStorageService>(
  (ref) => MediaStorageService(),
);
