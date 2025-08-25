import 'package:air_fare_app/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/food_provider.dart';

void main() {
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

