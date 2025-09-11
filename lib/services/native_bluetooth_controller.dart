import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:typed_data';

class NativeBluetoothController extends GetxController {
  // Method channel for native Android communication
  static const MethodChannel _channel = MethodChannel('bluetooth_serial');
  
  // Observable variables
  RxBool isBluetoothEnabled = false.obs;
  RxBool isConnected = false.obs;
  RxBool isScanning = false.obs;
  RxList<Map<String, dynamic>> discoveredDevices = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> pairedDevices = <Map<String, dynamic>>[].obs;
  RxString connectedDeviceName = ''.obs;
  RxString connectedDeviceAddress = ''.obs;
  RxString lastReceivedData = ''.obs;
  
  // Stream for receiving data
  StreamController<String> dataStreamController = StreamController<String>.broadcast();
  Stream<String> get dataStream => dataStreamController.stream;

  @override
  void onInit() {
    super.onInit();
    _initializeBluetooth();
    _setupMethodCallHandler();
  }

  @override
  void onClose() {
    dataStreamController.close();
    super.onClose();
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDataReceived':
          String data = call.arguments['data'] ?? '';
          dataStreamController.add(data);
          lastReceivedData.value = data;
          print('Received data: $data');
          break;
        case 'onDeviceFound':
          Map<String, dynamic> device = Map<String, dynamic>.from(call.arguments);
          print('Received device from native: ${device['name']} (${device['address']})');
          bool deviceExists = discoveredDevices.any((d) => d['address'] == device['address']);
          if (!deviceExists) {
            discoveredDevices.add(device);
            print('Added device to list: ${device['name']} (${device['address']})');
          } else {
            print('Device already exists: ${device['name']} (${device['address']})');
          }
          break;
        case 'onConnectionStateChanged':
          bool connected = call.arguments['connected'] ?? false;
          isConnected.value = connected;
          if (!connected) {
            connectedDeviceName.value = '';
            connectedDeviceAddress.value = '';
          }
          print('Connection state changed: $connected');
          break;
        case 'onBluetoothStateChanged':
          bool enabled = call.arguments['enabled'] ?? false;
          isBluetoothEnabled.value = enabled;
          print('Bluetooth state changed: $enabled');
          break;
      }
    });
  }

  Future<void> _initializeBluetooth() async {
    try {
      // Check if Bluetooth is available and enabled
      bool? isAvailable = await _channel.invokeMethod('isBluetoothAvailable');
      bool? isOn = await _channel.invokeMethod('isBluetoothEnabled');
      
      isBluetoothEnabled.value = (isAvailable == true && isOn == true);
      
      if (isBluetoothEnabled.value) {
        await _loadPairedDevices();
      }
      
      print('Native Bluetooth initialized - Available: $isAvailable, Enabled: $isOn');
    } catch (e) {
      print('Error initializing Bluetooth: $e');
      isBluetoothEnabled.value = false;
    }
  }

  // Request Bluetooth permissions
  Future<bool> requestBluetoothPermissions() async {
    try {
      print('Requesting Bluetooth permissions...');
      
      // Request location permission first (required for Bluetooth scanning)
      PermissionStatus locationStatus = await Permission.location.request();
      print('Location permission: $locationStatus');
      
      // Request Bluetooth permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();
      
      print('Bluetooth permissions: $statuses');
      
      // Check if all permissions are granted
      bool allGranted = statuses.values.every((status) => status == PermissionStatus.granted) &&
                       locationStatus == PermissionStatus.granted;
      
      if (allGranted) {
        print('All permissions granted');
        await _initializeBluetooth();
        return true;
      } else {
        print('Some permissions denied');
        return false;
      }
    } catch (e) {
      print('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  // Load paired devices
  Future<void> _loadPairedDevices() async {
    try {
      List<dynamic> devices = await _channel.invokeMethod('getPairedDevices');
      pairedDevices.value = devices.cast<Map<String, dynamic>>();
      print('Loaded ${devices.length} paired devices');
    } catch (e) {
      print('Error loading paired devices: $e');
    }
  }

  // Scan for available devices - زي Serial Bluetooth Terminal تماماً
  Future<void> scanDevices() async {
    if (!isBluetoothEnabled.value) {
      print('Bluetooth is not enabled');
      return;
    }

    // Check and request permissions first
    bool hasPermissions = await _checkPermissions();
    if (!hasPermissions) {
      print('Requesting permissions...');
      bool granted = await requestBluetoothPermissions();
      if (!granted) {
        print('Permissions denied, cannot scan');
        return;
      }
    }

    try {
      isScanning.value = true;
      discoveredDevices.clear();

      print('Starting native Bluetooth scan...');
      
      // Start scanning - زي Serial Bluetooth Terminal تماماً
      bool? result = await _channel.invokeMethod('startDiscovery');
      print('Discovery result: $result');
      
      if (result != true) {
        print('Failed to start discovery');
        isScanning.value = false;
        return;
      }

      // Stop scanning after 15 seconds
      Timer(Duration(seconds: 15), () {
        stopScanning();
      });

    } catch (e) {
      print('Error scanning devices: $e');
      isScanning.value = false;
    }
  }

  // Check if all required permissions are granted
  Future<bool> _checkPermissions() async {
    try {
      bool locationGranted = await Permission.location.isGranted;
      bool bluetoothGranted = await Permission.bluetooth.isGranted;
      bool bluetoothConnectGranted = await Permission.bluetoothConnect.isGranted;
      bool bluetoothScanGranted = await Permission.bluetoothScan.isGranted;
      
      print('Permission status - Location: $locationGranted, Bluetooth: $bluetoothGranted, Connect: $bluetoothConnectGranted, Scan: $bluetoothScanGranted');
      
      return locationGranted && bluetoothGranted && bluetoothConnectGranted && bluetoothScanGranted;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  // Stop scanning
  Future<void> stopScanning() async {
    try {
      await _channel.invokeMethod('cancelDiscovery');
      isScanning.value = false;
      print('Scan stopped - found ${discoveredDevices.length} devices');
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }

  // Connect to a specific device - زي Serial Bluetooth Terminal
  Future<bool> connectToDevice(Map<String, dynamic> device) async {
    print('=== CONNECT TO DEVICE CALLED ===');
    print('Device: $device');
    
    if (!isBluetoothEnabled.value) {
      print('Bluetooth is not enabled');
      return false;
    }

    // Check and request permissions first
    bool hasPermissions = await _checkPermissions();
    if (!hasPermissions) {
      print('Requesting permissions for connection...');
      bool granted = await requestBluetoothPermissions();
      if (!granted) {
        print('Permissions denied, cannot connect');
        return false;
      }
    }

    try {
      String deviceName = device['name'] ?? 'Unknown';
      String deviceAddress = device['address'] ?? '';
      
      print('Connecting to $deviceName ($deviceAddress)...');
      
      // Connect to the device - زي Serial Bluetooth Terminal تماماً
      bool? result = await _channel.invokeMethod('connect', {
        'address': deviceAddress,
        'name': deviceName,
      });
      
      print('Connection result: $result');
      
      if (result == true) {
        connectedDeviceName.value = deviceName;
        connectedDeviceAddress.value = deviceAddress;
        isConnected.value = true;
        print('Connected to $deviceName');
        return true;
      } else {
        print('Failed to connect to device');
        isConnected.value = false;
        return false;
      }

    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  // Send data to connected device - زي Serial Bluetooth Terminal
  Future<bool> sendData(String data) async {
    if (!isConnected.value) {
      print('Not connected to any device');
      return false;
    }

    try {
      bool? result = await _channel.invokeMethod('sendData', {'data': data});
      if (result == true) {
        print('Sent: $data');
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending data: $e');
      return false;
    }
  }

  // Send bytes directly
  Future<bool> sendBytes(Uint8List bytes) async {
    if (!isConnected.value) {
      print('Not connected to any device');
      return false;
    }

    try {
      bool? result = await _channel.invokeMethod('sendBytes', {'bytes': bytes.toList()});
      if (result == true) {
        print('Sent bytes: ${bytes.length} bytes');
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending bytes: $e');
      return false;
    }
  }

  // Disconnect from current device
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      isConnected.value = false;
      connectedDeviceName.value = '';
      connectedDeviceAddress.value = '';
      print('Disconnected from device');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // Get paired devices
  Future<List<Map<String, dynamic>>> getPairedDevices() async {
    try {
      List<dynamic> devices = await _channel.invokeMethod('getPairedDevices');
      pairedDevices.value = devices.cast<Map<String, dynamic>>();
      return pairedDevices;
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }

  // Check if device is paired
  bool isDevicePaired(Map<String, dynamic> device) {
    return pairedDevices.any((pairedDevice) => pairedDevice['address'] == device['address']);
  }

  // Pair with a device
  Future<bool> pairDevice(Map<String, dynamic> device) async {
    try {
      String deviceName = device['name'] ?? 'Unknown';
      print('Pairing with $deviceName');
      bool? result = await _channel.invokeMethod('pairDevice', {'address': device['address']});
      if (result == true) {
        await _loadPairedDevices();
        return true;
      }
      return false;
    } catch (e) {
      print('Error pairing device: $e');
      return false;
    }
  }

  // Unpair a device
  Future<bool> unpairDevice(Map<String, dynamic> device) async {
    try {
      String deviceName = device['name'] ?? 'Unknown';
      print('Unpairing $deviceName');
      bool? result = await _channel.invokeMethod('unpairDevice', {'address': device['address']});
      if (result == true) {
        await _loadPairedDevices();
        return true;
      }
      return false;
    } catch (e) {
      print('Error unpairing device: $e');
      return false;
    }
  }

  // Enable Bluetooth
  Future<bool> enableBluetooth() async {
    try {
      bool? result = await _channel.invokeMethod('enableBluetooth');
      if (result == true) {
        isBluetoothEnabled.value = true;
        await _loadPairedDevices();
        return true;
      }
      return false;
    } catch (e) {
      print('Error enabling Bluetooth: $e');
      return false;
    }
  }

  // Disable Bluetooth
  Future<bool> disableBluetooth() async {
    try {
      bool? result = await _channel.invokeMethod('disableBluetooth');
      if (result == true) {
        isBluetoothEnabled.value = false;
        await disconnect();
        return true;
      }
      return false;
    } catch (e) {
      print('Error disabling Bluetooth: $e');
      return false;
    }
  }

  // Check connection status - تحقق فعلي من الاتصال
  Future<bool> isDeviceConnected() async {
    try {
      bool? result = await _channel.invokeMethod('isConnected');
      bool isActuallyConnected = result == true;
      
      print('Connection status check: $isActuallyConnected');
      
      // Update UI state if connection is lost
      if (!isActuallyConnected && connectedDeviceName.value.isNotEmpty) {
        print('Connection lost - updating UI state');
        connectedDeviceName.value = '';
        connectedDeviceAddress.value = '';
        isConnected.value = false;
      }
      
      return isActuallyConnected;
    } catch (e) {
      print('Error checking connection status: $e');
      // Update UI state on error
      connectedDeviceName.value = '';
      connectedDeviceAddress.value = '';
      isConnected.value = false;
      return false;
    }
  }
}
