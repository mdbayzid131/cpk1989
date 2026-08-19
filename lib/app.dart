import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flutter/services.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/bindings/initial_binding.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F1012),
            primaryColor: const Color(0xFFE2B744),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE2B744),
              secondary: Color(0xFFE2B744),
              surface: Color(0xFF1E2022),
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Color(0xFFE2B744),
              circularTrackColor: Color(0x22E2B744),
              refreshBackgroundColor: Color(0xFF1E2022),
            ),
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Brightness.light, // Android icons (white)
                statusBarBrightness: Brightness.dark, // iOS icons (white)
              ),
            ),
          ),
          initialRoute: AppRoutes.splash,
          getPages: pages,
          initialBinding: InitialBinding(),
        );
      },
    );
  }
}
