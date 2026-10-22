import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/utils/product_ownership.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Avoid network requests and platform services in ownership/navigation tests.
class TestProfileController extends ProfileController {
  @override
  // Skip the real initialization, which fetches the profile and starts services.
  // ignore: must_call_super
  void onInit() {}
  @override
  void onClose() {}
}

class TestBottomNavBarController extends BottomNavBarController {
  @override
  // Skip notification requests in the navigation test.
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  tearDown(() => Get.reset());

  test('unknown identity cannot secure a listing', () {
    expect(isOwnProduct('seller'), isFalse);
    expect(canSecureProduct('seller'), isFalse);
    Get.put<ProfileController>(TestProfileController());
    expect(isOwnProduct(''), isFalse);
    expect(canSecureProduct('seller'), isFalse);
  });

  test('only other sellers listings can be secured', () {
    final profile = Get.put<ProfileController>(TestProfileController());
    profile.rxUserId.value = 'viewer';
    expect(isOwnProduct('viewer'), isTrue);
    expect(canSecureProduct('viewer'), isFalse);
    expect(isOwnProduct('other'), isFalse);
    expect(canSecureProduct('other'), isTrue);
    expect(canSecureProduct(''), isFalse);
  });

  testWidgets('ownership updates when the profile finishes loading', (
    tester,
  ) async {
    final profile = Get.put<ProfileController>(TestProfileController());
    await tester.pumpWidget(
      MaterialApp(
        home: Obx(
          () => Text(
            canSecureProduct('seller') ? 'Secure This Item' : 'View More',
          ),
        ),
      ),
    );
    expect(find.text('Secure This Item'), findsNothing);
    profile.rxUserId.value = 'buyer';
    await tester.pump();
    expect(find.text('Secure This Item'), findsOneWidget);
    profile.rxUserId.value = 'seller';
    await tester.pump();
    expect(find.text('Secure This Item'), findsNothing);
  });

  testWidgets('own profile returns to the existing profile tab', (
    tester,
  ) async {
    final navigation = Get.put<BottomNavBarController>(
      TestBottomNavBarController(),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.bottomNavBar,
        getPages: [
          GetPage(
            name: AppRoutes.bottomNavBar,
            page: () => const Scaffold(body: Text('Main')),
          ),
          GetPage(
            name: AppRoutes.itemDetail,
            page: () => const Scaffold(body: Text('Details')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed(AppRoutes.itemDetail);
    await tester.pumpAndSettle();
    openOwnProfile();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.bottomNavBar);
    expect(navigation.selectedIndex, 3);
    expect(find.text('Details'), findsNothing);
  });
}
