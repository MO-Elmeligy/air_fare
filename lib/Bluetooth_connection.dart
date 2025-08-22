
import 'package:flutter_blue/flutter_blue.dart'; 
import 'package:get/get.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class BluetoothController extends GetxController {
  FlutterBlue? flutterBlue;
  RxBool isConnected = false.obs;
  RxBool isBluetoothOn = false.obs;
  RxBool isPlatformSupported = false.obs;
  BluetoothDevice? connectedDevice;
  
  @override
  void onInit() {
    super.onInit();
    _initializeBluetooth();
  }

  void _initializeBluetooth() {
    // Check if platform supports Bluetooth
    if (kIsWeb) {
      isPlatformSupported.value = false;
      isBluetoothOn.value = false;
      return;
    }
    
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        flutterBlue = FlutterBlue.instance;
        isPlatformSupported.value = true;
        checkBluetoothStatus();
      } else {
        // For Windows, Linux, macOS - simulate Bluetooth functionality
        isPlatformSupported.value = true;
        isBluetoothOn.value = true;
        // Simulate connection for testing purposes
        simulateConnection();
      }
    } catch (e) {
      print('Error initializing Bluetooth: $e');
      isPlatformSupported.value = false;
      isBluetoothOn.value = false;
    }
  }

  void simulateConnection() {
    // Simulate a successful connection for testing on desktop platforms
    Future.delayed(Duration(seconds: 2), () {
      isConnected.value = true;
      print('Simulated Bluetooth connection for desktop platform');
    });
  }

  Future<void> checkBluetoothStatus() async {
    if (!isPlatformSupported.value || flutterBlue == null) return;
    
    try {
      // Check if Bluetooth is available and on
      isBluetoothOn.value = await flutterBlue!.isAvailable;
      
      // Listen to Bluetooth state changes
      flutterBlue!.state.listen((state) {
        isBluetoothOn.value = state == BluetoothState.on;
        if (state != BluetoothState.on) {
          isConnected.value = false;
          connectedDevice = null;
        }
      });
    } catch (e) {
      print('Error checking Bluetooth status: $e');
      isBluetoothOn.value = false;
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (!isPlatformSupported.value) {
      // Simulate connection for desktop platforms
      simulateConnection();
      return;
    }
    
    try {
      await device.connect();
      connectedDevice = device;
      isConnected.value = true;
      
      // Listen to connection state changes
      device.state.listen((state) {
        isConnected.value = state == BluetoothDeviceState.connected;
        if (state != BluetoothDeviceState.connected) {
          connectedDevice = null;
        }
      });
    } catch (e) {
      print('Error connecting to device: $e');
      isConnected.value = false;
      connectedDevice = null;
    }
  }

  Future<void> disconnect() async {
    if (connectedDevice != null && flutterBlue != null) {
      try {
        await connectedDevice!.disconnect();
      } catch (e) {
        print('Error disconnecting: $e');
      }
    }
    isConnected.value = false;
    connectedDevice = null;
  }

  bool get isBluetoothConnected => isBluetoothOn.value && isConnected.value;
  
  Future<void> scanDevices() async {
    if (!isPlatformSupported.value) {
      print('Bluetooth not supported on this platform');
      return;
    }
    
    if (flutterBlue == null) {
      // For desktop platforms, simulate scanning
      print('Simulating device scan for desktop platform');
      return;
    }
    
    if (!isBluetoothOn.value) {
      print('Bluetooth is not available');
      return;
    }
    
    // the Bluetooth starts scanning for devices for (seconds: 4)
    // Start scanning
    flutterBlue!.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = flutterBlue!.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
            print('${r.device.name} found! rssi: ${r.rssi}');
        }
    });

    // Stop scanning
    flutterBlue!.stopScan();
  }
}