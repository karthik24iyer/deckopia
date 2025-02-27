import 'package:deckopia/models/card_models.dart';
import 'package:deckopia/models/playing_card.dart';
import 'package:deckopia/util/snap_area.dart';
import 'package:deckopia/config/snap_area_config.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final _random = math.Random();
  late List<PlayingCardModel> deckCards;
  final Map<String, Offset> initialPositions = {};
  final Map<String, double> initialRotations = {};
  late List<String> cardOrder;

  @override
  void initState() {
    super.initState();
    // Generate all cards
    deckCards = PlayingCardModel.generateDeck(includeJokers: false);
    // Shuffle the deck
    _shuffleDeck();
    // Initialize card order with all card IDs
    cardOrder = deckCards.map((card) => card.id).toList();
  }

  void _shuffleDeck() {
    deckCards.shuffle(_random);
  }

  void _bringCardToFront(String cardId) {
    setState(() {
      cardOrder.remove(cardId);
      cardOrder.add(cardId);
    });
  }

  Offset _getStackedPosition(SnapAreaConfig snapArea, Size cardSize, int index) {
    // Stack cards with a small offset
    const stackOffset = 0.0; // Offset in pixels for each card

    // Calculate center position within snap area
    final centerX = snapArea.position.dx + (snapArea.size.width - cardSize.width) / 2;
    final centerY = snapArea.position.dy + (snapArea.size.height - cardSize.height) / 2;

    return Offset(
      centerX + (stackOffset * index),
      centerY + (stackOffset * index),
    );
  }

  double _getRandomRotation() {
    // Smaller rotation range for stacked cards
    return (_random.nextDouble() - 0.5) * 2 * (math.pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Constants for layout
          const horizontalPadding = 20.0;
          const verticalPadding = 50.0;
          const centerSpacing = 80.0; // Space between top areas

          // Calculate sizes
          final upperSnapAreaWidth = (constraints.maxWidth - (2 * horizontalPadding) - centerSpacing) / 2;
          final upperSnapAreaHeight = constraints.maxHeight * 0.3;
          final lowerSnapAreaWidth = constraints.maxWidth * 0.9;
          final lowerSnapAreaHeight = constraints.maxHeight * 0.3;
          final cardSize = Size(160.0, 200.0 * 1.4981);

          // Upper left snap area
          final topLeftArea = SnapAreaConfig(
            size: Size(upperSnapAreaWidth, upperSnapAreaHeight),
            position: Offset(
              horizontalPadding,
              verticalPadding,
            ),
          );

          // Upper right snap area
          final topRightArea = SnapAreaConfig(
            size: Size(upperSnapAreaWidth, upperSnapAreaHeight),
            position: Offset(
              horizontalPadding + upperSnapAreaWidth + centerSpacing,
              verticalPadding,
            ),
          );

          // Bottom area
          final bottomArea = SnapAreaConfig(
            size: Size(lowerSnapAreaWidth, lowerSnapAreaHeight),
            position: Offset(
              (constraints.maxWidth - lowerSnapAreaWidth) / 2,
              constraints.maxHeight - lowerSnapAreaHeight - verticalPadding,
            ),
          );

          // Initialize positions for all cards in the top left area
          for (var i = 0; i < deckCards.length; i++) {
            var card = deckCards[i];
            initialPositions[card.id] = _getStackedPosition(topLeftArea, cardSize, i);
            initialRotations[card.id] = _getRandomRotation();
          }

          return Stack(
            children: [
              // Background color or pattern if needed
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    opacity: 0.8,
                    image: AssetImage('assets/images/table.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Snap Areas
              SnapArea(
                config: topLeftArea,
                label: '',
              ),
              SnapArea(
                config: topRightArea,
                label: '',
              ),
              SnapArea(
                config: bottomArea,
                label: '',
              ),

              // Cards
              ...cardOrder.map((cardId) {
                final card = deckCards.firstWhere((c) => c.id == cardId);
                final cardMap = card.toMap();

                return PlayingCard(
                  key: ValueKey(cardId),
                  suit: cardMap['suit']!,
                  rank: cardMap['rank']!,
                  snapAreas: [topLeftArea, topRightArea, bottomArea],
                  initialSnapAreaIndex: 0,
                  onDragStart: () => _bringCardToFront(cardId),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}