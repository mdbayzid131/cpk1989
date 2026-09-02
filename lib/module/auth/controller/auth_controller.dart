import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/services/auth_service.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final rxIsLoading = false.obs;
  final rxIsSignUp = true.obs;
  final formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // OTP Fields & State
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final rxOtpSecondsRemaining = 45.obs;
  final rxIsOtpLoading = false.obs;
  Timer? _otpTimer;

  void startOtpTimer() {
    _otpTimer?.cancel();
    rxOtpSecondsRemaining.value = 45;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (rxOtpSecondsRemaining.value > 0) {
        rxOtpSecondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void stopOtpTimer() {
    _otpTimer?.cancel();
  }

  void clearOtpFields() {
    for (var c in otpControllers) {
      c.clear();
    }
  }

  String get formattedOtpTimer {
    final secondsRemaining = rxOtpSecondsRemaining.value;
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<bool> verifyOtp() async {
    final email = emailController.text.trim();
    final otpCode = otpControllers.map((c) => c.text).join();

    if (otpCode.length < 6) {
      Helpers.showError("Please enter all 6 digits of the verification code.");
      return false;
    }

    rxIsOtpLoading.value = true;
    try {
      final response = await authService.verifyOtp(email: email, otp: otpCode);
      rxIsOtpLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMsg = response.statusMessage ?? "Verification failed";
        Helpers.showError(errorMsg);
        return false;
      }
    } catch (e) {
      rxIsOtpLoading.value = false;
      Helpers.showError("An error occurred during verification: $e");
      return false;
    }
  }

  Future<bool> resendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Helpers.showError("Email address is missing");
      return false;
    }

    try {
      final response = await authService.resendOtp(email);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMsg = response.statusMessage ?? "Failed to resend OTP";
        Helpers.showError(errorMsg);
        return false;
      }
    } catch (e) {
      Helpers.showError("Failed to resend OTP: $e");
      return false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    _otpTimer?.cancel();
    super.onClose();
  }

  Future<bool> prepareAuth() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return false;
    }

    rxIsLoading.value = true;

    final email = emailController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    try {
      final response = await authService.login(
        email: email,
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
      );
      rxIsLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMsg = response.statusMessage ?? "Failed to request OTP";
        Helpers.showError(errorMsg);
        return false;
      }
    } catch (e) {
      rxIsLoading.value = false;
      Helpers.showError("An error occurred: $e");
      return false;
    }
  }

  Future<void> handleVerificationSuccess() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();

    if (firstName.isEmpty) {
      firstName = await StorageService.getString('first_name');
      if (firstName.isEmpty) firstName = "User";
    }
    if (lastName.isEmpty) {
      lastName = await StorageService.getString('last_name');
    }
    if (email.isEmpty) {
      email = await StorageService.getString('email');
    }

    // Persist user details in storage
    await _saveLocalUserData(firstName, lastName, email);

    Get.offAllNamed(AppRoutes.bottomNavBar);
  }

  Future<void> _saveLocalUserData(
    String firstName,
    String lastName,
    String email,
  ) async {
    await StorageService.setBool(StorageConstants.isLoggedIn, true);
    await StorageService.setString('first_name', firstName);
    await StorageService.setString('last_name', lastName);
    await StorageService.setString('email', email);

    // Set in the AuthService reactive state
    Get.find<AuthService>().isLoggedIn.value = true;
  }
}
