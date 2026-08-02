import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class AuthRepo {
  final ApiClient apiClient;
  AuthRepo({required this.apiClient});

  /// ===================== LOGIN / SIGNUP (OTP REQUEST) =====================
  Future<Response> login({
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    final Map<String, dynamic> body = {"email": email};
    if (firstName != null && firstName.trim().isNotEmpty) {
      body["firstName"] = firstName.trim();
    }
    if (lastName != null && lastName.trim().isNotEmpty) {
      body["lastName"] = lastName.trim();
    }
    return await apiClient.postData(ApiConstants.login, body);
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
