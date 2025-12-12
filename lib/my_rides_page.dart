import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyRidesPage extends StatefulWidget {
  @override
  _MyRidesPageState createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Rides'),
        backgroundColor: Color(0xFF0096C8),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'My Rides'),
            Tab(text: 'My Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My Rides (Driver-side)
          MyRidesList(),
          // Tab 2: My Requests (Rider-side)
          MyRequestsList(),
        ],
      ),
    );
  }
}

class MyRidesList extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('rides')
          .where('driverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'upcoming')
          .orderBy('dateTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(child: Text('No upcoming rides'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var ride = snapshot.data!.docs[index];
            return RideCard(
              ride: ride,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideRequestsScreen(rideId: ride.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class RideCard extends StatelessWidget {
  final DocumentSnapshot ride;
  final VoidCallback onTap;

  const RideCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(ride['dateTime']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ride['from']} to ${ride['to']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Date: $formattedDate at $formattedTime'),
              Text('Available Seats: ${ride['availableSeats']}'),
              Text('Price per seat: \$${ride['pricePerSeat']}'),
              Text('Facilities: ${ride['facilities']}'),
              SizedBox(height: 8),
              Text(
                'Tap to view requests',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RideRequestsScreen extends StatelessWidget {
  final String rideId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RideRequestsScreen({required this.rideId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Requests'),
        backgroundColor: Color(0xFF0096C8),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('ride_requests')
            .where('rideId', isEqualTo: rideId)
            .orderBy('requestTimestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(child: Text('No requests for this ride'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var request = snapshot.data!.docs[index];
              return RequestCard(request: request);
            },
          );
        },
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final DocumentSnapshot request;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestCard({required this.request});

  Future<void> _updateRequestStatus(String newStatus) async {
    await _firestore.collection('ride_requests').doc(request.id).update({
      'requestStatus': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(request['dateTime']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(request['driverImage']),
                  radius: 24,
                ),
                SizedBox(width: 16),
                Text(
                  request['driverName'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Date: $formattedDate at $formattedTime'),
            Text('From: ${request['from']}'),
            Text('To: ${request['to']}'),
            Text('Seats Requested: ${request['availableSeats']}'),
            Text('Status: ${request['requestStatus']}'),
            if (request['requestStatus'] == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _updateRequestStatus('rejected'),
                    child: Text('Decline', style: TextStyle(color: Colors.red)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateRequestStatus('accepted'),
                    child: Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class MyRequestsList extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;
    final now = DateTime.now();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ride_requests')
          .where('riderId', isEqualTo: currentUserId)
          .orderBy('dateTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(child: Text('No ride requests'));
        }

        // Filter out past rides
        final upcomingRequests = snapshot.data!.docs.where((doc) {
          final rideDate = DateTime.parse(doc['dateTime']);
          return rideDate.isAfter(now);
        }).toList();

        if (upcomingRequests.isEmpty) {
          return Center(child: Text('No upcoming ride requests'));
        }

        return ListView.builder(
          itemCount: upcomingRequests.length,
          itemBuilder: (context, index) {
            var request = upcomingRequests[index];
            return RiderRequestCard(request: request);
          },
        );
      },
    );
  }
}

class RiderRequestCard extends StatelessWidget {
  final DocumentSnapshot request;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RiderRequestCard({required this.request});

  Future<void> _cancelRequest() async {
    await _firestore.collection('ride_requests').doc(request.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(request['dateTime']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    Color statusColor;
    switch (request['requestStatus']) {
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(request['driverImage']),
                  radius: 24,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['driverName'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      request['requestStatus'],
                      style: TextStyle(color: statusColor),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Date: $formattedDate at $formattedTime'),
            Text('From: ${request['from']}'),
            Text('To: ${request['to']}'),
            Text(
                'Vehicle: ${request['vehicleName']} (${request['vehicleType']})'),
            Text('Price per seat: \$${request['pricePerSeat']}'),
            if (request['requestStatus'] == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _cancelRequest,
                    child: Text('Cancel Request',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
