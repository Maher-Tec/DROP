// This is a basic Flutter widget test for DROP app.

import 'package:flutter_test/flutter_test.dart';

import 'package:drop/app/drop_app.dart';

void main() {
  testWidgets('DROP app loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DropApp());

    // Verify that DROP title is present
    expect(find.text('DROP'), findsOneWidget);
    
    // Verify that tagline is present
    expect(find.text('Let it go'), findsOneWidget);
  });
}
