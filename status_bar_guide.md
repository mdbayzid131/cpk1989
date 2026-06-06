# Flutter Dark Theme Status Bar Guide

Apnar app-er sob screen-er background black/dark howar karone status bar-er icons (time, battery, wifi, etc.) invisible (kalo) hoye giyechilo. Ei guide-e dewa holo kivabe ta fix kora hoyeche jeno porobortite kaje lage.

---

## Somossa (Problem)
Default-vabe Flutter-er `ThemeData()`-er brightness thake `Brightness.light` (Light Mode)। 
* Light mode-e thakar karone Flutter mone kore app-er background holo light (sada), tai she status bar-er icons gulo kalo (dark) kore dey. 
* Kintu jehetu apnar scaffold background black, tai kalo background-e kalo status bar icons dekha jacchilo na.

---

## Somadhan (Solution)

Amra 2 ti layer-e ekti robust config set korechi:

### ১. Global Initial Status Bar Style (`main.dart`)
App launch howar shomoy system level-e status bar icons white korar jonno `SystemChrome` configuration use kora hoyeche:

**[lib/main.dart](file:///Users/mashiur/Bayzid/moeb_26/lib/main.dart) code change:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Status bar globally light/white color set kora hoyeche
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Android-er jonno white icons
    statusBarBrightness: Brightness.dark,      // iOS-er jonno white icons
  ));

  runApp(const MyApp());
}
```

### ২. Global Theme Config (`app.dart`)
Kono kono page-e `AppBar` thakle ba regular screen load hole jeno status bar automatically override hoye dark na hoye jay, shejonno Theme-e `brightness` settings and custom `appBarTheme` set kora hoyeche:

**[lib/app.dart](file:///Users/mashiur/Bayzid/moeb_26/lib/app.dart) code change:**
```dart
GetMaterialApp(
  theme: ThemeData(
    brightness: Brightness.dark, // 1. Full app theme-ke dark hika-re set kora holo
    scaffoldBackgroundColor: AppColors.black100,
    
    // 2. AppBar-er overlay style explicitly white text/icons set kora holo
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android icons (white)
        statusBarBrightness: Brightness.dark,      // iOS icons (white)
      ),
    ),
  ),
  ...
)
```

---

## Poroborti custom settings (Important Tip)
Jodi kono specific screen-e (e.g. Map Screen ba Light Screen) status bar icons darker korte chan, tobe shei specific screen-er `AppBar`-er `systemOverlayStyle` e custom styling set korte paren:

```dart
AppBar(
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark, // Android icon dark korbe
    statusBarBrightness: Brightness.light,    // iOS text/icon dark korbe
  ),
  ...
)
```
