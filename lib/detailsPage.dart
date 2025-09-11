import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'models/food_item.dart';
import 'NewDetailsPage.dart';
import 'providers/food_provider.dart';
import 'services/cooking_controller.dart';
import 'services/arduino_command_handler.dart';
import 'services/native_bluetooth_controller.dart';

class DetailsPage extends StatefulWidget {
  final String imgPath;
  final String foodName;
  final FoodItem? foodItem;
  //final int index;

  const DetailsPage({
    Key? key,
    required this.imgPath,
    required this.foodName,
    this.foodItem,
    //required this.index,
  }) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // New variables for temperature, timer, and steam
  int temperature = 175;
  int time = 30;
  int steam = 1;
  
  // Controllers
  final CookingController cookingController = Get.put(CookingController());
  final NativeBluetoothController bluetoothController = Get.find<NativeBluetoothController>();
  final ArduinoCommandHandler arduinoHandler = ArduinoCommandHandler();

  @override
  void initState() {
    super.initState();
    
    // Load data from FoodItem if available, otherwise use default values
    if (widget.foodItem != null) {
      temperature = widget.foodItem!.temperature;
      time = widget.foodItem!.time;
      steam = widget.foodItem!.steam;
    }
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
         _slideAnimation = Tween<Offset>(
       begin: Offset(0, 0.5),
       end: Offset.zero,
     ).animate(CurvedAnimation(
       parent: _animationController,
       curve: Curves.elasticOut,
     ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF7A9BEE),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text('Details',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.0,
                  color: Colors.white)),
          centerTitle: true,
          actions: <Widget>[
            if (widget.foodItem != null) ...[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editFoodItem(),
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteFoodItem(),
                color: Colors.white,
              ),
            ] else ...[
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('This is an original recipe item'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                color: Colors.white,
              )
            ]
          ],
        ),
        body: ListView(children: [
          Stack(children: [
            Container(
                height: MediaQuery.of(context).size.height - 82.0,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent),
            Positioned(
                top: 75.0,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(45.0),
                          topRight: Radius.circular(45.0),
                        ),
                        color: Colors.white),
                    height: MediaQuery.of(context).size.height - 100.0,
                    width: MediaQuery.of(context).size.width)),
                         Positioned(
                 top: 30.0,
                 left: (MediaQuery.of(context).size.width / 2) - 100.0,
                 child: FadeTransition(
                   opacity: _fadeAnimation,
                   child: SlideTransition(
                     position: Tween<Offset>(
                       begin: Offset(0, -0.3),
                       end: Offset.zero,
                     ).animate(CurvedAnimation(
                       parent: _animationController,
                       curve: Curves.easeOutBack,
                     )),
                     child: Hero(
                         tag: '${widget.imgPath}',
                         child: Container(
                             decoration: BoxDecoration(
                                 image: DecorationImage(
                                     image: widget.foodItem != null 
                                         ? FileImage(File(widget.imgPath))
                                         : AssetImage(widget.imgPath) as ImageProvider,
                                     fit: BoxFit.cover)),
                             height: 200.0,
                             width: 200.0)),
                   ),
                 )),
            Positioned(
                top: 250.0,
                left: 25.0,
                right: 25.0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                                                 Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: <Widget>[
                             Expanded(
                               child: Text(widget.foodName,
                                   style: TextStyle(
                                       fontFamily: 'Montserrat',
                                       fontSize: 22.0,
                                       fontWeight: FontWeight.bold)),
                             ),
                             Container(
                               width: 120.0,
                               height: 40.0,
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(20.0),
                                   color: Color(0xFF7A9BEE)),
                               child: InkWell(
                                 onTap: () {
                                   // Reheat functionality
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(
                                       content: Text('Reheating ${widget.foodName}...'),
                                       backgroundColor: Colors.green,
                                       duration: Duration(seconds: 2),
                                     ),
                                   );
                                 },
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: <Widget>[
                                     Icon(
                                       Icons.replay,
                                       color: Colors.white,
                                       size: 18.0,
                                     ),
                                     SizedBox(width: 6.0),
                                     Text('Reheat',
                                         style: TextStyle(
                                             color: Colors.white,
                                             fontFamily: 'Montserrat',
                                             fontSize: 14.0,
                                             fontWeight: FontWeight.bold)),
                                   ],
                                 ),
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: 20.0),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.foodItem != null) ...[
                                // Custom food item - show editable sliders
                                Text("Temperature: $temperature °C",
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      color: Colors.black87,
                                    )),
                                Slider(
                                  value: temperature.toDouble(),
                                  min: 100,
                                  max: 250,
                                  divisions: 15,
                                  activeColor: Color(0xFF7A9BEE),
                                  inactiveColor: Colors.grey.withOpacity(0.3),
                                  label: "$temperature °C",
                                  onChanged: (val) {
                                    setState(() {
                                      temperature = val.toInt();
                                    });
                                  },
                                ),

                                SizedBox(height: 20),
                                Text("Time: $time min",
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      color: Colors.black87,
                                    )),
                                Slider(
                                  value: time.toDouble(),
                                  min: 1,
                                  max: 60,
                                  divisions: 59,
                                  activeColor: Color(0xFF7A9BEE),
                                  inactiveColor: Colors.grey.withOpacity(0.3),
                                  label: "$time min",
                                  onChanged: (val) {
                                    setState(() {
                                      time = val.toInt();
                                    });
                                  },
                                ),

                                SizedBox(height: 20),
                                Text("Steam Level: $steam",
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      color: Colors.black87,
                                    )),
                                Slider(
                                  value: steam.toDouble(),
                                  min: 0,
                                  max: 2,
                                  divisions: 2,
                                  activeColor: Color(0xFF7A9BEE),
                                  inactiveColor: Colors.grey.withOpacity(0.3),
                                  label: steam == 0 ? "Off" : steam == 1 ? "Medium" : "High",
                                  onChanged: (val) {
                                    setState(() {
                                      steam = val.toInt();
                                    });
                                  },
                                ),
                              ] else ...[
                                // Original food item - show fixed values
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Original Recipe Settings",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Temperature:", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                                          Text("175°C", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Time:", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                                          Text("30 min", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Steam:", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                                          Text("Medium", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                          Padding(
                            padding: EdgeInsets.only(bottom:5.0),
                            child: Obx(() => InkWell(
                              onTap: bluetoothController.isConnected.value 
                                  ? () => _startCooking()
                                  : () => _showConnectionDialog(),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0), 
                                    topRight: Radius.circular(10.0), 
                                    bottomLeft: Radius.circular(25.0), 
                                    bottomRight: Radius.circular(25.0)
                                  ),
                                  color: bluetoothController.isConnected.value 
                                      ? Colors.black 
                                      : Colors.grey[600],
                                ),
                                height: 50.0,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (cookingController.isCookingInProgress) ...[
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                      Icon(
                                        bluetoothController.isConnected.value 
                                            ? (cookingController.isCookingInProgress ? Icons.pause : Icons.play_arrow)
                                            : Icons.bluetooth_disabled,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        bluetoothController.isConnected.value 
                                            ? (cookingController.isCookingInProgress ? "Cooking..." : "Start Cooking")
                                            : "Connect Bluetooth",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                          )
                      ],
                    ),
                  ),
                ))
          ])
        ]));
  }



  void _editFoodItem() {
    if (widget.foodItem != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewDetailsPage(
            foodItem: widget.foodItem,
            isEditing: true,
          ),
        ),
      );
    }
  }

  void _deleteFoodItem() {
    if (widget.foodItem != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Food Item'),
            content: Text('Are you sure you want to delete "${widget.foodItem!.name}"?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Delete the food item using FoodProvider
                  final foodProvider = Provider.of<FoodProvider>(context, listen: false);
                  await foodProvider.deleteFoodItem(widget.foodItem!.id);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Food item deleted successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          );
        },
      );
    }
  }

  // Start cooking function
  Future<void> _startCooking() async {
    if (cookingController.isCookingInProgress) {
      // If already cooking, show pause/resume options
      _showCookingControlDialog();
      return;
    }

    // Create FoodItem with current settings
    FoodItem foodItem = FoodItem(
      id: widget.foodItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: widget.foodName,
      imagePath: widget.imgPath,
      temperature: temperature,
      time: time,
      steam: steam,
      createdAt: widget.foodItem?.createdAt ?? DateTime.now(),
    );

    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Start Cooking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to start cooking "${widget.foodName}"?'),
              SizedBox(height: 15),
              Text('Settings:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Temperature: $temperature°C'),
              Text('• Time: $time minutes'),
              Text('• Steam: ${steam == 0 ? "Off" : steam == 1 ? "Medium" : "High"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Start Cooking'),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Start cooking
      bool success = await cookingController.startCooking(foodItem);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start cooking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show cooking control dialog
  void _showCookingControlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cooking Control'),
          content: Text('What would you like to do?'),
          actions: [
            if (cookingController.isCookingPaused) ...[
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await cookingController.resumeCooking();
                },
                child: Text('Resume'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ] else ...[
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await cookingController.pauseCooking();
                },
                child: Text('Pause'),
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
              ),
            ],
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await cookingController.stopCooking();
              },
              child: Text('Stop'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show connection dialog
  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bluetooth Required'),
          content: Text('Please connect to a Bluetooth device to start cooking.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to Bluetooth page
                Navigator.pushNamed(context, '/bluetooth');
              },
              child: Text('Connect'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ],
        );
      },
    );
  }

}
