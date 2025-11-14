import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'services/native_bluetooth_controller.dart';

class FanControlPage extends StatefulWidget {
  @override
  _FanControlPageState createState() => _FanControlPageState();
}

class _FanControlPageState extends State<FanControlPage> {
  final NativeBluetoothController bluetoothController = Get.find<NativeBluetoothController>();
  
  String _fanStatus = 'OFF'; // LOW, MID, HIGH, OFF
  String _lastCommand = ''; // لتخزين آخر أمر تم إرساله
  bool _isSwingOn = false;
  bool _isBreezeModeOn = false; // High Comfort mode

  @override
  void initState() {
    super.initState();
    // الاستماع للبيانات الواردة من الأردوينو
    bluetoothController.dataStream.listen((data) {
      _handleReceivedData(data);
    });
  }

  void _handleReceivedData(String data) {
    // معالجة البيانات الواردة من الأردوينو
    String cleanData = data.trim();
    
    setState(() {
      // معالجة الأوامر من الأردوينو حسب الكود
      if (cleanData == 'L') {
        _fanStatus = 'LOW';
        _isBreezeModeOn = false;
      } else if (cleanData == 'M') {
        _fanStatus = 'MID';
        _isBreezeModeOn = false;
      } else if (cleanData == 'H') {
        _fanStatus = 'HIGH';
        _isBreezeModeOn = false;
      } else if (cleanData == 'O') {
        _fanStatus = 'OFF';
        _isBreezeModeOn = false;
        _isSwingOn = false;
      } else if (cleanData == 'S') {
        _isSwingOn = true;
      } else if (cleanData == 's') {
        _isSwingOn = false;
      } else if (cleanData == 'B') {
        _isBreezeModeOn = true;
      } else if (cleanData == 'b') {
        _isBreezeModeOn = false;
      }
    });
  }

