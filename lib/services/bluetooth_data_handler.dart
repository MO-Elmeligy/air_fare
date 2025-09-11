import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'native_bluetooth_controller.dart';
import 'cooking_controller.dart';

class BluetoothDataHandler {
  final NativeBluetoothController bluetoothController = Get.find<NativeBluetoothController>();
  final CookingController cookingController = Get.find<CookingController>();
  
  // Singleton pattern
  static final BluetoothDataHandler _instance = BluetoothDataHandler._internal();
  factory BluetoothDataHandler() => _instance;
  BluetoothDataHandler._internal();

  void initialize() {
    // Listen to incoming data stream
    bluetoothController.dataStream.listen((data) {
      handleIncomingData(data);
    });
  }

  void handleIncomingData(String data) {
    // Clean the data
    String cleanData = data.trim();
    
    print('Handling incoming data: $cleanData');
    
    // Try to parse as JSON first
    if (cleanData.startsWith('{') && cleanData.endsWith('}')) {
      _handleJsonData(cleanData);
      return;
    }
    
    // Handle different types of commands
    switch (cleanData.toLowerCase()) {
      // Cooking commands
      case 'start_cooking':
        _handleStartCooking();
        break;
        
      case 'stop_cooking':
        _handleStopCooking();
        break;
        
      case 'pause_cooking':
        _handlePauseCooking();
        break;
        
      case 'resume_cooking':
        _handleResumeCooking();
        break;
        
      // Temperature commands
      case 'temp_high':
        _handleHighTemperature();
        break;
        
      case 'temp_low':
        _handleLowTemperature();
        break;
        
      case 'temp_normal':
        _handleNormalTemperature();
        break;
        
      // Timer commands
      case 'timer_start':
        _handleTimerStart();
        break;
        
      case 'timer_stop':
        _handleTimerStop();
        break;
        
      case 'timer_pause':
        _handleTimerPause();
        break;
        
      // Status requests
      case 'get_status':
        _handleStatusRequest();
        break;
        
      case 'get_temperature':
        _handleTemperatureRequest();
        break;
        
      case 'get_timer':
        _handleTimerRequest();
        break;
        
      // Emergency commands
      case 'emergency_stop':
        _handleEmergencyStop();
        break;
        
      case 'safety_check':
        _handleSafetyCheck();
        break;
        
      default:
        _handleCustomData(cleanData);
        break;
    }
  }

  // Cooking control methods
  void _handleStartCooking() {
    print('🚀 Starting cooking process...');
    // Add your cooking start logic here
    // Example: Start heating, turn on motors, etc.
    
    // Send confirmation back to device
    bluetoothController.sendData('cooking_started');
  }

  void _handleStopCooking() {
    print('⏹️ Stopping cooking process...');
    // Add your cooking stop logic here
    // Example: Stop heating, turn off motors, etc.
    
    bluetoothController.sendData('cooking_stopped');
  }

  void _handlePauseCooking() {
    print('⏸️ Pausing cooking process...');
    // Add your cooking pause logic here
    
    bluetoothController.sendData('cooking_paused');
  }

  void _handleResumeCooking() {
    print('▶️ Resuming cooking process...');
    // Add your cooking resume logic here
    
    bluetoothController.sendData('cooking_resumed');
  }

  // Temperature handling methods
  void _handleHighTemperature() {
    print('🔥 High temperature detected!');
    // Add your high temperature handling logic here
    // Example: Reduce heat, show warning, etc.
    
    bluetoothController.sendData('temp_high_ack');
  }

  void _handleLowTemperature() {
    print('❄️ Low temperature detected!');
    // Add your low temperature handling logic here
    // Example: Increase heat, show warning, etc.
    
    bluetoothController.sendData('temp_low_ack');
  }

  void _handleNormalTemperature() {
    print('✅ Temperature is normal');
    // Add your normal temperature handling logic here
    
    bluetoothController.sendData('temp_normal_ack');
  }

