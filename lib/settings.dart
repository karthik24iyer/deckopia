import 'package:deckopia/util/flip_card.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: FlipCard(
          front: Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '♠️ A',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),
          back: Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '🂠',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}