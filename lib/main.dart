import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cpk1989/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Global dark status bar settings
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android icons (white)
      statusBarBrightness: Brightness.dark, // iOS icons (white)
    ),
  );

  runApp(const MyApp());
}
