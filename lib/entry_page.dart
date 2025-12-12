import 'package:flutter/material.dart';
import 'content_page.dart'; // Import the content page

class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ContentPage()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF2196F3), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 250,
                  width: 250,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.asset('assets/sharing.png',
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.95,
                  fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }
}
