import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class EnvConfig {
  static double _platformFeePercentage = 12.0;
  static String _apiBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://smart-shopping-mall.onrender.com/api/v1',
  );
  static String _stripePublishableKey = const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51SqdqHDpab3KPsw4BQiAn9rUzt1abdcURDqGwvnss6DsYH7B4DmMKdKsMjoqjRFTfu6kYOlpTRQ4xkO3fGNev1wC00K3XpnV97',
  );

  /// Commission / Platform Fee Percentage (e.g. 12.0)
  static double get platformFeePercentage => _platformFeePercentage;

  /// Commission Rate as multiplier (e.g. 0.12)
  static double get feeRate => _platformFeePercentage / 100.0;

  /// Seller payout multiplier (e.g. 0.88)
  static double get sellerRate => (100.0 - _platformFeePercentage) / 100.0;

  /// Formatted fee label (e.g. "Closeté fee (12%)")
  static String get feeLabel {
    final formattedPercent = _platformFeePercentage % 1 == 0
        ? _platformFeePercentage.toInt().toString()
        : _platformFeePercentage.toString();
    return 'Closeté fee ($formattedPercent%)';
  }

  static String get apiBaseUrl => _apiBaseUrl;
  static String get stripePublishableKey => _stripePublishableKey;

  /// Initialize and load .env file from root
  static Future<void> init() async {
    try {
      final envString = await rootBundle.loadString('.env');
      final lines = envString.split('\n');
      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final eqIdx = line.indexOf('=');
        if (eqIdx != -1) {
          final key = line.substring(0, eqIdx).trim();
          final value = line.substring(eqIdx + 1).trim();
          if (key == 'PLATFORM_FEE_PERCENTAGE') {
            final parsed = double.tryParse(value);
            if (parsed != null) _platformFeePercentage = parsed;
          } else if (key == 'API_BASE_URL' && value.isNotEmpty) {
            _apiBaseUrl = value;
          } else if (key == 'STRIPE_PUBLISHABLE_KEY' && value.isNotEmpty) {
            _stripePublishableKey = value;
          }
        }
      }
      if (kDebugMode) {
        print('✅ EnvConfig initialized: fee = $_platformFeePercentage%');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ EnvConfig initialized with defaults ($e)');
      }
    }
  }
}
