import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_uni/home_screen.dart';
import 'package:ride_uni/login_screen.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  int _currentPage = 0;
  final List<Map<String, String>> _contentList = [
    {
      'title': 'Car pool with people like you',
      'description':
          'Lorem ipsum dolor sit amet consectetur. Aliquet honcus felis non mi ornare pretium nisl vestibulum enim.',
      'image': 'assets/content1.png',
    },
    {
      'title': 'Save money on your daily commute',
      'description':
          'Join the best carpool network and share rides with verified professionals.',
      'image': 'assets/sharing.png',
    },
    {
      'title': 'Eco-friendly way to travel',
      'description':
          'Reduce carbon footprint and contribute to a greener planet by carpooling.',
      'image': 'assets/sharing.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _contentList.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      // Check authentication state before navigating to LoginScreen
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          // User is signed in, navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // User is not signed in, navigate to LoginScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Check authentication state before navigating to LoginScreen
              FirebaseAuth.instance.authStateChanges().listen((User? user) {
                if (user != null) {
                  // User is signed in, navigate to HomeScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  // User is not signed in, navigate to LoginScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              });
            },
            child: Text('Skip',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          Image.asset(
            _contentList[_currentPage]['image']!,
            height: 250,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // Fixed width (90% of screen width)
                height: 300, // Fixed height
                padding: EdgeInsets.all(30),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _contentList[_currentPage]['title']!,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _contentList[_currentPage]['description']!,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _contentList.length,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 20 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.blue
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade300.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          _currentPage == _contentList.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
