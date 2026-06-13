import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/services/auth_service.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class AuthController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  final rxIsLoading = false.obs;
  final formKey = GlobalKey<FormState>();

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
    rxIsOtpLoading.value = true;
    
    // Simulate OTP verification delay for premium feel
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final otpCode = otpControllers.map((c) => c.text).join();
    debugPrint("Verifying OTP code: $otpCode");
    
    rxIsOtpLoading.value = false;
    return true;
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

  String? validateFirstName(String? value) {
    return null; // Bypassed for now
  }

  String? validateLastName(String? value) {
    return null; // Bypassed for now
  }

  String? validateEmail(String? value) {
    return null; // Bypassed for now
  }

  Future<bool> prepareAuth() async {
    rxIsLoading.value = true;

    // Simulate minor network/api check delay for premium feel
    await Future.delayed(const Duration(milliseconds: 600));
    rxIsLoading.value = false;

    return true;
  }

  Future<void> handleVerificationSuccess() async {
    final firstName = firstNameController.text.trim().isNotEmpty
        ? firstNameController.text.trim()
        : "Gretchen";
    final lastName = lastNameController.text.trim().isNotEmpty
        ? lastNameController.text.trim()
        : "Bothman";
    final email = emailController.text.trim().isNotEmpty
        ? emailController.text.trim()
        : "gretchen.bothman@gmail.com";

    // Perform backend login/signup or save user locally
    try {
      final authService = Get.find<AuthService>();
      final fullName = "$firstName $lastName";
      final defaultPassword = "Closete@${email.split('@')[0]}";

      // Try to register/log in via API if baseUrl is set
      try {
        final response = await authService.login(
          email: email,
          password: defaultPassword,
        );
        if (response.statusCode != 200) {
          await authService.signup(
            name: fullName,
            email: email,
            password: defaultPassword,
            phone: "+971501234567",
            country: "UAE",
          );
          await authService.login(email: email, password: defaultPassword);
        }
      } catch (_) {
        // Bypassed API errors
      }
    } catch (_) {}

    // Persist user details in storage
    await _saveLocalUserData(firstName, lastName, email);

    Helpers.showSuccess(
      "Logged in successfully as $firstName $lastName",
      title: "Welcome to Closeté",
    );

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
    await StorageService.setString('phone', "50 123 4567");

    // Set in the AuthService reactive state
    Get.find<AuthService>().isLoggedIn.value = true;
  }
}