  Future<void> _sendFanCommand(String command) async {
    if (!bluetoothController.isConnected.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not connected to device'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // إرسال الأمر للأردوينو (أحرف واحدة حسب كود الأردوينو)
    bool sent = await bluetoothController.sendData(command);
    
    if (sent) {
      setState(() {
        _lastCommand = command;
        // تحديث الحالة بناءً على الأمر
        if (command == 'L') {
          _fanStatus = 'LOW';
          _isBreezeModeOn = false;
        } else if (command == 'M') {
          _fanStatus = 'MID';
          _isBreezeModeOn = false;
        } else if (command == 'H') {
          _fanStatus = 'HIGH';
          _isBreezeModeOn = false;
        } else if (command == 'O') {
          _fanStatus = 'OFF';
          _isBreezeModeOn = false;
          _isSwingOn = false;
        } else if (command == 'S') {
          _isSwingOn = !_isSwingOn;
        } else if (command == 'B') {
          _isBreezeModeOn = !_isBreezeModeOn;
        }
      });
      
      print('✅ Sent fan command: $command');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send command'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF58C4C6), // Teal color
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Fan Test',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // للتوازن مع زر back
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fan Status Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFF58C4C6),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Fan Icon (ثلاث خطوط متموجة)
                          CustomPaint(
                            size: Size(80, 80),
                            painter: FanIconPainter(),
                          ),
                          SizedBox(height: 20),
                          // Fan Status Label
                          Text(
                            'Fan Status',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(height: 10),
                          // Current Status
                          Text(
                            _isBreezeModeOn ? 'High Comfort' : _fanStatus,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _isBreezeModeOn ? Colors.purple : Color(0xFF58C4C6),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Connected Button
                    Obx(() => Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: bluetoothController.isConnected.value 
                            ? Colors.green 
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            bluetoothController.isConnected.value 
                                ? 'Connected' 
                                : 'Disconnected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    )),

                    SizedBox(height: 30),

                    // Speed Buttons (LOW, MID, HIGH)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // LOW Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _sendFanCommand('L'),
                            child: Container(
                              height: 120,
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: (_fanStatus == 'LOW' && !_isBreezeModeOn) ? Colors.green : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: (_fanStatus == 'LOW' && !_isBreezeModeOn) ? Colors.green : Colors.blue,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.speed,
                                    size: 40,
                                    color: (_fanStatus == 'LOW' && !_isBreezeModeOn) ? Colors.white : Colors.blue,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'LOW',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: (_fanStatus == 'LOW' && !_isBreezeModeOn) ? Colors.white : Colors.blue,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // MID Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _sendFanCommand('M'),
                            child: Container(
                              height: 120,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: (_fanStatus == 'MID' && !_isBreezeModeOn) ? Colors.green : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: (_fanStatus == 'MID' && !_isBreezeModeOn) ? Colors.green : Colors.blue,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.speed,
                                    size: 40,
                                    color: (_fanStatus == 'MID' && !_isBreezeModeOn) ? Colors.white : Colors.blue,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'MID',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: (_fanStatus == 'MID' && !_isBreezeModeOn) ? Colors.white : Colors.blue,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // HIGH Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _sendFanCommand('H'),
                            child: Container(
                              height: 120,
                              margin: EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                color: (_fanStatus == 'HIGH' && !_isBreezeModeOn) ? Colors.green : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: (_fanStatus == 'HIGH' && !_isBreezeModeOn) ? Colors.green : Colors.blue,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.speed,
                                    size: 40,
                                    color: (_fanStatus == 'HIGH' && !_isBreezeModeOn) ? Colors.white : Colors.blue,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'HIGH',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: (_fanStatus == 'HIGH' && !_isBreezeModeOn) ? Colors.white : Colors.blue,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Swing and High Comfort Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Swing Button
                        Expanded(
                          child: Container(
                            height: 60,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: _isSwingOn ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _isSwingOn ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _sendFanCommand('S'),
                                borderRadius: BorderRadius.circular(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swap_horiz,
                                      color: _isSwingOn ? Colors.white : Colors.grey,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Swing',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _isSwingOn ? Colors.white : Colors.grey,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // High Comfort Button (Breeze Mode)
                        Expanded(
                          child: Container(
                            height: 60,
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: _isBreezeModeOn ? Colors.purple : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _isBreezeModeOn ? Colors.purple : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _sendFanCommand('B'),
                                borderRadius: BorderRadius.circular(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.ac_unit,
                                      color: _isBreezeModeOn ? Colors.white : Colors.grey,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'High Comfort',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _isBreezeModeOn ? Colors.white : Colors.grey,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // OFF Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _sendFanCommand('O'),
                          borderRadius: BorderRadius.circular(25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.power_settings_new,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'OFF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Bar
            if (_lastCommand.isNotEmpty && _fanStatus != 'OFF')
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Color(0xFF58C4C6),
                ),
                child: Center(
                  child: Text(
                    _isBreezeModeOn 
                        ? 'High Comfort Mode Active'
                        : 'Fan set to ${_fanStatus}${_isSwingOn ? ' • Swing ON' : ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Fan Icon (ثلاث خطوط متموجة)
class FanIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF58C4C6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    double centerY = size.height / 2;
    double waveLength = size.width * 0.8;
    double amplitude = size.height * 0.15;

    // Line 1 (top)
    for (double x = 0; x < size.width; x += 1) {
      double y = centerY - amplitude + amplitude * sin(x / waveLength * 2 * pi);
      if (x == 0) {
        path1.moveTo(x, y);
      } else {
        path1.lineTo(x, y);
      }
    }

    // Line 2 (middle)
    for (double x = 0; x < size.width; x += 1) {
      double y = centerY + amplitude * sin(x / waveLength * 2 * pi);
      if (x == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }

    // Line 3 (bottom)
    for (double x = 0; x < size.width; x += 1) {
      double y = centerY + amplitude + amplitude * sin(x / waveLength * 2 * pi);
      if (x == 0) {
        path3.moveTo(x, y);
      } else {
        path3.lineTo(x, y);
      }
    }

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


