import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Bluetooth_connection.dart';

class BluetoothPage extends StatelessWidget {
  final BluetoothController bluetoothController = Get.put(BluetoothController());

  @override
  Widget build(BuildContext context) {
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
                                  MockBluetoothDevice device = bluetoothController.discoveredDevices[index];
                                  return ListTile(
                                    leading: Icon(Icons.bluetooth),
                                    title: Text(device.name ?? 'Unknown Device'),
                                    subtitle: Text(device.address),
                                    trailing: ElevatedButton(
                                      onPressed: bluetoothController.isConnected.value
                                          ? null
                                          : () => bluetoothController.connectToDevice(device),
                                      child: Text('Connect'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
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
            
            // Data Communication Section
            if (bluetoothController.isConnected.value) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Communication',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter command to send',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  bluetoothController.sendData(value);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Send a test command
                              bluetoothController.sendData('test_command');
                            },
                            child: Text('Send Test'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Obx(() => Text(
                        'Last received: ${bluetoothController.lastReceivedData.value.isEmpty ? "No data" : bluetoothController.lastReceivedData.value}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
