import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/data/repositories/auth_repository.dart';

class AuthService extends GetxService {
  late AuthRepo _authRepo;

  // Reactive state
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Find the already-registered ApiClient from InitialBinding
    _authRepo = AuthRepo(apiClient: Get.find<ApiClient>());

    // Check initial login state
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await StorageService.getString(StorageConstants.bearerToken);
    isLoggedIn.value = token.isNotEmpty;
  }

  Future<AuthService> init() async {
    return this;
  }

  /// ===================== SIGNUP =====================
  Future<Response> signup({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final response = await _authRepo.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== LOGIN =====================
  Future<Response> login({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {


      final response = await _authRepo.login(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      await _handleAuthResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== LOGOUT =====================
  Future<void> logout() async {
    try {
      // final response = await _authRepo.logout(deviceToken);
      await _clearLocalAuth();
      // return response;
    } catch (e) {
      await _clearLocalAuth();
      rethrow;
    }
  }

  /// ===================== OTP VERIFY =====================
  Future<Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _authRepo.otpVerify(email: email, otp: otp);
      if (response.statusCode == 200) {
        await _handleAuthResponse(response);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== RESEND OTP =====================
  Future<Response> resendOtp(String email) async {
    try {
      return await _authRepo.resendOtp(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== HELPER METHODS =====================

  /// Handles successful auth response (Login/Signup)
  Future<void> _handleAuthResponse(Response response) async {
    // Adjust these keys based on your actual API response structure
    // Example: { "data": { "accessToken": "...", "refreshToken": "..." } }
    final data = response.data;
    if (data is! Map) return;

    // Check if data is nested
    final authData = data['data'] is Map ? data['data'] : data;

    final String? accessToken = authData['accessToken'] ?? authData['token'];
    final String? refreshToken = authData['refreshToken'];

    if (accessToken != null) {
      await StorageService.setString(StorageConstants.bearerToken, accessToken);
      isLoggedIn.value = true;
    }

    if (refreshToken != null) {
      await StorageService.setString(
        StorageConstants.refreshToken,
        refreshToken,
      );
    }

    final bool? isOnboardingCompleted = authData['isOnboardingCompleted'];
    if (isOnboardingCompleted != null) {
      await StorageService.setBool(
        StorageConstants.quickSetupCompleted,
        isOnboardingCompleted,
      );
    }
  }

  /// Manually save user ID (Useful when profile is fetched separately)
  Future<void> saveUserId(String id) async {
    Helpers.debug('IAP: Manually saving User ID: $id');
    await StorageService.setString(StorageConstants.userId, id);
  }

  /// Clears all local auth data
  Future<void> _clearLocalAuth() async {
    await StorageService.remove(StorageConstants.bearerToken);
    await StorageService.remove(StorageConstants.refreshToken);
    await StorageService.remove(StorageConstants.userData);
    await StorageService.remove(StorageConstants.isLoggedIn);
    await StorageService.remove('first_name');
    await StorageService.remove('last_name');
    await StorageService.remove('email');
    await StorageService.remove('phone');

    isLoggedIn.value = false;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value;
}
