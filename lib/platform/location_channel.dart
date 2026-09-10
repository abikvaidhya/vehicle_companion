import 'package:flutter/services.dart';

import '../core/constants.dart';

/// Thin wrapper around the location MethodChannel / EventChannel.
///
/// Controllers and UI never call MethodChannel directly — only this class.
class LocationChannel {
  static const _method =
      MethodChannel(AppConstants.locationMethodChannel);
  static const _events =
      EventChannel(AppConstants.locationEventChannel);

  /// One-shot current position.
  /// Returns map: latitude, longitude, accuracy, timestamp, speed
  Future<Map<String, dynamic>> getCurrentPosition() async {
    try {
      final result = await _method.invokeMethod<Map>('getCurrentPosition');
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? 'Failed to get position',
        details: e.details,
      );
    }
  }

  /// Continuous tracking stream for an active trip.
  Stream<Map<String, dynamic>> startTracking() {
    return _events.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }

  Future<void> stopTracking() async {
    try {
      await _method.invokeMethod('stopTracking');
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? 'Failed to stop tracking',
        details: e.details,
      );
    }
  }

  /// Returns: granted_fine | granted_coarse | denied | unknown
  Future<String> checkPermission() async {
    try {
      final result = await _method.invokeMethod<String>('checkPermission');
      return result ?? 'unknown';
    } on PlatformException catch (e) {
      throw LocationException(
        code: e.code,
        message: e.message ?? 'Permission check failed',
        details: e.details,
      );
    }
  }
}

class LocationException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  LocationException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'LocationException($code): $message';
}
