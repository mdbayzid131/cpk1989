import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// ===================== APP LOGGER =====================
/// Centralized logging utility for API requests, responses, and errors.
/// Pretty-prints JSON formatted responses in debug mode.

class AppLogger {
  AppLogger._();

  static const String _divider =
      '════════════════════════════════════════════════════════';

  /// Log outgoing API request
  static void request(RequestOptions options) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ➡️➡️➡️➡️ REQUEST $_divider');
    debugPrint('│ ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${_sanitizeHeaders(options.headers)}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│ Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      debugPrint('│ Body:');
      _printFormattedJson(options.data);
    }
    debugPrint('└ ➡️➡️➡️➡️ REQUEST $_divider');
    debugPrint('');
  }

  /// Log incoming API response
  static void response(Response response) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ✅✅✅✅ RESPONSE $_divider');
    debugPrint(
      '│ [ ${response.requestOptions.method} ${response.statusCode} ] ${response.requestOptions.uri}',
    );
    debugPrint('│ Data:');
    _printFormattedJson(response.data);
    debugPrint('└ ✅✅✅✅ RESPONSE $_divider');
    debugPrint('');
  }

  /// Log API error
  static void error(DioException e) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ❌❌❌❌ ERROR $_divider');
    debugPrint('│ ${e.type.name}: ${e.message}');
    debugPrint('│ ${e.requestOptions.method} ${e.requestOptions.uri}');
    if (e.response != null) {
      debugPrint('│ Status: ${e.response?.statusCode}');
      debugPrint('│ Data:');
      _printFormattedJson(e.response?.data);
    }
    debugPrint('└ ❌❌❌❌ ERROR $_divider');
    debugPrint('');
  }

  // ──────────────────── PRIVATE HELPERS ────────────────────

  /// Format data into pretty-printed JSON string
  static String _prettyPrintJson(dynamic data) {
    if (data == null) return 'null';
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (_) {}
    return data.toString();
  }

  /// Print JSON line by line to avoid debugPrint truncation limits
  static void _printFormattedJson(dynamic data) {
    final prettyString = _prettyPrintJson(data);
    final lines = prettyString.split('\n');
    for (final line in lines) {
      debugPrint('│ $line');
    }
  }

  /// Remove Authorization header value for safe logging
  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '***';
    }
    return sanitized;
  }
}
