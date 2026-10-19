import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class AuthRepo {
  final ApiClient apiClient;
  AuthRepo({required this.apiClient});

  /// ===================== SIGN UP (REGISTRATION) =====================
  Future<Response> signUp({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    return await apiClient.postData(ApiConstants.signUp, {
      "email": email.trim(),
      "firstName": firstName.trim(),
      "lastName": lastName.trim(),
    });
  }

  /// ===================== LOGIN (OTP REQUEST) =====================
  Future<Response> login({
    required String email,
  }) async {
    return await apiClient.postData(ApiConstants.login, {
      "email": email.trim(),
    });
  }

  /// ===================== OTP VERIFY =====================
  Future<Response> otpVerify({
    required String email,
    required String otp,
  }) async {
    final code = int.tryParse(otp) ?? 0;
    return await apiClient.postData(ApiConstants.verifyOtp, {
      "email": email,
      "oneTimeCode": code,
    });
  }

  /// ===================== RESEND OTP =====================
  Future<Response> resendOtp({required String email}) async {
    return await apiClient.postData(ApiConstants.resendOtp, {"email": email});
  }
}
