import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drop/widgets/lake_background.dart';
import 'package:drop/widgets/floating_particles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop/config/theme.dart';
import 'package:drop/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DropTheme.nightModeOverride = false;
  });
  tearDown(() => DropTheme.nightModeOverride = false);

  test(
    'appearance and reduced motion survive restarting the service',
    () async {
      final settings = ThemeService();
      await settings.init();
      await settings.setDarkMode(false);
      await settings.setReducedMotion(true);
      final restored = ThemeService();
      await restored.init();
      expect(restored.isLightMode, isTrue);
      expect(restored.reducedMotion, isTrue);
      settings.dispose();
      restored.dispose();
    },
  );

  test('night override wins, and explicit theme selection clears it', () async {
    final settings = ThemeService();
    await settings.init();
    await settings.setDarkMode(false);
    await settings.setNightMode(true);
    expect(settings.isDarkMode, isTrue);
    expect(DropTheme.isNightTime(), isTrue);
    await settings.toggleTheme();
    expect(settings.isLightMode, isTrue);
    expect(settings.nightModeOverride, isFalse);
    final restored = ThemeService();
    await restored.init();
    expect(restored.isLightMode, isTrue);
    expect(restored.nightModeOverride, isFalse);
    settings.dispose();
    restored.dispose();
  });
  testWidgets('lake stops decorative animation when reduced motion changes', (
    tester,
  ) async {
    final settings = ThemeService();
    await settings.init();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: MaterialApp(
          home: Consumer<ThemeService>(
            builder: (context, preferences, _) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(disableAnimations: preferences.reducedMotion),
                child: const LakeBackground(child: SizedBox()),
              );
            },
          ),
        ),
      ),
    );
    expect(find.byType(FloatingParticles), findsOneWidget);
    await settings.setReducedMotion(true);
    await tester.pump();
    expect(find.byType(FloatingParticles), findsNothing);
    final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    expect(
      paints.where((paint) => paint.painter is WavePatternPainter),
      isEmpty,
    );
    await settings.setReducedMotion(false);
    await tester.pump();
    expect(find.byType(FloatingParticles), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
}
