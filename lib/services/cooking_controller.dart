import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../Bluetooth_connection.dart';
import '../models/food_item.dart';

class CookingController extends GetxController {
  final BluetoothController bluetoothController = Get.find<BluetoothController>();
  
  // Cooking state
  RxBool isCooking = false.obs;
  RxString currentFoodName = ''.obs;
  RxInt remainingTime = 0.obs;
  RxDouble currentTemperature = 0.0.obs;
  RxString cookingStatus = 'idle'.obs;
  
  // Timer for cooking
  Timer? _cookingTimer;
  
  // Cooking parameters
  FoodItem? currentFoodItem;
  int totalCookingTime = 0;
  int targetTemperature = 0;
  
  @override
  void onClose() {
    _cookingTimer?.cancel();
    super.onClose();
  }
  
  // Start cooking a food item
  Future<bool> startCooking(FoodItem foodItem) async {
    if (!bluetoothController.isConnected.value) {
      Get.snackbar(
        'Error',
        'Bluetooth not connected. Please connect to a device first.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    try {
      // Set cooking parameters
      currentFoodItem = foodItem;
      currentFoodName.value = foodItem.name;
      targetTemperature = foodItem.temperature;
      totalCookingTime = foodItem.time;
      remainingTime.value = totalCookingTime;
      
      // Send cooking command to device
      String cookingCommand = 'start_cooking:${foodItem.temperature}:${foodItem.time}:${foodItem.steam}';
      bool sent = await bluetoothController.sendData(cookingCommand);
      
      if (sent) {
        isCooking.value = true;
        cookingStatus.value = 'cooking';
        
        // Start timer
        _startCookingTimer();
        
        Get.snackbar(
          'Cooking Started',
          'Started cooking ${foodItem.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to send cooking command',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
    } catch (e) {
      print('Error starting cooking: $e');
      Get.snackbar(
        'Error',
        'Failed to start cooking: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  // Stop cooking
  Future<bool> stopCooking() async {
    if (!isCooking.value) return true;
    
    try {
      bool sent = await bluetoothController.sendData('stop_cooking');
      
      if (sent) {
        _stopCookingTimer();
        isCooking.value = false;
        cookingStatus.value = 'stopped';
        
        Get.snackbar(
          'Cooking Stopped',
          'Stopped cooking ${currentFoodName.value}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to send stop command',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
    } catch (e) {
      print('Error stopping cooking: $e');
      return false;
    }
  }
  
  // Pause cooking
  Future<bool> pauseCooking() async {
    if (!isCooking.value) return true;
    
    try {
      bool sent = await bluetoothController.sendData('pause_cooking');
      
      if (sent) {
        _stopCookingTimer();
        cookingStatus.value = 'paused';
        
        Get.snackbar(
          'Cooking Paused',
          'Paused cooking ${currentFoodName.value}',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to send pause command',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
    } catch (e) {
      print('Error pausing cooking: $e');
      return false;
    }
  }
  
  // Resume cooking
  Future<bool> resumeCooking() async {
    if (cookingStatus.value != 'paused') return true;
    
    try {
      bool sent = await bluetoothController.sendData('resume_cooking');
      
      if (sent) {
        _startCookingTimer();
        cookingStatus.value = 'cooking';
        
        Get.snackbar(
          'Cooking Resumed',
          'Resumed cooking ${currentFoodName.value}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to send resume command',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
    } catch (e) {
      print('Error resuming cooking: $e');
      return false;
    }
  }
  
  // Get cooking status from device
  Future<void> getCookingStatus() async {
    if (!bluetoothController.isConnected.value) return;
    
    try {
      await bluetoothController.sendData('get_status');
    } catch (e) {
      print('Error getting cooking status: $e');
    }
  }
  
  // Get temperature from device
  Future<void> getTemperature() async {
    if (!bluetoothController.isConnected.value) return;
    
    try {
      await bluetoothController.sendData('get_temperature');
    } catch (e) {
      print('Error getting temperature: $e');
    }
  }
  
  // Emergency stop
  Future<bool> emergencyStop() async {
    try {
      bool sent = await bluetoothController.sendData('emergency_stop');
      
      if (sent) {
        _stopCookingTimer();
        isCooking.value = false;
        cookingStatus.value = 'emergency_stopped';
        
        Get.snackbar(
          'Emergency Stop',
          'Emergency stop activated',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to send emergency stop command',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
    } catch (e) {
      print('Error emergency stop: $e');
      return false;
    }
  }
  
  // Start cooking timer
  void _startCookingTimer() {
    _cookingTimer?.cancel();
    _cookingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        _cookingCompleted();
        timer.cancel();
      }
    });
  }
  
  // Stop cooking timer
  void _stopCookingTimer() {
    _cookingTimer?.cancel();
  }
  
  // Cooking completed
  void _cookingCompleted() {
    isCooking.value = false;
    cookingStatus.value = 'completed';
    
    Get.snackbar(
      'Cooking Completed',
      '${currentFoodName.value} is ready!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
    );
    
    // Send completion notification to device
    bluetoothController.sendData('cooking_completed');
  }
  
  // Format remaining time as MM:SS
  String get formattedRemainingTime {
    int minutes = remainingTime.value ~/ 60;
    int seconds = remainingTime.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Get cooking progress percentage
  double get cookingProgress {
    if (totalCookingTime == 0) return 0.0;
    return ((totalCookingTime - remainingTime.value) / totalCookingTime) * 100;
  }
  
  // Check if cooking is in progress
  bool get isCookingInProgress => isCooking.value && cookingStatus.value == 'cooking';
  
  // Check if cooking is paused
  bool get isCookingPaused => cookingStatus.value == 'paused';
  
  // Check if cooking is completed
  bool get isCookingCompleted => cookingStatus.value == 'completed';
}
