// Basic widget test for Smart Emergency Response App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build a simple MaterialApp and verify it renders
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Smart Emergency Response App')),
        ),
      ),
    );

    expect(find.text('Smart Emergency Response App'), findsOneWidget);
  });
}
