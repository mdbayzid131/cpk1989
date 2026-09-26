import 'package:cpk1989/config/env_config.dart';

class ApiConstants {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  //Auth
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/login-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/user/profile';
  static const String profilePhoto = '/user/profile/photo';
  static const String profileStats = '/user/profile/stats';
  static const String products = '/products';
  static const String myProducts = '/products/my-products';
  static const String wishlist = '/wishlist';
  static const String notifications = '/notifications';
  static const String orders = '/orders';
  static const String paymentMethods = '/payment-methods';
  static const String setupIntent = '/payment-methods/setup-intent';
  static const String connectStatus = '/payment/connect/status';
  static const String connectOnboarding = '/payment/connect/onboarding';

  static String get stripePublishableKey => EnvConfig.stripePublishableKey;
  // static const String stripePublishableKey =
  //     'pk_test_51U5jOdDjRWLHvFckcLsPQfuOI06rVpsf41eJcId1bbuy71KBEHWadS7bXPmpAvGkWQ5rWsCNWicfhRYhsBBBSu4100PGFYAGMa';
  // static const String stripePublishableKey =
  //     'pk_test_51RqgJSGlimJ2gcj4JgiuajuGcFOXAjGwbzSH9FhLZRbBgbhAwJ4NRLGJhNhoj7m7Zi4u0K82q1CST9b1llKm4iHw00KA351vJ3';
  // static const String stripePublishableKey =
  //     'pk_test_51RqgJZGXJvAsdd7omGPG7Z1sPRl3dJb9QY9oCfrl8tSn1StxRIAig3I5xK9hKk1gCVKwSQka5lUi683927AaIoPu00TYnG8Xx6';
}
