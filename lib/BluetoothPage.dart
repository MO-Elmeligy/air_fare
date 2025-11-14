import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/native_bluetooth_controller.dart';

class BluetoothPage extends StatelessWidget {
  final NativeBluetoothController bluetoothController = Get.put(NativeBluetoothController());

  @override
  Widget build(BuildContext context) {
    // Request permissions when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bluetoothController.requestBluetoothPermissions();
      
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Connection'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bluetooth Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          bluetoothController.isBluetoothEnabled.value
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          color: bluetoothController.isBluetoothEnabled.value
                              ? Colors.green
                              : Colors.red,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Bluetooth Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Obx(() => Text(
                      bluetoothController.isBluetoothEnabled.value
                          ? 'Bluetooth is enabled'
                          : 'Bluetooth is disabled',
                      style: TextStyle(
                        color: bluetoothController.isBluetoothEnabled.value
                            ? Colors.green
                            : Colors.red,
                      ),
                    )),
                    SizedBox(height: 10),
                    if (!bluetoothController.isBluetoothEnabled.value)
                      ElevatedButton(
                        onPressed: () => bluetoothController.requestBluetoothPermissions(),
                        child: Text('Enable Bluetooth'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Connection Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          bluetoothController.isConnected.value
                              ? Icons.link
                              : Icons.link_off,
                          color: bluetoothController.isConnected.value
                              ? Colors.green
                              : Colors.red,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Connection Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Obx(() => Text(
                      bluetoothController.isConnected.value
                          ? 'Connected to: ${bluetoothController.connectedDeviceName.value}'
                          : 'Not connected',
                      style: TextStyle(
                        color: bluetoothController.isConnected.value
                            ? Colors.green
                            : Colors.red,
                      ),
                    )),
                    SizedBox(height: 10),
                    if (bluetoothController.isConnected.value)
                      ElevatedButton(
                        onPressed: () => bluetoothController.disconnect(),
                        child: Text('Disconnect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Scan Button
            Obx(() => ElevatedButton(
              onPressed: bluetoothController.isBluetoothEnabled.value && !bluetoothController.isScanning.value
                  ? () => bluetoothController.scanDevices()
                  : null,
              child: bluetoothController.isScanning.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Scanning...'),
                      ],
                    )
                  : Text('Scan for Devices'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            )),
            
            SizedBox(height: 10),
            
            // Refresh Button
            ElevatedButton(
              onPressed: () async {
                await bluetoothController.requestBluetoothPermissions();
                await bluetoothController.scanDevices();
              },
              child: Text('Refresh & Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Discovered Devices List
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discovered Devices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Obx(() => bluetoothController.discoveredDevices.isEmpty
                            ? Center(
                                child: Text(
                                  'No devices found',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: bluetoothController.discoveredDevices.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> device = bluetoothController.discoveredDevices[index];
                                  return ListTile(
                                    leading: Icon(Icons.bluetooth),
                                    title: Text(device['name']?.isNotEmpty == true ? device['name'] : 'Unknown Device'),
                                    subtitle: Text(device['address'] ?? 'No Address'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (bluetoothController.isDevicePaired(device))
                                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            print('Connect button pressed for device: ${device['name']}');
                                            
                                            // Show loading indicator
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  content: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      CircularProgressIndicator(),
                                                      SizedBox(width: 20),
                                                      Flexible(
                                                        child: Text(
                                                          'Connecting to ${device['name']}...',
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                            
                                            bool connected = await bluetoothController.connectToDevice(device);
                                            
                                            // Hide loading indicator
                                            Navigator.of(context).pop();
                                            
                                            if (connected) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Connected to ${device['name']}'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to connect to ${device['name']}'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: Text('Connect'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }

}
