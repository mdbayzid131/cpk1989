import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class AuthRepo {
  final ApiClient apiClient;
  AuthRepo({required this.apiClient});


  /// ===================== SIGNUP =====================
  Future<Response> signup({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final Map<String, dynamic> body = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
    };

    return await apiClient.postData(ApiConstants.signup, body);
  }

  /// ===================== LOGIN =====================
  Future<Response> login({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final Map<String, dynamic> body = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
    };
    return await apiClient.postData(ApiConstants.login, body);
  }

  /// ===================== OTP VERIFY =====================
  Future<Response> otpVerify({
    required String email,
    required String otp,
  }) async {
    return await apiClient.postData(ApiConstants.verifyOtp, {
      "email": email,
      "otp": otp,
    });
  }

  /// ===================== RESEND OTP =====================
  Future<Response> resendOtp({required String email}) async {
    return await apiClient.postData(ApiConstants.resendOtp, {
      "email": email,
    });
  }
}
