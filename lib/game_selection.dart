import 'package:flutter/material.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Selection'),
      ),
      body: const Center(
        child: Text('Game Selection Screen'),
      ),
    );
  }
}