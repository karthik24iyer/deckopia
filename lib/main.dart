import 'package:deckopia/profile.dart';
import 'package:deckopia/settings.dart';
import 'package:flutter/material.dart';

import 'game_builder.dart';
import 'game_selection.dart';
import 'homepage.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Game App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/game-selection': (context) => const GameSelectionScreen(),
        '/game-builder': (context) => const GameBuilderScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}