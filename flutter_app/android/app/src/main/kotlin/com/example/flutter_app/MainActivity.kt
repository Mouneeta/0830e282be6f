package com.example.flutter_app

import android.app.ActivityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.os.Build
import android.os.PowerManager
import android.os.BatteryManager
import android.provider.Settings

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.flutter.device_vitals"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceStatus" -> {
                        result.success(getDeviceStatus())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun getDeviceStatus(): Map<String, Any> {
        return mapOf(
            "battery_level" to getBatteryCapacity(),
            "memory_usage" to getMemoryUsage(),
            "thermal_value" to getMappedThermalStatus(applicationContext),
            "device_id" to getUniqueDeviceId()
        )
    }

    private fun getBatteryCapacity(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        // Returns battery capacity as percentage (0-100)
        val batteryCapacity = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        return batteryCapacity
    }

    private fun getMemoryUsage(): Int {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)

        val usedMemory: Long = memoryInfo.totalMem - memoryInfo.availMem
        val totalMemory: Long = memoryInfo.totalMem

        return ((usedMemory.toDouble() / totalMemory.toDouble()) * 100).toInt()
    }


    private fun getMappedThermalStatus(context: Context): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            println("Thermal status API not available on this Android version")
            return -1 // fallback for older versions
        }

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val status = powerManager.currentThermalStatus

        return when (status) {
            PowerManager.THERMAL_STATUS_NONE -> 0   // Normal
            PowerManager.THERMAL_STATUS_LIGHT -> 1  // Light
            PowerManager.THERMAL_STATUS_MODERATE -> 2 // Moderate
            PowerManager.THERMAL_STATUS_SEVERE -> 3   // Severe
            PowerManager.THERMAL_STATUS_CRITICAL,
            PowerManager.THERMAL_STATUS_EMERGENCY,
            PowerManager.THERMAL_STATUS_SHUTDOWN -> 4 // Optional: map higher levels
            else -> -1 // Unknown
        }
    }

    private fun getUniqueDeviceId(): String {
        return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID) ?: "unknown"
    }


}
