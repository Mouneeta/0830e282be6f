import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'device_vitals_hive_model.dart';

class HiveInit {
  static Future<void> initialize() async {
    try {
      log('HiveInit: Initializing Hive...');
      
      // Initialize Hive with Flutter
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DeviceVitalsHiveModelAdapter());
        log('HiveInit: DeviceVitalsHiveModel adapter registered');
      }
      
      log('HiveInit: Hive initialized successfully');
    } catch (e) {
      log('HiveInit: Error initializing Hive: $e');
      rethrow;
    }
  }
}
