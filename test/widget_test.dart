// This is a basic Flutter widget test for DROP app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:drop/screens/home_screen.dart';
import 'package:drop/services/theme_service.dart';

void main() {
  testWidgets('DROP home offers the three private paths', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final themeService = ThemeService();
    await themeService.init();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeService,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('One thought at a time.'), findsOneWidget);
    expect(find.text('Write a thought'), findsOneWidget);
    expect(find.text('Without words'), findsOneWidget);
    expect(find.text('Breathe'), findsOneWidget);
    expect(find.byTooltip('Turn animation off'), findsOneWidget);
    expect(
      find.byTooltip('Turn music on').evaluate().length +
          find.byTooltip('Turn music off').evaluate().length,
      1,
    );
    await tester.pumpWidget(const SizedBox());
    themeService.dispose();
  });
}
