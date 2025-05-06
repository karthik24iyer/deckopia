import 'package:deckopia/models/card_models.dart';
import 'package:deckopia/models/playing_card.dart';
import 'package:deckopia/util/snap_area.dart';
import 'package:deckopia/config/snap_area_config.dart';
import 'package:deckopia/util/config_provider.dart';
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
    final stackOffset = context.config.board.stackOffset;

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
    return (_random.nextDouble() - 0.5) * 2 * context.config.board.rotation.maxRadians;
  }

  @override
  Widget build(BuildContext context) {
    final cardConfig = context.cardConfig;
    final boardLayoutConfig = context.layoutConfig.board;
    final boardConfig = context.config.board;
    final backgroundConfig = context.config.background;
    
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Get layout constants from config
          final horizontalPadding = boardLayoutConfig.horizontalPadding;
          final verticalPadding = boardLayoutConfig.verticalPadding;
          final centerSpacing = boardLayoutConfig.centerSpacing;

          // Calculate sizes using factors from config
          final upperSnapAreaWidth = (constraints.maxWidth - (2 * horizontalPadding) - centerSpacing) * boardConfig.snapAreaSizes.upperWidthFactor;
          final upperSnapAreaHeight = constraints.maxHeight * boardConfig.snapAreaSizes.upperHeightFactor;
          final lowerSnapAreaWidth = constraints.maxWidth * boardConfig.snapAreaSizes.lowerWidthFactor;
          final lowerSnapAreaHeight = constraints.maxHeight * boardConfig.snapAreaSizes.lowerHeightFactor;
          final cardSize = Size(
            cardConfig.dimensions.width,
            cardConfig.dimensions.width * cardConfig.dimensions.aspectRatio
          );

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
              // Background color or pattern
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    opacity: backgroundConfig.imageOpacity,
                    image: const AssetImage('assets/images/table.png'),
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