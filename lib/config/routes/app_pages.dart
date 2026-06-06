import 'package:get/get.dart';
import 'package:cpk1989/module/splash/view/splash_view.dart';
import 'package:cpk1989/module/splash/binding/splash_binding.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_screen.dart';
import 'package:cpk1989/module/onboarding/binding/onboarding_binding.dart';
import 'package:cpk1989/module/bottom_nav_bar/view/bottom_nav_bar_screen.dart';
import 'package:cpk1989/module/bottom_nav_bar/binding/bottom_nav_bar_binding.dart';
import 'package:cpk1989/module/sell/view/sell_screen.dart';
import 'package:cpk1989/module/sell/binding/sell_binding.dart';
import 'package:cpk1989/module/item_detail/view/item_detail_screen.dart';
import 'package:cpk1989/module/item_detail/binding/item_detail_binding.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String bottomNavBar = '/bottom-nav-bar';
  static const String sell = '/sell';
  static const String itemDetail = '/item-detail';
}

final Transition transition = Transition.fade;

final pages = [
  GetPage(
    name: AppRoutes.splash,
    page: () => const SplashView(),
    binding: SplashBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.onboarding,
    page: () => const OnboardingScreen(),
    binding: OnboardingBinding(),
    transition: transition,
  ),

  GetPage(
    name: AppRoutes.bottomNavBar,
    page: () => const BottomNavBarScreen(),
    binding: BottomNavBarBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.sell,
    page: () => const SellScreen(),
    binding: SellBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.itemDetail,
    page: () => const ItemDetailScreen(),
    binding: ItemDetailBinding(),
    transition: transition,
  ),
];
