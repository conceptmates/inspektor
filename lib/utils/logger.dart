import 'dart:convert';
import 'dart:developer' as developer;

/// Centralized logger. Uses dart:developer.log — never print/debugPrint.
/// HTTP logging goes through the Dio interceptor (see api_logging_interceptor.dart).
class AppLogger {
  const AppLogger._();

  static void log(String message, {String name = 'inspektor'}) =>
      developer.log(message, name: name);

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'inspektor',
  }) =>
      developer.log(
        message,
        name: name,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );

  /// Pretty-print JSON-able data (indented). Falls back to toString().
  static String prettyPrintJson(Object? data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}
