import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'Bluetooth_connection.dart';
import 'BluetoothPage.dart';
import 'detailsPage.dart';
import 'NewDetailsPage.dart';
import 'models/food_item.dart';
import 'providers/food_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BluetoothController bluetoothController = Get.find<BluetoothController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF58C4C6),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Container(
                    width: 125.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Bluetooth status indicator
                        Obx(() => IconButton(
                          icon: Icon(
                            bluetoothController.isConnected.value 
                                ? Icons.bluetooth_connected 
                                : Icons.bluetooth_disabled,
                            color: bluetoothController.isConnected.value 
                                ? Colors.green 
                                : Colors.red,
                          ),
                          onPressed: () {
                            if (bluetoothController.isConnected.value) {
                              _showDisconnectDialog();
                            } else {
                              // Navigate to Bluetooth page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BluetoothPage(),
                                ),
                              );
                            }
                          },
                        )),
                        IconButton(
                          icon: Icon(Icons.menu),
                          color: Colors.white,
                          onPressed: () {},
                        )
                      ],
                    ))
              ],
            ),
          ),
          SizedBox(height: 25.0),
          Padding(
            padding: EdgeInsets.only(left: 40.0),
            child: Row(
              children: <Widget>[
                Text('ELARABY',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0)),
                SizedBox(width: 10.0),
                Text('Food',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 25.0))
              ],
            ),
          ),
          SizedBox(height: 40.0),
          Container(
            height: MediaQuery.of(context).size.height - 185.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
            ),
            child: ListView(
              primary: false,
              padding: EdgeInsets.only(left: 25.0, right: 20.0),
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 45.0),
                    child: Container(
                        height: MediaQuery.of(context).size.height - 300.0,
                        child: ListView(                        children: [
                          // Original dishes
                          _buildOriginalFoodItem('assets/images/plate1.png', 'Salmon bowl'),
                          _buildOriginalFoodItem('assets/images/plate2.png', 'Spring bowl'),
                          _buildOriginalFoodItem('assets/images/plate6.png', 'Avocado bowl'),
                          _buildOriginalFoodItem('assets/images/plate5.png', 'Berry bowl'),
                          _buildOriginalFoodItem('assets/images/plate1.png', 'Salmon bowl'),
                          _buildOriginalFoodItem('assets/images/plate2.png', 'Spring bowl'),
                          _buildOriginalFoodItem('assets/images/plate1.png', 'Salmon bowl'),
                          _buildOriginalFoodItem('assets/images/plate2.png', 'Spring bowl'),
                          _buildOriginalFoodItem('assets/images/plate6.png', 'Avocado bowl'),
                          _buildOriginalFoodItem('assets/images/plate5.png', 'Berry bowl'),
                          
                          // Divider
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Text(
                                    'Custom Items',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Custom food items
                          Consumer<FoodProvider>(
                            builder: (context, foodProvider, child) {
                              if (foodProvider.foodItems.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 15),
                                        Text(
                                          'No custom items yet',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add your own food items using the New button',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            fontFamily: 'Montserrat',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              
                              return Column(
                                children: foodProvider.foodItems.map((foodItem) {
                                  return _buildFoodItem(foodItem);
                                }).toList(),
                              );
                            },
                          ),
                        ]))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                    
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewDetailsPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 65.0,
                        width: 120.0,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                                width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                            color:Colors.black),
                        child: Center(
                            child: Text('New',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontSize: 24.0)))),
                      ),
                      ],
                    )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Disconnect Bluetooth'),
          content: Text('Do you want to disconnect from ${bluetoothController.connectedDeviceName.value}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await bluetoothController.disconnect();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bluetooth disconnected'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: Text('Disconnect'),
            ),
          ],
        );
      },
    );
  }

  void _editFoodItem(FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewDetailsPage(
          foodItem: foodItem,
          isEditing: true,
        ),
      ),
    );
  }

  void _deleteFoodItem(FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Food Item'),
          content: Text('Are you sure you want to delete "${foodItem.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final foodProvider = Provider.of<FoodProvider>(context, listen: false);
                await foodProvider.deleteFoodItem(foodItem.id);
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

  Widget _buildOriginalFoodItem(String imgPath, String foodName) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  imgPath: imgPath,
                  foodName: foodName,
                  foodItem: null, // Original items don't have FoodItem
                ),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Row(
                  children: [
                    Hero(
                      tag: '$imgPath',
                      child: Image(
                        image: AssetImage(imgPath),
                        fit: BoxFit.cover,
                        height: 75.0,
                        width: 75.0
                      )
                    ),
                    SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          foodName,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold
                          )
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Original Recipe',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ]
                    )
                  ]
                )
              ),
              IconButton(
                icon: Icon(Icons.add),
                color: Colors.black,
                onPressed: () {}
              )
            ],
          )
        ));
  }

  Widget _buildFoodItem(FoodItem foodItem) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(
                          imgPath: foodItem.imagePath,
                          foodName: foodItem.name,
                          foodItem: foodItem,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Hero(
                          tag: '${foodItem.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.file(
                                File(foodItem.imagePath),
                                fit: BoxFit.cover,
                                height: 75.0,
                                width: 75.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(
                                foodItem.name,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                '${foodItem.temperature}°C • ${foodItem.time}min • Steam: ${foodItem.steam}',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
              ),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Color(0xFF7A9BEE)),
                    onPressed: () => _editFoodItem(foodItem),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFoodItem(foodItem),
                  ),
                ],
              ),
            ],
          )
        ));
  }
}
