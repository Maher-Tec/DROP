import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../config/theme.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/write_screen.dart';
import '../services/sound_service.dart';
import '../services/update_service.dart';
import '../services/widget_launch_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class DropApp extends StatefulWidget {
  final String? initialWidgetAction;

  const DropApp({super.key, this.initialWidgetAction});

  @override
  State<DropApp> createState() => _DropAppState();
}

class _DropAppState extends State<DropApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetLaunchService.listen(_openWidgetAction);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    if (widget.initialWidgetAction != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openWidgetAction(widget.initialWidgetAction!),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
  }

  Future<void> _checkForUpdates() async {
    await UpdateService.instance.checkForUpdate(
      onDownloading: () {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: const Text(
              'Update available — downloading in background…',
            ),
            backgroundColor: DropTheme.dropAccent.withValues(alpha: 0.9),
            duration: const Duration(seconds: 4),
          ),
        );
      },
      onDownloaded: () {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: const Text('Update ready — tap to install'),
            backgroundColor: DropTheme.tealAccent.withValues(alpha: 0.9),
            action: SnackBarAction(
              label: 'INSTALL',
              textColor: Colors.white,
              onPressed: () async {
                await UpdateService.instance.completeUpdate();
              },
            ),
            duration: const Duration(days: 1),
          ),
        );
      },
      onError: (e) {
        debugPrint('Update check error: $e');
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WidgetLaunchService.stopListening();
    soundService.dispose();
    super.dispose();
  }

  void _openWidgetAction(String action) {
    if (action != 'write' && action != 'wordless') return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = appNavigatorKey.currentState;
      if (navigator == null) return;
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => WriteScreen(wordless: action == 'wordless'),
        ),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        soundService.pauseAmbient();
        break;
      case AppLifecycleState.resumed:
        soundService.resumeAmbient();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<ThemeService>();
    return MaterialApp(
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations:
                media.disableAnimations || preferences.reducedMotion,
          ),
          child: child!,
        );
      },
      title: 'DROP',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        useMaterial3: true,
        brightness: preferences.isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: DropTheme.gradientTop,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DropTheme.dropAccent,
          brightness: preferences.isDarkMode
              ? Brightness.dark
              : Brightness.light,
          primary: DropTheme.dropAccent,
          secondary: DropTheme.tealAccent,
          surface: DropTheme.gradientTop,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: widget.initialWidgetAction == null
          ? const SplashScreen()
          : const HomeScreen(),
    );
  }
}
