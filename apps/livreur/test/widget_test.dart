import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livreur_le_transporteur/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We pass a simple Scaffold as the initialHome because MyApp requires it.
    await tester.pumpWidget(const MyApp(
      initialHome: Scaffold(
        body: Center(child: Text('App started')),
      ),
    ));

    // Verify that our app renders the initial home content.
    expect(find.text('App started'), findsOneWidget);
  });
}
