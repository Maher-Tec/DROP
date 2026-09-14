import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop/screens/write_screen.dart';
import 'package:drop/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('release button stays above the keyboard', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 915);
    tester.view.viewInsets = const FakeViewPadding(bottom: 390);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);

    SharedPreferences.setMockInitialValues({'sound_enabled': false});
    final themeService = ThemeService();
    await themeService.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeService,
        child: const MaterialApp(home: WriteScreen()),
      ),
    );
    await tester.enterText(find.byType(TextField), 'A private thought');
    await tester.pump();

    final buttonLabel = find.text('Let it go');
    expect(buttonLabel, findsOneWidget);
    expect(tester.getBottomRight(buttonLabel).dy, lessThanOrEqualTo(525));
    expect(
      find.text("Your words aren't saved or sent by DROP."),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
    themeService.dispose();
  });
}