  // Timer handling methods
  void _handleTimerStart() {
    print('⏱️ Timer started');
    // Add your timer start logic here
    
    bluetoothController.sendData('timer_started');
  }

  void _handleTimerStop() {
    print('⏹️ Timer stopped');
    // Add your timer stop logic here
    
    bluetoothController.sendData('timer_stopped');
  }

  void _handleTimerPause() {
    print('⏸️ Timer paused');
    // Add your timer pause logic here
    
    bluetoothController.sendData('timer_paused');
  }

  // Status request methods
  void _handleStatusRequest() {
    print('📊 Status request received');
    // Get current status and send back
    String status = _getCurrentStatus();
    bluetoothController.sendData('status:$status');
  }

  void _handleTemperatureRequest() {
    print('🌡️ Temperature request received');
    // Get current temperature and send back
    String temperature = _getCurrentTemperature();
    bluetoothController.sendData('temp:$temperature');
  }

  void _handleTimerRequest() {
    print('⏱️ Timer request received');
    // Get current timer value and send back
    String timer = _getCurrentTimer();
    bluetoothController.sendData('timer:$timer');
  }

  // Emergency handling methods
  void _handleEmergencyStop() {
    print('🚨 EMERGENCY STOP triggered!');
    // Add your emergency stop logic here
    // Example: Stop all operations immediately
    
    bluetoothController.sendData('emergency_stop_ack');
  }

  void _handleSafetyCheck() {
    print('🔒 Safety check requested');
    // Add your safety check logic here
    // Example: Check all sensors, verify connections, etc.
    
    String safetyStatus = _performSafetyCheck();
    bluetoothController.sendData('safety:$safetyStatus');
  }

  // Custom data handling
  void _handleCustomData(String data) {
    print('📝 Custom data received: $data');
    
    // Try to parse as sensor data
    if (data.contains('temp:')) {
      _handleTemperatureData(data);
    } else if (data.contains('humidity:')) {
      _handleHumidityData(data);
    } else if (data.contains('weight:')) {
      _handleWeightData(data);
    } else {
      // Handle as general command
      bluetoothController.sendData('received:$data');
    }
  }

  void _handleTemperatureData(String data) {
    try {
      String tempValue = data.split(':')[1];
      double temperature = double.parse(tempValue);
      print('🌡️ Temperature reading: ${temperature}°C');
      
      // Add your temperature processing logic here
      
      bluetoothController.sendData('temp_processed');
    } catch (e) {
      print('Error parsing temperature data: $e');
    }
  }

  void _handleHumidityData(String data) {
    try {
      String humidityValue = data.split(':')[1];
      double humidity = double.parse(humidityValue);
      print('💧 Humidity reading: ${humidity}%');
      
      // Add your humidity processing logic here
      
      bluetoothController.sendData('humidity_processed');
    } catch (e) {
      print('Error parsing humidity data: $e');
    }
  }

  void _handleWeightData(String data) {
    try {
      String weightValue = data.split(':')[1];
      double weight = double.parse(weightValue);
      print('⚖️ Weight reading: ${weight}g');
      
      // Add your weight processing logic here
      
      bluetoothController.sendData('weight_processed');
    } catch (e) {
      print('Error parsing weight data: $e');
    }
  }

  // Helper methods to get current status
  String _getCurrentStatus() {
    // Add your logic to get current cooking status
    return 'cooking_active';
  }

  String _getCurrentTemperature() {
    // Add your logic to get current temperature
    return '75.5';
  }

  String _getCurrentTimer() {
    // Add your logic to get current timer value
    return '15:30';
  }

  String _performSafetyCheck() {
    // Add your logic to perform safety check
    return 'all_systems_ok';
  }

  // Method to send custom commands
  void sendCustomCommand(String command) {
    if (bluetoothController.isConnected.value) {
      bluetoothController.sendData(command);
    } else {
      print('Not connected to any device');
    }
  }

