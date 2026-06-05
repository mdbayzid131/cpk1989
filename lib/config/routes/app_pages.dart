import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/shared/splash/splash_view.dart';
import 'package:cpk1989/module/shared/splash/splash_binding.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String bottomNavBar = '/bottom-nav-bar';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String welcomePage = '/welcome-page';
  static const String whatYourSpeciality = '/what-your-speciality';
  static const String preferredNoteMethod = '/preferred-note-method';
  static const String interactiveTutorial = '/interactive-tutorial';
  static const String verifyEmail = '/verify-email';
  static const String otpVerification = '/otp-verification';
  static const String cardDetails = '/card-details';
  static const String myCards = '/my-cards';
  static const String subscription = '/subscription';
  static const String eventDetails = '/event-details';
}

final Transition transition = Transition.rightToLeft;

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('App is running!'),
      ),
    );
  }
}

final pages = [
  GetPage(
    name: AppRoutes.splash,
    page: () => const SplashView(),
    binding: SplashBinding(),
  ),
  GetPage(
    name: AppRoutes.onboarding,
    page: () => const PlaceholderScreen(),
  ),
  GetPage(
    name: AppRoutes.login,
    page: () => const PlaceholderScreen(),
  ),
  GetPage(
    name: AppRoutes.bottomNavBar,
    page: () => const PlaceholderScreen(),
  ),
];
