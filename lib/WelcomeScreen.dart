import 'package:air_fare_app/Bluetooth_connection.dart';
import 'package:air_fare_app/HomePage.dart';
import 'package:air_fare_app/BluetoothPage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final BluetoothController bluetoothController = Get.put(BluetoothController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenHeight = size.height;
    double screenWidth = size.width;
    
    // Responsive sizing
    double topImageWidth = screenWidth * 0.3;
    double bluetoothSize = screenWidth * 0.4; // 40% of screen width
    double buttonPadding = screenWidth * 0.1; // 10% of screen width
    double fontSize = screenWidth * 0.05; // 5% of screen width
    double iconSize = screenWidth * 0.06; // 6% of screen width
    
    // Ensure minimum and maximum sizes
    bluetoothSize = bluetoothSize.clamp(200.0, 400.0);
    fontSize = fontSize.clamp(16.0, 24.0);
    iconSize = iconSize.clamp(20.0, 32.0);
    buttonPadding = buttonPadding.clamp(20.0, 60.0);
    
    return Container(
      height: screenHeight,
      width: screenWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF58C4C6), Color(0xFFFFFFFF)],
        ),
      ),
      child: Stack(
        children: [
          // Top image - responsive positioning
          Positioned(
            top: screenHeight * 0, 
            left: screenWidth * 0, 
            child: Image.asset(
              'assets/images/main_top.png', 
              width: topImageWidth,
              fit: BoxFit.contain,
            ),
          ),
          
          // Main content - centered and responsive
          Center(
            child: Container(
              width: screenWidth * 0.9, // 90% of screen width
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bluetooth animation - responsive size
                  GestureDetector(
                                          onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BluetoothPage(),
                          ),
                        );
                      },
                    child: Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.02),
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 50,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Lottie.asset(
                        "assets/lottie/bluetooth.json",
                        width: bluetoothSize,
                        height: bluetoothSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  // Responsive spacing
                  SizedBox(height: screenHeight * 0.08),
                  
                  // Start button - responsive and flexible
                  Container(
                    width: screenWidth * 0.8, // 80% of screen width
                    decoration: BoxDecoration(
                     color: Colors.black,
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                    child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          horizontal: buttonPadding, 
                          vertical: screenHeight * 0.02
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        ),
                        minimumSize: Size(screenWidth * 0.6, screenHeight * 0.06),
                      ),
                      onPressed: bluetoothController.isConnected.value 
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyHomePage(),
                                ),
                              );
                            }
                          : () {
                              // Navigate directly to Bluetooth page instead of showing SnackBar
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BluetoothPage(),
                                ),
                              );
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            bluetoothController.isConnected.value 
                                ? Icons.bluetooth_connected 
                                : Icons.bluetooth_disabled,
                            color: bluetoothController.isConnected.value 
                                ? Colors.green 
                                : Colors.red,
                            size: iconSize,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Flexible(
                            child: Text(
                              bluetoothController.isConnected.value ? "Start" : "Need Connection",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom image - responsive positioning
          Positioned(
            bottom: screenHeight * 0, 
            left: screenWidth * 0, 
            child: Image.asset(
              'assets/images/main_bottom.png',
              width: screenWidth * 0.25, // 25% of screen width
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
