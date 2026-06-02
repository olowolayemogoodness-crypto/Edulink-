import 'package:flutter/material.dart';

class CameraScanPage extends StatelessWidget {
  const CameraScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(child: Text('Camera Scan — step 9')),
    );
  }
}