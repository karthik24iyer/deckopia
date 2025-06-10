import 'package:deckopia/models/card_models.dart';
import 'package:deckopia/models/playing_card.dart';
import 'package:deckopia/util/snap_area.dart';
import 'package:deckopia/config/snap_area_config.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:deckopia/util/card_config_adapter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final _random = math.Random();
  List<PlayingCardModel> deckCards = [];
  final Map<String, Offset> initialPositions = {};
  final Map<String, double> initialRotations = {};
  List<String> cardOrder = [];
  String? currentlyDraggingCard; // Track which card is being dragged
  List<String> bottomAreaCards = []; // Track cards in bottom area

  @override
  void initState() {
    super.initState();
    // Generate all cards - we'll initialize them after config is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Generate deck with configuration if not already done
    if (deckCards.isEmpty) {
      // Defer heavy operations to next frame to avoid blocking initial render
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            deckCards = PlayingCardModel.generateDeck(
              includeJokers: false,
              deckConfig: context.deckConfig,
            );
            // Shuffle the deck
            _shuffleDeck();
            // Initialize card order with all card IDs
            cardOrder = deckCards.map((card) => card.id).toList();
          });
        }
      });
    }
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

  void _startDragging(String cardId) {
    setState(() {
      currentlyDraggingCard = cardId;
    });
  }

  void _stopDragging() {
    setState(() {
      currentlyDraggingCard = null;
    });
  }

  // Get card order with currently dragging card on top
  List<String> get _renderOrder {
    if (currentlyDraggingCard != null) {
      List<String> tempOrder = List.from(cardOrder);
      tempOrder.remove(currentlyDraggingCard);
      tempOrder.add(currentlyDraggingCard!);
      return tempOrder;
    }
    return cardOrder;
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
  
  int _getBottomAreaCardCount() {
    return bottomAreaCards.length;
  }
  
  void _updateBottomAreaCards(String cardId, int? snapAreaIndex) {
    setState(() {
      // Remove card from bottom area list if it was there
      bottomAreaCards.remove(cardId);
      
      // Add card to bottom area if it snapped there
      if (snapAreaIndex == 2) {
        bottomAreaCards.add(cardId);
      }
    });
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

              // Cards (with dragging card on top)
              ..._renderOrder.map((cardId) {
                final card = deckCards.firstWhere((c) => c.id == cardId);
                final cardMap = card.toMap();
                final cardIndex = deckCards.indexOf(card);

                return PlayingCard(
                  key: ValueKey(cardId),
                  cardId: cardId,
                  suit: cardMap['suit']!,
                  rank: cardMap['rank']!,
                  renderConfig: CardConfigAdapter.createRenderConfig(
                    context, 
                    cardMap['suit']!, 
                    cardMap['rank']!
                  ),
                  snapBehavior: CardConfigAdapter.createSnapBehavior(
                    [topLeftArea, topRightArea, bottomArea],
                    getBottomAreaCardCount: _getBottomAreaCardCount,
                  ),
                  animationBehavior: CardConfigAdapter.createAnimationBehavior(context),
                  initialPosition: CardConfigAdapter.calculateInitialPosition(
                    topLeftArea,
                    Size(
                      context.cardConfig.dimensions.width,
                      context.cardConfig.dimensions.width * context.cardConfig.dimensions.aspectRatio
                    ),
                    cardIndex,
                    context.config.board.stackOffset,
                  ),
                  initiallyFaceUp: false,
                  callbacks: CardConfigAdapter.createCallbacks(
                    onSnapToArea: (snapAreaIndex) {
                      _updateBottomAreaCards(cardId, snapAreaIndex);
                      _bringCardToFront(cardId);
                    },
                    onDragStart: () => _startDragging(cardId),
                    onDragEnd: () => _stopDragging(),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}