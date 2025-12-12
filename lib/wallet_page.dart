import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
        backgroundColor: Color(0xFF0096C8),
      ),
      body: Center(
        child: Text(
          'This is the Wallet page.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
