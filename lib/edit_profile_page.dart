// edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

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
            _nameController.text = userDoc['name'] ?? "";
            _emailController.text = userDoc['email'] ?? "";
            _mobileController.text = userDoc['mobile'] ?? "";
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

  Future<void> _saveUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'mobile': _mobileController.text,
        });
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Edit Profile'), backgroundColor: Color(0xFF0096C8)),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
                radius: 50,
                backgroundImage:
                    AssetImage('assets/profile_picture.jpg')), // Reduced size
            SizedBox(height: 16),
            _buildTextField('Name', _nameController),
            SizedBox(height: 16),
            _buildTextField('Email', _emailController),
            SizedBox(height: 16),
            _buildTextField('Mobile Number', _mobileController),
            SizedBox(height: 32),
            ElevatedButton(onPressed: _saveUserData, child: Text('Save')),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()));
  }
}
