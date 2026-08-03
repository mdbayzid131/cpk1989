class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://10.10.26.198:5000/api/v1';
  // static const String baseUrl = 'https://nayem5001.binarybards.online/api/v1';
  // static const String apiVersion = '';

  //Auth
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/login-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/user/profile';
  static const String products = '/products';
}
