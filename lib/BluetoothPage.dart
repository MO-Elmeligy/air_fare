import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'Bluetooth_connection.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ScanResultsPage extends StatefulWidget {
  @override
  _ScanResultsPageState createState() => _ScanResultsPageState();
}

class _ScanResultsPageState extends State<ScanResultsPage> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final BluetoothController bluetoothController = Get.put(BluetoothController());

  @override
  void initState() {
    super.initState();
    if (bluetoothController.isPlatformSupported.value) {
      bluetoothController.scanDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          Obx(() => bluetoothController.isConnected.value
              ? Icon(Icons.bluetooth_connected, color: Colors.green)
              : Icon(Icons.bluetooth_disabled, color: Colors.red)),
        ],
      ),
      body: Column(
        children: [
          // Warning message about connection requirement
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تنبيه مهم!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'يجب الاتصال بجهاز Bluetooth للوصول إلى الصفحة التالية',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Connection status
          Obx(() => Container(
            padding: EdgeInsets.all(16),
            color: bluetoothController.isBluetoothConnected 
                ? Colors.green.withOpacity(0.1) 
                : Colors.red.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  bluetoothController.isBluetoothConnected 
                      ? Icons.bluetooth_connected 
                      : Icons.bluetooth_disabled,
                  color: bluetoothController.isBluetoothConnected 
                      ? Colors.green 
                      : Colors.red,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bluetoothController.isBluetoothConnected 
                        ? 'Connected to ${bluetoothController.connectedDevice?.name ?? "Device"}'
                        : 'Not connected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bluetoothController.isBluetoothConnected 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          // Platform-specific content
          Obx(() {
            if (!bluetoothController.isPlatformSupported.value) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Bluetooth not supported on this platform',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
              // Desktop platform - show simulated content
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth, size: 64, color: Colors.blue),
                      SizedBox(height: 16),
                      Text(
                        'Desktop Platform Detected',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bluetooth functionality is simulated for testing',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _simulateConnection(),
                        child: Text('Simulate Connection'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // Mobile platform - show actual Bluetooth content
            return Expanded(
              child: StreamBuilder<List<ScanResult>>(
                stream: flutterBlue.scanResults,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data![index];
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(data.device.name.isNotEmpty
                                ? data.device.name
                                : 'Unknown Device'),
                            subtitle: Text(data.device.id.id),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(data.rssi.toString()),
                                SizedBox(width: 8),
                                Obx(() => bluetoothController.connectedDevice?.id == data.device.id
                                    ? Icon(Icons.bluetooth_connected, color: Colors.green)
                                    : IconButton(
                                        icon: Icon(Icons.bluetooth),
                                        onPressed: () => _connectToDevice(data.device),
                                      )),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Scanning for devices...'),
                        ],
                      ),
                    );
                  }
                },
              ),
            );
          }),
        ],
      ),
      floatingActionButton: Obx(() {
        if (!bluetoothController.isPlatformSupported.value || 
            kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
          return SizedBox.shrink();
        }
        return FloatingActionButton(
          onPressed: () {
            bluetoothController.scanDevices();
          },
          child: Icon(Icons.refresh),
        );
      }),
    );
  }

  void _simulateConnection() {
    bluetoothController.simulateConnection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulated Bluetooth connection'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await bluetoothController.connectToDevice(device);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
