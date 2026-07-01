import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/services/media_storage_service.dart';

void main() {
  group('MediaStorageService.volumeRoot', () {
    test('strips /Android/data/<pkg>/files → volume root', () {
      expect(
        MediaStorageService.volumeRoot(
            '/storage/emulated/0/Android/data/com.example.inspektor/files'),
        '/storage/emulated/0',
      );
    });

    test('secondary user volume', () {
      expect(
        MediaStorageService.volumeRoot(
            '/storage/emulated/10/Android/data/x/files'),
        '/storage/emulated/10',
      );
    });

    test('no /Android/ segment → unchanged', () {
      expect(MediaStorageService.volumeRoot('/sdcard'), '/sdcard');
    });
  });
}
