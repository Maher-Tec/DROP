import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../screens/splash_screen.dart';
import '../services/sound_service.dart';

/// DROP App - Premium Pro Max
/// 
/// One thought. Let it go.
/// 
/// A daily emotional release ritual - not a journal.
/// No lists. No pressure. No productivity guilt.
class DropApp extends StatefulWidget {
  const DropApp({super.key});

  @override
  State<DropApp> createState() => _DropAppState();
}

class _DropAppState extends State<DropApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register lifecycle observer to pause/resume sounds
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    soundService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is in background - pause all sounds
        soundService.pauseAmbient();
        break;
      case AppLifecycleState.resumed:
        // App is in foreground - resume sounds
        soundService.resumeAmbient();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lock to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI to transparent for immersive feel
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      title: 'DROP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: DropTheme.gradientTop,
        colorScheme: ColorScheme.dark(
          primary: DropTheme.dropAccent,
          secondary: DropTheme.tealAccent,
          surface: DropTheme.gradientTop,
        ),
        // Disable splash effects for calmer feel
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const SplashScreen(),
    );
  }
}
