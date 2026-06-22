import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/themes/app_theme.dart';

void main() {
  test('dark theme is Material 3 dark', () {
    final theme = AppTheme.darkTheme;
    expect(theme.useMaterial3, true);
    expect(theme.brightness, Brightness.dark);
  });
}
