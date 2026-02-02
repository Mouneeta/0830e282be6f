import 'dart:developer';
import 'package:flutter/services.dart';

class DeviceVitalChannel {
  static const platform = MethodChannel('com.flutter.device_vitals');

  Future<Map<String, dynamic>> getDeviceStatus() async {
    try {
      final result = await platform.invokeMethod('getDeviceStatus');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      log("Failed to get device status: '${e.message}'.");
      return {};
    }
  }
}
