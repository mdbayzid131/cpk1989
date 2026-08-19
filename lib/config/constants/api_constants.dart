class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://10.10.26.198:5001/api/v1';
  // static const String baseUrl = 'http://10.10.26.198:5000/api/v1';
  // static const String baseUrl = 'https://nayem5001.binarybards.online/api/v1';
  // static const String apiVersion = '';

  //Auth
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/login-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/user/profile';
  static const String products = '/products';
  static const String wishlist = '/wishlist';
  static const String orders = '/orders';
  static const String paymentMethods = '/payment-methods';
  static const String setupIntent = '/payment-methods/setup-intent';
  static const String connectStatus = '/payment/connect/status';
  static const String connectOnboarding = '/payment/connect/onboarding';
  static const String stripePublishableKey =
      'pk_test_51RqgJZGXJvAsdd7omGPG7Z1sPRl3dJb9QY9oCfrl8tSn1StxRIAig3I5xK9hKk1gCVKwSQka5lUi683927AaIoPu00TYnG8Xx6';
}
