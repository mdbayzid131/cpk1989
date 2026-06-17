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
import 'package:cpk1989/module/purchase_detail/view/purchase_detail_screen.dart';
import 'package:cpk1989/module/purchase_detail/binding/purchase_detail_binding.dart';
import 'package:cpk1989/module/my_item_detail/view/my_item_detail_screen.dart';
import 'package:cpk1989/module/my_item_detail/binding/my_item_detail_binding.dart';
import 'package:cpk1989/module/sell/view/ai_analysis_screen.dart';
import 'package:cpk1989/module/sell_item_detail/view/sell_item_detail_screen.dart';
import 'package:cpk1989/module/sell_item_detail/binding/sell_item_detail_binding.dart';
import 'package:cpk1989/module/secure_checkout/view/secure_checkout_screen.dart';
import 'package:cpk1989/module/secure_checkout/view/terms_and_conditions_screen.dart';
import 'package:cpk1989/module/secure_checkout/binding/secure_checkout_binding.dart';
import 'package:cpk1989/module/auth/view/login_screen.dart';
import 'package:cpk1989/module/auth/binding/auth_binding.dart';
import 'package:cpk1989/module/my_purchase_ditails/view/my_purchase_ditails.dart';
import 'package:cpk1989/module/my_purchase_ditails/binding/my_purchase_ditails_binding.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String bottomNavBar = '/bottom-nav-bar';
  static const String sell = '/sell';
  static const String itemDetail = '/item-detail';
  static const String purchaseDetail = '/purchase-detail';
  static const String myItemDetail = '/my-item-detail';
  static const String aiAnalysis = '/ai-analysis';
  static const String sellItemDetail = '/sell-item-detail';
  static const String secureCheckout = '/secure-checkout';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String myPurchaseDetails = '/my-purchase-details';
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
    name: AppRoutes.login,
    page: () => const LoginScreen(),
    binding: AuthBinding(),
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
    name: AppRoutes.aiAnalysis,
    page: () => const AIAnalysisScreen(),
    binding: SellBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.itemDetail,
    page: () => const ItemDetailScreen(),
    binding: ItemDetailBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.purchaseDetail,
    page: () => const PurchaseDetailScreen(),
    binding: PurchaseDetailBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.myItemDetail,
    page: () => const MyItemDetailScreen(),
    binding: MyItemDetailBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.sellItemDetail,
    page: () => const SellItemDetailScreen(),
    binding: SellItemDetailBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.secureCheckout,
    page: () => const SecureCheckoutScreen(),
    binding: SecureCheckoutBinding(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.termsAndConditions,
    page: () => const TermsAndConditionsScreen(),
    transition: transition,
  ),
  GetPage(
    name: AppRoutes.myPurchaseDetails,
    page: () => const MyPurchaseDitails(),
    binding: MyPurchaseDitailsBinding(),
    transition: transition,
  ),
];
