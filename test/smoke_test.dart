import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/themes/app_theme.dart';

void main() {
  test('light theme is Material 3 light', () {
    final theme = AppTheme.light;
    expect(theme.useMaterial3, true);
    expect(theme.brightness, Brightness.light);
  });
}
