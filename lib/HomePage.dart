import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Bluetooth_connection.dart';
import 'detailsPage.dart';

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
                            bluetoothController.isBluetoothConnected 
                                ? Icons.bluetooth_connected 
                                : Icons.bluetooth_disabled,
                            color: bluetoothController.isBluetoothConnected 
                                ? Colors.green 
                                : Colors.red,
                          ),
                          onPressed: () {
                            if (bluetoothController.isBluetoothConnected) {
                              _showDisconnectDialog();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Bluetooth is not connected'),
                                  backgroundColor: Colors.red,
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
                        child: ListView(children: [
                          _buildFoodItem('assets/images/plate1.png', 'Salmon bowl', '\$24.00', 0),
                          _buildFoodItem('assets/images/plate2.png', 'Spring bowl', '\$22.00', 1),
                          _buildFoodItem('assets/images/plate6.png', 'Avocado bowl', '\$26.00', 2),
                          _buildFoodItem('assets/images/plate5.png', 'Berry bowl', '\$24.00', 3),
                          _buildFoodItem('assets/images/plate1.png', 'Salmon bowl', '\$24.00', 4),
                          _buildFoodItem('assets/images/plate2.png', 'Spring bowl', '\$22.00', 5),
                          _buildFoodItem('assets/images/plate1.png', 'Salmon bowl', '\$24.00', 6),
                          _buildFoodItem('assets/images/plate2.png', 'Spring bowl', '\$22.00', 7),
                          _buildFoodItem('assets/images/plate6.png', 'Avocado bowl', '\$26.00', 8),
                          _buildFoodItem('assets/images/plate5.png', 'Berry bowl', '\$24.00', 9),
                        ]))),
                    Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    
                    Container(
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
                                  fontSize: 24.0))),
                    )
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
          content: Text('Do you want to disconnect from ${bluetoothController.connectedDevice?.name ?? "the device"}?'),
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

  Widget _buildFoodItem(String imgPath, String foodName, String price, int index) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => DetailsPage(
                  imgPath: imgPath,
                  foodName: foodName,
                  price: price,
                  index: index,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  
                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  
                  var offsetAnimation = animation.drive(tween);
                  
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 500),
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
                      tag: '$imgPath-$index',
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
                        Text(
                          price,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15.0,
                            color: Colors.grey
                          )
                        )
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
}
