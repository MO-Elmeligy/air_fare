
import 'package:get/get.dart';
import 'dart:async';
import 'dart:typed_data';

// Mock Bluetooth Device class
class MockBluetoothDevice {
  final String name;
  final String address;
  final bool isBonded;

  MockBluetoothDevice({
    required this.name,
    required this.address,
    this.isBonded = false,
  });
}

// Mock Bluetooth Controller for testing
class BluetoothController extends GetxController {
  // Observable variables
  RxBool isBluetoothEnabled = true.obs; // Mock as enabled
  RxBool isConnected = false.obs;
  RxBool isScanning = false.obs;
  RxList<MockBluetoothDevice> discoveredDevices = <MockBluetoothDevice>[].obs;
  RxString connectedDeviceName = ''.obs;
  RxString lastReceivedData = ''.obs;
  
  // Stream for receiving data
  StreamController<String> dataStreamController = StreamController<String>.broadcast();
  Stream<String> get dataStream => dataStreamController.stream;

  @override
  void onInit() {
    super.onInit();
    _initializeBluetooth();
  }

  @override
  void onClose() {
    dataStreamController.close();
    super.onClose();
  }

  Future<void> _initializeBluetooth() async {
    try {
      // Mock initialization - always successful
      isBluetoothEnabled.value = true;
      print('Mock Bluetooth initialized successfully');
    } catch (e) {
      print('Error initializing Bluetooth: $e');
      isBluetoothEnabled.value = false;
    }
  }

  // Request Bluetooth permissions and enable Bluetooth
  Future<void> requestBluetoothPermissions() async {
    try {
      // Mock permission request - always successful
      isBluetoothEnabled.value = true;
      print('Mock Bluetooth permissions granted');
    } catch (e) {
      print('Error requesting Bluetooth permissions: $e');
    }
  }

  // Scan for available devices
  Future<void> scanDevices() async {
    if (!isBluetoothEnabled.value) {
      print('Bluetooth is not enabled');
      return;
    }

    try {
      isScanning.value = true;
      discoveredDevices.clear();

      // Mock scanning - add some fake devices
      await Future.delayed(Duration(seconds: 2));
      
      discoveredDevices.addAll([
        MockBluetoothDevice(
          name: 'HC-05',
          address: '00:11:22:33:44:55',
          isBonded: true,
        ),
        MockBluetoothDevice(
          name: 'Arduino BT',
          address: 'AA:BB:CC:DD:EE:FF',
          isBonded: false,
        ),
        MockBluetoothDevice(
          name: 'ESP32',
          address: '11:22:33:44:55:66',
          isBonded: false,
        ),
      ]);

      isScanning.value = false;
      print('Mock scan completed - found ${discoveredDevices.length} devices');

    } catch (e) {
      print('Error scanning devices: $e');
      isScanning.value = false;
    }
  }

  // Connect to a specific device
  Future<bool> connectToDevice(MockBluetoothDevice device) async {
    if (!isBluetoothEnabled.value) {
      print('Bluetooth is not enabled');
      return false;
    }

    try {
      // Disconnect from any existing connection
      await disconnect();

      print('Mock connecting to ${device.name}...');
      
      // Mock connection delay
      await Future.delayed(Duration(seconds: 2));
      
      isConnected.value = true;
      connectedDeviceName.value = device.name;
      
      print('Mock connected to ${device.name}');

      // Start mock data stream
      _startMockDataStream();

      return true;

    } catch (e) {
      print('Error connecting to device: $e');
      isConnected.value = false;
      connectedDeviceName.value = '';
      return false;
    }
  }

  // Send data to connected device
  Future<bool> sendData(String data) async {
    if (!isConnected.value) {
      print('Not connected to any device');
      return false;
    }

    try {
      print('Mock sent: $data');
      
      // Simulate response
      await Future.delayed(Duration(milliseconds: 500));
      String response = _generateMockResponse(data);
      dataStreamController.add(response);
      
      return true;

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
      String data = String.fromCharCodes(bytes);
      print('Mock sent bytes: $data');
      
      // Simulate response
      await Future.delayed(Duration(milliseconds: 500));
      String response = _generateMockResponse(data);
      dataStreamController.add(response);
      
      return true;

    } catch (e) {
      print('Error sending bytes: $e');
      return false;
    }
  }

  // Disconnect from current device
  Future<void> disconnect() async {
    try {
      isConnected.value = false;
      connectedDeviceName.value = '';
      print('Mock disconnected from device');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // Get paired devices
  Future<List<MockBluetoothDevice>> getPairedDevices() async {
    try {
      // Return mock paired devices
      return [
        MockBluetoothDevice(
          name: 'HC-05',
          address: '00:11:22:33:44:55',
          isBonded: true,
        ),
      ];
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }

  // Check if device is paired
  Future<bool> isDevicePaired(MockBluetoothDevice device) async {
    try {
      List<MockBluetoothDevice> pairedDevices = await getPairedDevices();
      return pairedDevices.any((pairedDevice) => pairedDevice.address == device.address);
    } catch (e) {
      print('Error checking if device is paired: $e');
      return false;
    }
  }

  // Pair with a device
  Future<bool> pairDevice(MockBluetoothDevice device) async {
    try {
      print('Mock pairing with ${device.name}');
      await Future.delayed(Duration(seconds: 1));
      return true;
    } catch (e) {
      print('Error pairing device: $e');
      return false;
    }
  }

  // Unpair a device
  Future<bool> unpairDevice(MockBluetoothDevice device) async {
    try {
      print('Mock unpairing ${device.name}');
      await Future.delayed(Duration(seconds: 1));
      return true;
    } catch (e) {
      print('Error unpairing device: $e');
      return false;
    }
  }

  // Mock data stream
  void _startMockDataStream() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (!isConnected.value) {
        timer.cancel();
        return;
      }
      
      // Send mock sensor data
      String mockData = _generateMockSensorData();
      dataStreamController.add(mockData);
      lastReceivedData.value = mockData;
    });
  }

  // Generate mock response based on sent data
  String _generateMockResponse(String data) {
    String cleanData = data.trim().toLowerCase();
    
    switch (cleanData) {
      case 'start_cooking':
        return 'cooking_started';
      case 'stop_cooking':
        return 'cooking_stopped';
      case 'get_temperature':
        return 'temp:75.5';
      case 'get_status':
        return 'status:cooking_active';
      case 'test':
        return 'test_response:ok';
      default:
        return 'received:$data';
    }
  }

  // Generate mock sensor data
  String _generateMockSensorData() {
    double temp = 70.0 + (DateTime.now().millisecondsSinceEpoch % 100) / 10.0;
    int humidity = 50 + (DateTime.now().millisecondsSinceEpoch % 30);
    return 'sensor_data:temp:$temp,humidity:$humidity';
  }
}