import 'dart:convert';
import 'package:get/get.dart';
import 'native_bluetooth_controller.dart';
import '../models/food_item.dart';

class ArduinoCommandHandler {
  final NativeBluetoothController bluetoothController = Get.find<NativeBluetoothController>();
  
  // Singleton pattern
  static final ArduinoCommandHandler _instance = ArduinoCommandHandler._internal();
  factory ArduinoCommandHandler() => _instance;
  ArduinoCommandHandler._internal();

  // Send command to set control mode
  Future<bool> setControlMode(int mode) async {
    try {
      String command = '{"cmd":"SET_MODE","payload":{"mode":$mode}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('✅ Control mode set to: ${mode == 0 ? "Normal (ADC)" : "App Control"}');
        return true;
      } else {
        print('❌ Failed to set control mode');
        return false;
      }
    } catch (e) {
      print('Error setting control mode: $e');
      return false;
    }
  }

  // Send command to set output pins
  Future<bool> setOutputs({
    required bool out1,
    required bool out2,
    required bool out3,
    required bool out4,
    required bool out5,
  }) async {
    try {
      String command = '{"cmd":"SET_OUTPUTS","payload":{"out1":${out1 ? 1 : 0},"out2":${out2 ? 1 : 0},"out3":${out3 ? 1 : 0},"out4":${out4 ? 1 : 0},"out5":${out5 ? 1 : 0}}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('✅ Outputs set: OUT1:$out1, OUT2:$out2, OUT3:$out3, OUT4:$out4, OUT5:$out5');
        return true;
      } else {
        print('❌ Failed to set outputs');
        return false;
      }
    } catch (e) {
      print('Error setting outputs: $e');
      return false;
    }
  }

  // Send start cooking command
  Future<bool> startCooking(FoodItem foodItem) async {
    try {
      String command = '{"cmd":"START_COOKING","payload":{"temperature":${foodItem.temperature},"time":${foodItem.time},"steam":${foodItem.steam},"foodName":"${foodItem.name}"}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('✅ Start cooking command sent for: ${foodItem.name}');
        return true;
      } else {
        print('❌ Failed to send start cooking command');
        return false;
      }
    } catch (e) {
      print('Error sending start cooking command: $e');
      return false;
    }
  }

  // Send stop cooking command
  Future<bool> stopCooking() async {
    try {
      String command = '{"cmd":"STOP_COOKING","payload":{}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('✅ Stop cooking command sent');
        return true;
      } else {
        print('❌ Failed to send stop cooking command');
        return false;
      }
    } catch (e) {
      print('Error sending stop cooking command: $e');
      return false;
    }
  }

  // Send pause cooking command
  Future<bool> pauseCooking() async {
    try {
      String command = '{"cmd":"PAUSE_COOKING","payload":{}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('✅ Pause cooking command sent');
        return true;
      } else {
        print('❌ Failed to send pause cooking command');
        return false;
      }
    } catch (e) {
      print('Error sending pause cooking command: $e');
      return false;
    }
  }

  // Send resume cooking command
  Future<bool> resumeCooking() async {
    try {
      String command = '{"cmd":"RESUME_COOKING","payload":{}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('✅ Resume cooking command sent');
        return true;
      } else {
        print('❌ Failed to send resume cooking command');
        return false;
      }
    } catch (e) {
      print('Error sending resume cooking command: $e');
      return false;
    }
  }

  // Send emergency stop command
  Future<bool> emergencyStop() async {
    try {
      String command = '{"cmd":"EMERGENCY_STOP","payload":{}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('🚨 Emergency stop command sent');
        return true;
      } else {
        print('❌ Failed to send emergency stop command');
        return false;
      }
    } catch (e) {
      print('Error sending emergency stop command: $e');
      return false;
    }
  }

  // Send request for status
  Future<bool> requestStatus() async {
    try {
      String command = '{"cmd":"GET_STATUS","payload":{}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('📊 Status request sent');
        return true;
      } else {
        print('❌ Failed to send status request');
        return false;
      }
    } catch (e) {
      print('Error sending status request: $e');
      return false;
    }
  }

  // Send request for temperature
  Future<bool> requestTemperature() async {
    try {
      String command = '{"cmd":"GET_TEMPERATURE","payload":{}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('🌡️ Temperature request sent');
        return true;
      } else {
        print('❌ Failed to send temperature request');
        return false;
      }
    } catch (e) {
      print('Error sending temperature request: $e');
      return false;
    }
  }

  // Send request for timer
  Future<bool> requestTimer() async {
    try {
      String command = '{"cmd":"GET_TIMER","payload":{}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('⏱️ Timer request sent');
        return true;
      } else {
        print('❌ Failed to send timer request');
        return false;
      }
    } catch (e) {
      print('Error sending timer request: $e');
      return false;
    }
  }

  // Send custom command
  Future<bool> sendCustomCommand(String cmd, Map<String, dynamic> payload) async {
    try {
      String command = '{"cmd":"$cmd","payload":${jsonEncode(payload)}}';
      bool sent = await bluetoothController.sendData(command);
      
      if (sent) {
        print('✅ Custom command sent: $cmd');
        return true;
      } else {
        print('❌ Failed to send custom command: $cmd');
        return false;
      }
    } catch (e) {
      print('Error sending custom command: $e');
      return false;
    }
  }

  // Get temperature-based output configuration
  Map<String, bool> getTemperatureOutputs(int temperature) {
    Map<String, bool> outputs = {
      'out1': false,
      'out2': false,
      'out3': false,
      'out4': false,
      'out5': false,
    };

    // Temperature-based output selection (similar to ADC ranges in Arduino)
    if (temperature < 120) {
      outputs['out1'] = true; // Low temperature
    } else if (temperature < 150) {
      outputs['out2'] = true; // Medium-low temperature
    } else if (temperature < 180) {
      outputs['out3'] = true; // Medium temperature
    } else if (temperature < 210) {
      outputs['out4'] = true; // Medium-high temperature
    } else {
      outputs['out5'] = true; // High temperature
    }

    return outputs;
  }

  // Send complete cooking sequence
  Future<bool> sendCookingSequence(FoodItem foodItem) async {
    try {
      // Step 1: Set mode to app control
      bool modeSet = await setControlMode(1);
      if (!modeSet) return false;

      // Wait a bit for mode change
      await Future.delayed(Duration(milliseconds: 500));

      // Step 2: Send cooking parameters
      bool cookingStarted = await startCooking(foodItem);
      if (!cookingStarted) return false;

      // Step 3: Set outputs based on temperature
      Map<String, bool> outputs = getTemperatureOutputs(foodItem.temperature);
      bool outputsSet = await setOutputs(
        out1: outputs['out1']!,
        out2: outputs['out2']!,
        out3: outputs['out3']!,
        out4: outputs['out4']!,
        out5: outputs['out5']!,
      );

      if (outputsSet) {
        print('🎯 Complete cooking sequence sent successfully for: ${foodItem.name}');
        return true;
      } else {
        print('❌ Failed to set outputs in cooking sequence');
        return false;
      }
    } catch (e) {
      print('Error in cooking sequence: $e');
      return false;
    }
  }

  // Send stop sequence
  Future<bool> sendStopSequence() async {
    try {
      // Step 1: Turn off all outputs
      bool outputsStopped = await setOutputs(
        out1: false,
        out2: false,
        out3: false,
        out4: false,
        out5: false,
      );

      // Step 2: Send stop cooking command
      bool cookingStopped = await stopCooking();

      if (outputsStopped && cookingStopped) {
        print('🛑 Complete stop sequence sent successfully');
        return true;
      } else {
        print('❌ Failed to complete stop sequence');
        return false;
      }
    } catch (e) {
      print('Error in stop sequence: $e');
      return false;
    }
  }
}

