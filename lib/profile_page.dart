import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'my_rides_page.dart';
import 'wallet_page.dart';
import 'edit_profile_page.dart';
import 'profile/my_vehicle_page.dart';
import 'profile/ride_history_page.dart';
import 'profile/terms_conditions_page.dart';
import 'profile/privacy_policy_page.dart';
import 'profile/language_page.dart';
import 'profile/customer_support_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  String _name = "Loading...";
  String _email = "Loading...";
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _name = userDoc['name'] ?? "Name not found";
            _email = userDoc['email'] ?? "Email not found";
            _nameController.text = _name;
            _emailController.text = _email;
          });
        } else {
          print("User document does not exist");
        }
      } else {
        print("No user is logged in");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyRidesPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => WalletPage()));
        break;
      case 3:
        break;
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditProfilePage()));
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
          context, '/login'); // Replace with your login route
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0096C8),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile_picture.jpg'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _email,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: _navigateToEditProfile,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileOption('My vehicle', Icons.directions_car),
                  SizedBox(height: 8),
                  _buildProfileOption('Ride history', Icons.history),
                  SizedBox(height: 8),
                  _buildProfileOption('Terms & Conditions', Icons.description),
                  SizedBox(height: 8),
                  _buildProfileOption('Privacy Policy', Icons.privacy_tip),
                  SizedBox(height: 8),
                  _buildProfileOption('Language', Icons.language),
                  SizedBox(height: 8),
                  _buildProfileOption('Customer Support', Icons.support),
                  SizedBox(height: 8),
                  _buildProfileOption('Logout', Icons.logout, isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_car), label: 'My Rides'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0096C8),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon,
      {bool isLogout = false}) {
    return ListTile(
      leading: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: isLogout ? Colors.red : Color(0xFF0096C8),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        switch (title) {
          case 'My vehicle':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyVehiclePage()),
            );
            break;
          case 'Ride history':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RideHistoryPage()),
            );
            break;
          case 'Terms & Conditions':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TermsConditionsPage()),
            );
            break;
          case 'Privacy Policy':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
            );
            break;
          case 'Language':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LanguagePage()),
            );
            break;
          case 'Customer Support':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerSupportPage()),
            );
            break;
          case 'Logout':
            _handleLogout();
            break;
        }
      },
    );
  }
}
