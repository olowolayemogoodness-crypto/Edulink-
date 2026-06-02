import 'package:flutter/material.dart';
class FlashcardsPage extends StatelessWidget {
  const FlashcardsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(child: Text('Flashcards - step 5')));
  }
}
