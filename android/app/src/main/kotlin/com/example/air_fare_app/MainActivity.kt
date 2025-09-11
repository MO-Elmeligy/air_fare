package com.example.air_fare_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "bluetooth_serial"
    private val bluetoothPlugin = BluetoothSerialPlugin()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the method channel
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(bluetoothPlugin)
        
        // Also add as plugin
        flutterEngine.plugins.add(bluetoothPlugin)
    }
}
