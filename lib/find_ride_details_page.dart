import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'rider_profile_page.dart'; // Import the new rider profile page

class AvailableRidesPage extends StatefulWidget {
  final String from;
  final String to;
  final String dateTime;
  final int requiredSeats;

  const AvailableRidesPage({
    super.key,
    required this.from,
    required this.to,
    required this.dateTime,
    required this.requiredSeats,
  });

  @override
  _AvailableRidesPageState createState() => _AvailableRidesPageState();
}

class _AvailableRidesPageState extends State<AvailableRidesPage> {
  List<Map<String, dynamic>> availableRides = [];
  bool isLoading = true;
  final Map<String, String> _driverNames = {}; // Cache for driver names

  @override
  void initState() {
    super.initState();
    _fetchAvailableRides();
  }

  Future<String> _getDriverName(String driverId) async {
    if (_driverNames.containsKey(driverId)) {
      return _driverNames[driverId]!;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(driverId)
          .get();

      if (doc.exists) {
        final name = doc.data()?['name'] ?? 'Driver';
        _driverNames[driverId] = name;
        return name;
      }
      return 'Driver';
    } catch (e) {
      print("Error fetching driver name: $e");
      return 'Driver';
    }
  }

  Future<void> _fetchAvailableRides() async {
    try {
      // Parse the selected date and time
      final selectedDateTime = DateTime.parse(widget.dateTime);
      final now = DateTime.now();

      // Determine the time window
      DateTime startTime;
      DateTime endTime;

      if (selectedDateTime.isAfter(now)) {
        // For future rides, use ±2 hours around selected time
        startTime = selectedDateTime.subtract(const Duration(hours: 2));
        endTime = selectedDateTime.add(const Duration(hours: 2));
      } else {
        // For current/past time, use current time as center point
        startTime = now.subtract(const Duration(hours: 2));
        endTime = now.add(const Duration(hours: 2));
      }

      // First get all active rides matching from/to
      final querySnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('from', isEqualTo: widget.from)
          .where('to', isEqualTo: widget.to)
          .where('status', isEqualTo: 'active')
          .get();

      // Fetch driver names for all rides
      final ridesWithDriverNames = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();
          final rideDateTime = DateTime.parse(data['dateTime']);
          final hasEnoughSeats = data['availableSeats'] >= widget.requiredSeats;
          final isInTimeWindow =
              rideDateTime.isAfter(startTime) && rideDateTime.isBefore(endTime);

          if (isInTimeWindow && hasEnoughSeats) {
            final driverName = await _getDriverName(data['driverId']);
            return {
              'id': doc.id,
              'driverId': data['driverId'],
              'driverName': driverName,
              'driverImage':
                  data['driverImage'] ?? 'https://via.placeholder.com/150',
              'from': data['from'],
              'to': data['to'],
              'dateTime': data['dateTime'],
              'pricePerSeat': data['pricePerSeat'],
              'availableSeats': data['availableSeats'],
              'vehicleName': data['vehicleName'],
              'vehicleType': data['vehicleType'],
              'registrationNumber': data['registrationNumber'],
              'facilities': data['facilities'],
              'instructions': data['instructions'],
              'totalPrice': (data['pricePerSeat'] * widget.requiredSeats)
                  .toStringAsFixed(2),
              'rating': data['rating'] ?? 5,
            };
          }
          return null;
        }),
      );

      setState(() {
        availableRides =
            ridesWithDriverNames.whereType<Map<String, dynamic>>().toList();

        // Sort rides by closest to selected time
        availableRides.sort((a, b) {
          final aTime = DateTime.parse(a['dateTime']);
          final bTime = DateTime.parse(b['dateTime']);
          final aDiff = (aTime.difference(selectedDateTime).inMinutes.abs());
          final bDiff = (bTime.difference(selectedDateTime).inMinutes.abs());
          return aDiff.compareTo(bDiff);
        });

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching rides: $e");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching rides: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0096C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0096C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Rides on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(widget.dateTime))}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6F9FC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : availableRides.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No rides available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search criteria',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: availableRides.length,
                    itemBuilder: (context, index) {
                      final ride = availableRides[index];
                      final dateTime = DateTime.parse(ride['dateTime']);
                      final formattedDate =
                          DateFormat('dd MMM yyyy').format(dateTime);
                      final formattedTime =
                          DateFormat('hh:mm a').format(dateTime);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RiderProfilePage(ride: ride),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(2, 5),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Row
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        NetworkImage(ride['driverImage']),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              ride['driverName'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified,
                                                size: 16, color: Colors.green),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < ride['rating']
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 16,
                                              color: Colors.amber,
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$formattedDate, $formattedTime",
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "\$${ride['totalPrice']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Pickup and Drop locations
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: const [
                                      Icon(Icons.location_pin,
                                          color: Colors.green, size: 20),
                                      SizedBox(height: 4),
                                      Icon(Icons.location_pin,
                                          color: Colors.red, size: 20),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ride['from'],
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ride['to'],
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Available Seats Display
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Available Seats:',
                                      style: TextStyle(fontSize: 12)),
                                  const SizedBox(height: 4),
                                  // Calculate how many rows we need (4 seats per row)
                                  for (int row = 0;
                                      row < (ride['availableSeats'] / 4).ceil();
                                      row++)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          // Display 4 seats per row
                                          for (int i = 0; i < 4; i++)
                                            if (row * 4 + i <
                                                ride['availableSeats'])
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: Icon(
                                                  Icons.event_seat,
                                                  size: 18,
                                                  color: const Color(
                                                      0xFF0096C8), // Blue for available seats
                                                ),
                                              )
                                            else
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: Icon(
                                                  Icons.event_seat,
                                                  size: 18,
                                                  color: Colors.grey[
                                                      300], // Gray for unavailable seats
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                  Text(
                                    '${ride['availableSeats']} seats available',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
