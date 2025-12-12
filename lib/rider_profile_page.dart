import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ride_confirmation_page.dart';

class RiderProfilePage extends StatelessWidget {
  final Map<String, dynamic> ride;

  const RiderProfilePage({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(ride['dateTime']));
    final formattedTime =
        DateFormat('h:mm a').format(DateTime.parse(ride['dateTime']));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: const Color(0xFF0096C8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(bottom: 100), // Add padding for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCard(
                  child: _buildDriverProfile(context),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  child: _buildRideInfo(formattedDate, formattedTime),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  child: _buildVehicleInfo(),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  child: _buildReviewsSection(),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  // Get the current user's ID (you'll need to implement this based on your auth system)
                  final currentUserId = FirebaseAuth
                      .instance.currentUser?.uid; // Replace with actual user ID

                  // Create a new ride request document
                  await FirebaseFirestore.instance
                      .collection('ride_requests')
                      .add({
                    'rideId': ride['id'],
                    'driverId': ride['driverId'],
                    'riderId': currentUserId, // Add the rider's ID
                    'driverName': ride['driverName'],
                    'driverImage': ride['driverImage'],
                    'from': ride['from'],
                    'to': ride['to'],
                    'dateTime': ride['dateTime'],
                    'availableSeats': ride['availableSeats'],
                    'pricePerSeat': ride['pricePerSeat'],
                    'vehicleName': ride['vehicleName'],
                    'vehicleType': ride['vehicleType'],
                    'registrationNumber': ride['registrationNumber'],
                    'requestStatus': 'pending', // pending, accepted, rejected
                    'requestTimestamp': FieldValue.serverTimestamp(),
                    'facilities': ride['facilities'],
                    'instructions': ride['instructions'],
                  });

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ride request sent successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to confirmation page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideConfirmationPage(),
                    ),
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sending ride request: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0096C8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Request Ride',
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
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildDriverProfile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Driver Profile'),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(ride['driverImage']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride['driverName'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < ride['rating'] ? Icons.star : Icons.star_border,
                        size: 20,
                        color: Colors.amber,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRideInfo(String date, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Ride Information'),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.location_on,
          iconColor: Colors.green,
          title: 'From',
          value: ride['from'],
        ),
        _divider(),
        _buildInfoRow(
          icon: Icons.location_on,
          iconColor: Colors.red,
          title: 'To',
          value: ride['to'],
        ),
        _divider(),
        _buildInfoRow(
          icon: Icons.calendar_today,
          title: 'Date & Time',
          value: '$date at $time',
        ),
        _divider(),
        _buildInfoRow(
          icon: Icons.event_seat,
          title: 'Available Seats',
          value: ride['availableSeats'].toString(),
        ),
        _divider(),
        _buildInfoRow(
          icon: Icons.attach_money,
          title: 'Price per Seat',
          value: '\$${ride['pricePerSeat']}',
        ),
      ],
    );
  }

  Widget _buildVehicleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Vehicle Information'),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.directions_car,
          title: 'Vehicle',
          value: '${ride['vehicleName']} (${ride['vehicleType']})',
        ),
        _divider(),
        _buildInfoRow(
          icon: Icons.confirmation_number,
          title: 'Registration',
          value: ride['registrationNumber'],
        ),
        if (ride['facilities'] != null && ride['facilities'].isNotEmpty) ...[
          _divider(),
          _buildSectionDetail('Facilities', ride['facilities']),
        ],
        if (ride['instructions'] != null &&
            ride['instructions'].isNotEmpty) ...[
          _divider(),
          _buildSectionDetail('Special Instructions', ride['instructions']),
        ],
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeaderWithButton('Reviews', onViewAll: () {
          // TODO: Navigate to full reviews
        }),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getLatestReviews(ride['driverId']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error loading reviews: ${snapshot.error}');
            } else {
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Text(
                  'No reviews yet',
                  style: TextStyle(color: Colors.grey),
                );
              }
              return Column(
                children: reviews.map((review) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review['reviewerName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              review['date'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review['rating']
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review['comment'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0096C8),
      ),
    );
  }

  Widget _sectionHeaderWithButton(String title,
      {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionHeader(title),
        TextButton(
          onPressed: onViewAll,
          child: const Text(
            'View All',
            style: TextStyle(color: Color(0xFF0096C8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDetail(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(height: 24, color: Colors.grey);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: iconColor ?? Colors.grey[700]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String> _getDriverJoinDate(String driverId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(driverId)
          .get();

      if (doc.exists) {
        final joinDate = doc.data()?['joinDate'];
        if (joinDate != null) {
          final date = DateTime.parse(joinDate);
          return DateFormat('MMM yyyy').format(date);
        }
      }
      return 'Unknown';
    } catch (e) {
      print("Error fetching driver join date: $e");
      return 'Unknown';
    }
  }

  Future<List<Map<String, dynamic>>> _getLatestReviews(String driverId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('driverId', isEqualTo: driverId)
          .orderBy('timestamp', descending: true)
          .limit(2)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'reviewerName': data['reviewerName'] ?? 'Anonymous',
          'comment': data['comment'] ?? '',
          'rating': data['rating'] ?? 5,
          'date': data['timestamp'] != null
              ? DateFormat('MMM d, yyyy')
                  .format((data['timestamp'] as Timestamp).toDate())
              : '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }
}
