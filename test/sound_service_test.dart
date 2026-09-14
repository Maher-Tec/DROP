import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    SharedPreferences.setMockInitialValues({'sound_enabled': false});
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => call.method == 'getTemporaryDirectory' ? '.' : null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global/events'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        calls.add(call);
        if (call.method == 'create') {
          final id = (call.arguments as Map)['playerId'];
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null,
          );
        } else if (call.method == 'setSourceUrl') {
          final id = (call.arguments as Map)['playerId'];
          Future.microtask(() => messenger.handlePlatformMessage(
                'xyz.luan/audioplayers/events/$id',
                const StandardMethodCodec().encodeSuccessEnvelope(
                  {'event': 'audio.onPrepared', 'value': true},
                ),
                (_) {},
              ));
        }
        return null;
      },
    );
  });

  test(
    'saved music mute still plays drop effect after resume',
    () async {
      final sound = SoundService();
      await sound.init();
      await sound.playRelax();
      await sound.playRelaxLow();
      await sound.playLetItGo();
      expect(calls.where((c) => c.method.startsWith('setSource')), isEmpty);
      await sound.playWaterDrop();
      await sound.playPop();
      await sound.pauseAmbient();
      await sound.resumeAmbient();
      calls.clear();
      await sound.playWaterDrop();
      expect(sound.enabled, isFalse);
      expect(
        calls.where(
          (c) => c.method.startsWith('setSource'),
        ),
        isNotEmpty,
      );
      await sound.dispose();
    },
  );

  test('turning sound off stops players and persists the choice', () async {
    SharedPreferences.setMockInitialValues({'sound_enabled': true});
    final sound = SoundService();
    await sound.init();
    await sound.setEnabled(false);
    expect(calls.where((c) => c.method == 'stop'), isNotEmpty);
    await sound.resumeAmbient();
    calls.clear();
    await sound.playWaterDrop();
    expect(
      calls.where(
        (c) => c.method.startsWith('setSource'),
      ),
      isNotEmpty,
    );
    expect(
      (await SharedPreferences.getInstance()).getBool('sound_enabled'),
      isFalse,
    );
    await sound.dispose();
  });

}
