import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_vehicle_page.dart'; // Import the new page

class MyVehiclePage extends StatefulWidget {
  @override
  _MyVehiclePageState createState() => _MyVehiclePageState();
}

class _MyVehiclePageState extends State<MyVehiclePage> {
  Future<void> _deleteVehicle(String vehicleId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        // Delete the vehicle document from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('vehicles')
            .doc(vehicleId)
            .delete();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle deleted successfully!')),
        );
      }
    } catch (e) {
      print("Error deleting vehicle: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete vehicle. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Match the background color
      appBar: AppBar(
        title: Text(
          'My vehicle',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color(0xFF0096C8), // Match the app bar color
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black), // Back button color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('vehicles')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No vehicles added yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final vehicles = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final vehicleId = vehicle.id; // Get the document ID for deletion

              return Card(
                color: Colors
                    .white, // Set the background color of the card to white
                margin: EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/car1.png', // Use the local asset
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle['vehicleName'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${vehicle['vehicleType']} |  ${vehicle['registrationNumber']}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                                Text(
                                  '${vehicle['numberOfSeats']} seat',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteVehicle(vehicleId),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddVehiclePage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVehiclePage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF0096C8), // Match the FAB color
      ),
    );
  }
}
