import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/utils/payout_navigation.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class PayoutTestProfile extends ProfileController {
  @override
  // Avoid network/platform initialization in these navigation tests.
  // ignore: must_call_super
  void onInit() {}
  @override
  void onReady() {}
  @override
  void onClose() {}
  @override
  Future<void> checkStripeConnectStatus() async {}
}

class PayoutTestNavigation extends BottomNavBarController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

Widget profileDestination() {
  final profile = Get.find<ProfileController>();
  return Scaffold(
    body: Obx(() {
      final personal = profile.rxSelectedIndex.value == 2;
      profile.scrollToPayoutIfRequested();
      if (profile.rxIsLoadingProfile.value) return const Text('Loading');
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 1200),
            if (personal)
              SizedBox(
                key: profile.payoutSectionKey,
                height: 180,
                child: const Text('Payout Details'),
              ),
            const SizedBox(height: 400),
          ],
        ),
      );
    }),
  );
}

void registerControllers() {
  Get.put<ProfileController>(PayoutTestProfile());
  Get.put<BottomNavBarController>(PayoutTestNavigation());
}

void main() {
  tearDown(() => Get.reset());

  testWidgets(
    'payout tap returns to profile and scrolls after details finish loading',
    (tester) async {
      registerControllers();
      final profile = Get.find<ProfileController>();
      profile.rxIsLoadingProfile.value = true;
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: AppRoutes.bottomNavBar,
          getPages: [
            GetPage(name: AppRoutes.bottomNavBar, page: profileDestination),
            GetPage(name: '/notice', page: () => const Scaffold()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed('/notice');
      await tester.pumpAndSettle();
      openProfilePayoutDetails();
      await tester.pumpAndSettle();
      expect(profile.rxFocusPayoutRequested.value, isTrue);
      profile.rxIsLoadingProfile.value = false;
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.bottomNavBar);
      expect(Get.find<BottomNavBarController>().selectedIndex, 3);
      expect(profile.rxSelectedIndex.value, 2);
      expect(profile.rxFocusPayoutRequested.value, isFalse);
      expect(tester.getTopLeft(find.text('Payout Details')).dy, lessThan(300));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'payout tap also initializes the profile when navigation is absent',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/notice',
          getPages: [
            GetPage(name: '/notice', page: () => const Scaffold()),
            GetPage(
              name: AppRoutes.bottomNavBar,
              page: profileDestination,
              binding: BindingsBuilder(registerControllers),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      openProfilePayoutDetails();
      await tester.pumpAndSettle();
      expect(Get.find<BottomNavBarController>().selectedIndex, 3);
      expect(Get.find<ProfileController>().rxSelectedIndex.value, 2);
      expect(tester.getTopLeft(find.text('Payout Details')).dy, lessThan(300));
      expect(tester.takeException(), isNull);
    },
  );
}
