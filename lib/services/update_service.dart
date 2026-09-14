import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service to handle flexible in-app updates for Android.
///
/// Uses Google Play's in-app update API to:
/// 1. Check if an update is available
/// 2. Start flexible update (downloads in background)
/// 3. Complete update when user is ready
class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  AppUpdateInfo? _info;
  bool _started = false;

  /// Checks for update and starts flexible download if available.
  ///
  /// Returns true if an update flow started.
  /// Only works on Android when installed from Play Store.
  Future<bool> checkForUpdate({
    VoidCallback? onDownloading,
    VoidCallback? onDownloaded,
    void Function(Object error)? onError,
  }) async {
    // Only Android + not web
    if (kIsWeb || !Platform.isAndroid) return false;

    try {
      _info = await InAppUpdate.checkForUpdate();

      final availability = _info?.updateAvailability;
      final allowed = _info?.flexibleUpdateAllowed ?? false;

      final isAvailable = availability == UpdateAvailability.updateAvailable;

      if (!isAvailable || !allowed) return false;

      // Start flexible update once
      if (_started) return true;
      _started = true;

      onDownloading?.call();

      await InAppUpdate.startFlexibleUpdate();

      // If startFlexibleUpdate returns without throwing, download finished
      onDownloaded?.call();
      return true;
    } catch (e) {
      _started = false;
      onError?.call(e);
      return false;
    }
  }

  /// Completes the flexible update by installing the downloaded APK.
  ///
  /// Call this when user taps "Install" after download completes.
  Future<void> completeUpdate({void Function(Object error)? onError}) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      onError?.call(e);
    }
  }
}
