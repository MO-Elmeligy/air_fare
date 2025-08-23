import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NewDetailsPage extends StatefulWidget {
  const NewDetailsPage({Key? key}) : super(key: key);

  @override
  _NewDetailsPageState createState() => _NewDetailsPageState();
}

class _NewDetailsPageState extends State<NewDetailsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Variables for user input
  String foodName = '';
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  // Control variables
  int temperature = 175;
  int time = 30;
  int steam = 1;
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void _saveDetails() {
    if (foodName.isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and select an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Here you can save the data or navigate back with the new details
    Navigator.pop(context, {
      'name': foodName,
      'image': selectedImage!.path,
      'temperature': temperature,
      'time': time,
      'steam': steam,
    });
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
        title: Text('Add New Food',
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18.0,
                color: Colors.white)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDetails,
            color: Colors.white,
          )
        ],
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 82.0,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent
              ),
              Positioned(
                top: 75.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45.0),
                      topRight: Radius.circular(45.0),
                    ),
                    color: Colors.white
                  ),
                  height: MediaQuery.of(context).size.height - 100.0,
                  width: MediaQuery.of(context).size.width
                )
              ),
              Positioned(
                top: 30.0,
                left: (MediaQuery.of(context).size.width / 2) - 100.0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Color(0xFF7A9BEE), width: 3.0),
                    ),
                    height: 200.0,
                    width: 200.0,
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(17.0),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 60,
                                color: Color(0xFF7A9BEE),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Tap to add image',
                                style: TextStyle(
                                  color: Color(0xFF7A9BEE),
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                )
              ),
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
                        // Food Name Input
                        TextField(
                          controller: _nameController,
                          onChanged: (value) {
                            setState(() {
                              foodName = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Food Name',
                            labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color(0xFF7A9BEE), width: 2.0),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        SizedBox(height: 30.0),
                        
                        // Control Sliders
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                            ],
                          ),
                        ),
                        SizedBox(height: 30.0),
                        
                        // Save Button
                        Container(
                          width: double.infinity,
                          height: 50.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Color(0xFF7A9BEE),
                          ),
                          child: ElevatedButton(
                            onPressed: _saveDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            child: Text(
                              'Save Food Item',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              )
            ]
          )
        ]
      )
    );
  }
}
