import 'package:air_fare_app/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'providers/food_provider.dart';
import 'Bluetooth_connection.dart';
import 'services/bluetooth_data_handler.dart';

void main() {
  runApp(const MyApp());
  
  // Initialize Bluetooth controller
  Get.put(BluetoothController());
  
  // Initialize Bluetooth data handler
  final dataHandler = BluetoothDataHandler();
  dataHandler.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FoodProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const WelcomeScreen(),//استدعاء اول صفحة
      ),
    );
  }
}

