import 'package:cpk1989/core/widgets/dirham_symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Widget priceExample(double fontSize, {double scale = 1, bool compact = false}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, child) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: compact ? 80 : 300,
              child: DirhamPrice(
                price: 'AED 1,234,567',
                style: TextStyle(fontSize: fontSize, color: Colors.black),
                fitScaleDown: compact,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final fontSize in [11.0, 13.0, 16.0, 24.0]) {
    testWidgets('symbol follows the $fontSize price font', (tester) async {
      await tester.pumpWidget(priceExample(fontSize));
      await tester.pumpAndSettle();
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, fontSize);
      expect(svg.height, fontSize);
      expect(find.text('1,234,567'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('large text scales the symbol and fits compact price badges', (
    tester,
  ) async {
    await tester.pumpWidget(priceExample(16, scale: 2, compact: true));
    await tester.pumpAndSettle();
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.height, 32);
    expect(tester.getSize(find.byType(FittedBox).first).width, lessThanOrEqualTo(80));
    expect(tester.takeException(), isNull);
  });
}
