import 'package:air_fare_app/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'providers/food_provider.dart';
import 'services/native_bluetooth_controller.dart';
import 'services/bluetooth_data_handler.dart';
import 'services/cooking_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  Get.put(NativeBluetoothController());
  Get.put(CookingController());
  
  // Initialize Bluetooth data handler
  final dataHandler = BluetoothDataHandler();
  dataHandler.initialize();
  
  runApp(const MyApp());
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

