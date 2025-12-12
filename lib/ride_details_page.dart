import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideDetailsPage extends StatefulWidget {
  final String from;
  final String to;
  final String dateTime;
  final double pricePerSeat;

  const RideDetailsPage({
    super.key,
    required this.from,
    required this.to,
    required this.dateTime,
    required this.pricePerSeat,
  });

  @override
  _RideDetailsPageState createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  final facilitiesController = TextEditingController();
  final instructionsController = TextEditingController();
  String? selectedSeats;
  String? selectedVehicle;
  List<Map<String, dynamic>> userVehicles = [];
  bool isLoadingVehicles = true;

  @override
  void initState() {
    super.initState();
    _fetchUserVehicles();
  }

  Future<void> _fetchUserVehicles() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoadingVehicles = false;
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vehicles')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        userVehicles = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'vehicleName': doc['vehicleName'],
            'vehicleType': doc['vehicleType'],
            'registrationNumber': doc['registrationNumber'],
            'numberOfSeats': doc['numberOfSeats'],
          };
        }).toList();
        isLoadingVehicles = false;
      });
    } catch (e) {
      print("Error fetching vehicles: $e");
      setState(() {
        isLoadingVehicles = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching vehicles: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offer Ride',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0096C8),
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildLocationSelector(),
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel('Available Seats'),
            _buildSeatsDropdown(),
            const SizedBox(height: 20),
            _buildLabel('Your Car'),
            _buildVehicleDropdown(),
            const SizedBox(height: 20),
            _buildLabel('Facility'),
            _buildLargeTextField(
              'e.g. Ac, Music etc',
              facilitiesController,
            ),
            const SizedBox(height: 20),
            _buildLabel('Instructions'),
            _buildLargeTextField(
              'e.g. No smoking or no pets allowed',
              instructionsController,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0096C8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Stack(
      children: [
        Positioned(
          left: 14,
          top: 30,
          bottom: 30,
          child: CustomPaint(
            size: const Size(2, 120),
            painter: DashedLinePainter(),
          ),
        ),
        Column(
          children: [
            _buildLocationField('From', Colors.green, Icons.circle),
            const SizedBox(height: 40),
            _buildLocationField('To', Colors.red, Icons.location_on),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationField(String label, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                label == 'From' ? widget.from : widget.to,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSeatsDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedSeats,
        hint: const Text('No. of seats'),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        underline: const SizedBox(),
        items: List.generate(7, (index) {
          return DropdownMenuItem<String>(
            value: '${index + 1} seat${index + 1 > 1 ? 's' : ''}',
            child: Text('${index + 1} seat${index + 1 > 1 ? 's' : ''}'),
          );
        }),
        onChanged: (String? value) {
          setState(() {
            selectedSeats = value;
          });
        },
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoadingVehicles
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          : userVehicles.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                      'No vehicles available. Please add a vehicle first.'),
                )
              : DropdownButton<String>(
                  value: selectedVehicle,
                  hint: const Text('Select your vehicle'),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  underline: const SizedBox(),
                  items: userVehicles.map<DropdownMenuItem<String>>((vehicle) {
                    return DropdownMenuItem<String>(
                      value: vehicle['id'],
                      child: Text(
                        '${vehicle['vehicleName']} (${vehicle['registrationNumber']})',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedVehicle = value;
                    });
                  },
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
    );
  }

  Widget _buildLargeTextField(
      String hintText, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _createRide() async {
    if (selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    if (selectedSeats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select number of seats')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    // Get the user document reference
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final selectedVehicleData = userVehicles.firstWhere(
      (v) => v['id'] == selectedVehicle,
    );

    final rideData = {
      'driverId': user.uid, // Store the document reference instead of email
      'from': widget.from,
      'to': widget.to,
      'dateTime': widget.dateTime,
      'pricePerSeat': widget.pricePerSeat,
      'availableSeats': int.parse(selectedSeats!.split(' ')[0]),
      'vehicleId': selectedVehicle,
      'vehicleName': selectedVehicleData['vehicleName'],
      'vehicleType': selectedVehicleData['vehicleType'],
      'registrationNumber': selectedVehicleData['registrationNumber'],
      'numberOfSeats': selectedVehicleData['numberOfSeats'],
      'facilities': facilitiesController.text,
      'instructions': instructionsController.text,
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance.collection('rides').add(rideData);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating ride: $e')),
        );
      }
    }
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dashWidth = 3;
    final dashSpace = 2;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
