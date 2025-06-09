import 'package:flutter/material.dart';
import 'package:deckopia/models/sketchy_dropdown_button.dart';
import 'package:deckopia/util/config_provider.dart';

class PlayerDeckControls extends StatelessWidget {
  final int players;
  final int decks;
  final List<int> playerOptions;
  final List<int> deckOptions;
  final Function(int?) onPlayersChanged;
  final Function(int?) onDecksChanged;

  const PlayerDeckControls({
    super.key,
    required this.players,
    required this.decks,
    required this.playerOptions,
    required this.deckOptions,
    required this.onPlayersChanged,
    required this.onDecksChanged,
  });

  @override
  Widget build(BuildContext context) {
    final layoutConfig = context.layoutConfig;
    
    return Column(
      children: [
        // Players Row
        Row(
          children: [
            Text(
              'Players',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'CaveatBrush',
              ),
            ),
            const Spacer(),
            SketchyDropdownButton<int>(
              width: layoutConfig.ui.boxWidth,
              height: layoutConfig.ui.boxHeight,
              menuWidth: layoutConfig.ui.menuWidth,
              value: players,
              seed: 10,
              fontFamily: 'CaveatBrush',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'CaveatBrush',
              ),
              onChanged: onPlayersChanged,
              items: playerOptions.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  alignment: Alignment.center,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Decks Row
        Row(
          children: [
            Text(
              'Decks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'CaveatBrush',
              ),
            ),
            const Spacer(),
            SketchyDropdownButton<int>(
              width: layoutConfig.ui.boxWidth,
              height: layoutConfig.ui.boxHeight,
              menuWidth: layoutConfig.ui.menuWidth,
              value: decks,
              seed: 20,
              fontFamily: 'CaveatBrush',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'CaveatBrush',
              ),
              onChanged: onDecksChanged,
              items: deckOptions.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  alignment: Alignment.center,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
