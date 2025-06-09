import 'package:deckopia/util/flip_card.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demoConfig = context.layoutConfig.demo;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: FlipCard(
          front: Container(
            width: demoConfig.cardWidth,
            height: demoConfig.cardHeight,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(demoConfig.cardBorderRadius),
            ),
            child: const Center(
              child: Text(
                '♠️ A',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),
          back: Container(
            width: demoConfig.cardWidth,
            height: demoConfig.cardHeight,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(demoConfig.cardBorderRadius),
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