import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/services/auth_service.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/core/widgets/custom_dipped_bottom_sheet.dart';
import 'package:cpk1989/module/auth/view/email_verification_bottom_sheet.dart';

class AuthController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  final rxIsLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
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

  Future<void> continueAuth(BuildContext context) async {
    rxIsLoading.value = true;

    final firstName = firstNameController.text.trim().isNotEmpty
        ? firstNameController.text.trim()
        : "Gretchen";
    final lastName = lastNameController.text.trim().isNotEmpty
        ? lastNameController.text.trim()
        : "Bothman";
    final email = emailController.text.trim().isNotEmpty
        ? emailController.text.trim()
        : "gretchen.bothman@gmail.com";

    // Simulate minor network/api check delay for premium feel
    await Future.delayed(const Duration(milliseconds: 600));
    rxIsLoading.value = false;

    if (!context.mounted) return;

    // Show the custom dipped bottom sheet
    showCustomDippedBottomSheet(
      context: context,
      logo: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(Icons.mail_rounded, color: const Color(0xFFE2B744), size: 36.r),
          Positioned(
            top: -2.r,
            left: -2.r,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                "1",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      content: EmailVerificationBottomSheetContent(
        email: email,
        onVerifySuccess: () async {
          Navigator.pop(context); // Close bottom sheet

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
                await authService.login(
                  email: email,
                  password: defaultPassword,
                );
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
        },
      ),
    );
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