  // Method to send cooking parameters
  void sendCookingParameters({
    required int temperature,
    required int duration,
    required String mode,
  }) {
    String parameters = 'cook:$temperature:$duration:$mode';
    sendCustomCommand(parameters);
  }

  // Method to request sensor data
  void requestSensorData(String sensorType) {
    sendCustomCommand('get_$sensorType');
  }

  // Handle JSON data from Arduino
  void _handleJsonData(String jsonData) {
    try {
      Map<String, dynamic> data = jsonDecode(jsonData);
      
      // Handle different JSON commands from Arduino
      if (data.containsKey('status')) {
        _handleStatusJson(data);
      } else if (data.containsKey('ok')) {
        _handleOkResponse(data);
      } else if (data.containsKey('error')) {
        _handleErrorResponse(data);
      } else if (data.containsKey('telemetry')) {
        _handleTelemetryData(data);
      } else {
        print('Unknown JSON data received: $data');
      }
    } catch (e) {
      print('Error parsing JSON data: $e');
      print('Raw data: $jsonData');
    }
  }

  // Handle status JSON from Arduino
  void _handleStatusJson(Map<String, dynamic> data) {
    print('📊 Status received from Arduino: $data');
    
    // Update cooking controller with Arduino status
    if (data['status'] != null) {
      Map<String, dynamic> status = data['status'];
      
      // Update temperature if available
      if (status['adc'] != null) {
        // Convert ADC value to temperature (you may need to adjust this formula)
        double temperature = (status['adc'] as int) * 0.488; // Example conversion
        cookingController.currentTemperature.value = temperature;
      }
      
      // Update mode
      if (status['mode'] != null) {
        int mode = status['mode'] as int;
        print('Arduino control mode: ${mode == 0 ? "Normal (ADC)" : "App Control"}');
      }
      
      // Update output status
      if (status['out1'] != null) {
        print('Output 1: ${status['out1'] == 1 ? "ON" : "OFF"}');
      }
      if (status['out2'] != null) {
        print('Output 2: ${status['out2'] == 1 ? "ON" : "OFF"}');
      }
      if (status['out3'] != null) {
        print('Output 3: ${status['out3'] == 1 ? "ON" : "OFF"}');
      }
      if (status['out4'] != null) {
        print('Output 4: ${status['out4'] == 1 ? "ON" : "OFF"}');
      }
      if (status['out5'] != null) {
        print('Output 5: ${status['out5'] == 1 ? "ON" : "OFF"}');
      }
    }
  }

  // Handle OK response from Arduino
  void _handleOkResponse(Map<String, dynamic> data) {
    print('✅ Arduino response: OK');
    
    if (data['mode'] != null) {
      int mode = data['mode'] as int;
      print('Mode set to: ${mode == 0 ? "Normal (ADC)" : "App Control"}');
    }
  }

  // Handle error response from Arduino
  void _handleErrorResponse(Map<String, dynamic> data) {
    print('❌ Arduino error: ${data['error']}');
    
    // Show error to user
    Get.snackbar(
      'Arduino Error',
      data['error'] ?? 'Unknown error occurred',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Handle telemetry data from Arduino
  void _handleTelemetryData(Map<String, dynamic> data) {
    print('📡 Telemetry data received: $data');
    
    // Process telemetry data
    if (data['telemetry'] != null) {
      Map<String, dynamic> telemetry = data['telemetry'];
      
      // Update temperature
      if (telemetry['temperature'] != null) {
        double temperature = (telemetry['temperature'] as num).toDouble();
        cookingController.currentTemperature.value = temperature;
      }
      
      // Update humidity if available
      if (telemetry['humidity'] != null) {
        double humidity = (telemetry['humidity'] as num).toDouble();
        print('Humidity: ${humidity.toStringAsFixed(1)}%');
      }
      
      // Update weight if available
      if (telemetry['weight'] != null) {
        double weight = (telemetry['weight'] as num).toDouble();
        print('Weight: ${weight.toStringAsFixed(1)}g');
      }
    }
  }
}
