import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_in/screens/landing/landing_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  testWidgets('Landing shows Stitch content and CTAs', (tester) async {
    await tester.pumpWidget(_wrap(const LandingScreen()));
    expect(find.text('SubIn'), findsOneWidget);
    expect(find.textContaining('Stop watching.'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
