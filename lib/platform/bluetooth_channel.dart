import 'package:flutter/services.dart';

import '../core/constants.dart';

/// Thin wrapper for Bluetooth LE (scan / connect to simulated OBD).
/// Native implementation comes in the next step.
class BluetoothChannel {
  static const _method =
      MethodChannel(AppConstants.bluetoothMethodChannel);
  static const _events =
      EventChannel(AppConstants.bluetoothEventChannel);

  Future<void> startScan() async {
    try {
      await _method.invokeMethod('startScan');
    } on PlatformException catch (e) {
      throw BluetoothException(
        code: e.code,
        message: e.message ?? 'Scan failed',
        details: e.details,
      );
    }
  }

  Future<void> stopScan() async {
    try {
      await _method.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      throw BluetoothException(
        code: e.code,
        message: e.message ?? 'Stop scan failed',
        details: e.details,
      );
    }
  }

  Future<void> connect(String deviceId) async {
    try {
      await _method.invokeMethod('connect', {'deviceId': deviceId});
    } on PlatformException catch (e) {
      throw BluetoothException(
        code: e.code,
        message: e.message ?? 'Connect failed',
        details: e.details,
      );
    }
  }

  Future<void> disconnect() async {
    try {
      await _method.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      throw BluetoothException(
        code: e.code,
        message: e.message ?? 'Disconnect failed',
        details: e.details,
      );
    }
  }

  Stream<Map<String, dynamic>> deviceStream() {
    return _events.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }
}

class BluetoothException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  BluetoothException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'BluetoothException($code): $message';
}
