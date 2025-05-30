import 'package:RAKSHA/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches with custom name and logo', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const WomenSafetyApp());

    // Verify that the custom app name is displayed.
    expect(find.text('RAKSHA'), findsOneWidget);

    // Verify that the custom logo is displayed.
    expect(find.byWidgetPredicate((widget) =>
        widget is Image && widget.image == const AssetImage('assets/img.jpg')
    ), findsOneWidget);
  });

  // Add any additional tests as needed (e.g., for other UI components)
}
