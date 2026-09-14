import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  AppUpdateInfo? _info;
  bool _started = false;

  Future<bool> checkForUpdate({
    VoidCallback? onDownloading,
    VoidCallback? onDownloaded,
    void Function(Object error)? onError,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return false;

    try {
      _info = await InAppUpdate.checkForUpdate();

      final availability = _info?.updateAvailability;
      final allowed = _info?.flexibleUpdateAllowed ?? false;

      final isAvailable = availability == UpdateAvailability.updateAvailable;

      if (!isAvailable || !allowed) return false;

      if (_started) return true;
      _started = true;

      onDownloading?.call();

      await InAppUpdate.startFlexibleUpdate();

      onDownloaded?.call();
      return true;
    } catch (e) {
      _started = false;
      onError?.call(e);
      return false;
    }
  }

  Future<void> completeUpdate({void Function(Object error)? onError}) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      onError?.call(e);
    }
  }
}
