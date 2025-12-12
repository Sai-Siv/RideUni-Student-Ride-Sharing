import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVehiclePage extends StatefulWidget {
  @override
  _AddVehiclePageState createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _numberOfSeatsController = TextEditingController();

  Future<void> _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userId = user.uid;

          // Add vehicle data to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('vehicles')
              .add({
            'vehicleName': _vehicleNameController.text,
            'vehicleType': _vehicleTypeController.text,
            'registrationNumber': _registrationNumberController.text,
            'numberOfSeats': int.tryParse(_numberOfSeatsController.text) ?? 0,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Clear the form
          _vehicleNameController.clear();
          _vehicleTypeController.clear();
          _registrationNumberController.clear();
          _numberOfSeatsController.clear();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vehicle added successfully!')),
          );

          // Navigate back to the previous page
          Navigator.of(context).pop();
        }
      } catch (e) {
        print("Error adding vehicle: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add vehicle. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set entire page background to white
      appBar: AppBar(
        backgroundColor: Color(0xFF0096C8), // Blue app bar
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // Back button color
        title: Text(
          'Add Vehicle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Image Section
              Container(
                height: 200, // Increased size
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white, // Changed to white
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 50, color: Colors.grey), // Increased size
                      SizedBox(height: 8),
                      Text(
                        'Add vehicle image',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18), // Increased font size
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Form Section
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vehicle Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    buildTextField(
                        _vehicleNameController, 'Enter Vehicle Name'),
                    SizedBox(height: 16),
                    Text(
                      "Vehicle Type",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    buildTextField(
                        _vehicleTypeController, 'Enter Vehicle Type'),
                    SizedBox(height: 16),
                    Text(
                      "Registration Number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    buildTextField(_registrationNumberController,
                        'Enter Registration Number'),
                    SizedBox(height: 16),
                    Text(
                      "Number of Seats Offered",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    buildTextField(
                        _numberOfSeatsController, 'Enter Number of Seats',
                        keyboardType: TextInputType.number),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // White background for the bottom bar
        elevation: 0, // Remove shadow if needed
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0096C8), // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0, // Remove shadow if needed
            ),
            onPressed: _addVehicle,
            child: Text(
              'Add',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          return null;
        },
      ),
    );
  }
}
