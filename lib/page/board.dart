import 'package:deckopia/models/card_models.dart';
import 'package:deckopia/models/playing_card.dart';
import 'package:deckopia/util/snap_area.dart';
import 'package:deckopia/config/snap_area_config.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:deckopia/models/game_state_manager.dart';
import 'package:deckopia/models/card_snap_behavior.dart';
import 'package:deckopia/models/card_behavior_interfaces.dart';
import 'package:deckopia/models/card_animation_behavior.dart';
import 'package:deckopia/config/snap_behavior_config.dart';
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
  List<String> cardOrder = [];
  String? currentlyDraggingCard;
  
  // Persistent state management
  late GameStateManager gameState;
  late SmartSnapBehavior snapBehavior;
  
  // Snap area configurations (created once)
  late SnapAreaConfig topLeftArea;
  late SnapAreaConfig topRightArea;
  late SnapAreaConfig bottomArea;

  @override
  void initState() {
    super.initState();
    // Initialize with default configuration (30px spacing, no concentric offset)
    gameState = GameStateManager(config: SnapBehaviorConfig.defaultConfig);
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


  
  /// Initialize snap areas and behavior once
  void _initializeSnapAreas(BoxConstraints constraints, Size cardSize) {
    final boardLayoutConfig = context.layoutConfig.board;
    final boardConfig = context.config.board;
    
    // Get layout constants from config
    final horizontalPadding = boardLayoutConfig.horizontalPadding;
    final verticalPadding = boardLayoutConfig.verticalPadding;
    final centerSpacing = boardLayoutConfig.centerSpacing;

    // Calculate sizes using factors from config
    final upperSnapAreaWidth = (constraints.maxWidth - (2 * horizontalPadding) - centerSpacing) * boardConfig.snapAreaSizes.upperWidthFactor;
    final upperSnapAreaHeight = constraints.maxHeight * boardConfig.snapAreaSizes.upperHeightFactor;
    final lowerSnapAreaWidth = constraints.maxWidth * boardConfig.snapAreaSizes.lowerWidthFactor;
    final lowerSnapAreaHeight = constraints.maxHeight * boardConfig.snapAreaSizes.lowerHeightFactor;
    
    // Create snap area configurations
    topLeftArea = SnapAreaConfig(
      size: Size(upperSnapAreaWidth, upperSnapAreaHeight),
      position: Offset(horizontalPadding, verticalPadding),
    );

    topRightArea = SnapAreaConfig(
      size: Size(upperSnapAreaWidth, upperSnapAreaHeight),
      position: Offset(
        horizontalPadding + upperSnapAreaWidth + centerSpacing,
        verticalPadding,
      ),
    );

    bottomArea = SnapAreaConfig(
      size: Size(lowerSnapAreaWidth, lowerSnapAreaHeight),
      position: Offset(
        (constraints.maxWidth - lowerSnapAreaWidth) / 2,
        constraints.maxHeight - lowerSnapAreaHeight - verticalPadding,
      ),
    );
    
    // Create persistent smart areas
    final areas = [
      ConcentricStackArea(
        index: 0,
        bounds: Rect.fromLTWH(
          topLeftArea.position.dx,
          topLeftArea.position.dy,
          topLeftArea.size.width,
          topLeftArea.size.height,
        ),
        gameState: gameState,
      ),
      ConcentricStackArea(
        index: 1,
        bounds: Rect.fromLTWH(
          topRightArea.position.dx,
          topRightArea.position.dy,
          topRightArea.size.width,
          topRightArea.size.height,
        ),
        gameState: gameState,
      ),
      HorizontalStackArea(
        index: 2,
        bounds: Rect.fromLTWH(
          bottomArea.position.dx,
          bottomArea.position.dy,
          bottomArea.size.width,
          bottomArea.size.height,
        ),
        gameState: gameState,
      ),
    ];
    
    // Create persistent snap behavior
    snapBehavior = SmartSnapBehavior(areas: areas, gameState: gameState);
  }
  
  /// Create render configuration for a card
  CardRenderConfig _createRenderConfig(String suit, String rank) {
    final cardConfig = context.cardConfig;
    final assetsConfig = context.assetsConfig;
    
    return CardRenderConfig(
      cardSize: Size(
        cardConfig.dimensions.width,
        cardConfig.dimensions.width * cardConfig.dimensions.aspectRatio,
      ),
      borderRadius: cardConfig.dimensions.borderRadius,
      frontImagePath: assetsConfig.cards.getCardPath(suit, rank),
      backImagePath: assetsConfig.cards.backCardPath,
      initiallyFaceUp: cardConfig.initial.isFaceUp,
      initialRotation: cardConfig.initial.rotation,
      shadowColor: null,
      shadowBlur: 0,
      shadowOffset: Offset.zero,
    );
  }
  
  /// Create animation behavior
  CardAnimationBehavior _createAnimationBehavior() {
    final cardConfig = context.cardConfig;
    
    return DefaultCardAnimationBehavior(
      flipDuration: cardConfig.animation.flipDuration,
      rotationDuration: cardConfig.animation.rotationTransitionDuration,
      maxRotationDegrees: cardConfig.animation.maxRotationDegrees,
      rotationUpdateInterval: cardConfig.animation.rotationUpdateInterval,
    );
  }
  
  /// Calculate initial position for a card using game state
  Offset _calculateInitialPosition(String cardId, Size cardSize) {
    final currentArea = gameState.getCardArea(cardId) ?? GameStateManager.concentricArea0;
    
    Rect areaBounds;
    switch (currentArea) {
      case GameStateManager.concentricArea0:
        areaBounds = Rect.fromLTWH(
          topLeftArea.position.dx,
          topLeftArea.position.dy,
          topLeftArea.size.width,
          topLeftArea.size.height,
        );
        break;
      case GameStateManager.concentricArea1:
        areaBounds = Rect.fromLTWH(
          topRightArea.position.dx,
          topRightArea.position.dy,
          topRightArea.size.width,
          topRightArea.size.height,
        );
        break;
      case GameStateManager.horizontalArea2:
        areaBounds = Rect.fromLTWH(
          bottomArea.position.dx,
          bottomArea.position.dy,
          bottomArea.size.width,
          bottomArea.size.height,
        );
        break;
      default:
        areaBounds = Rect.fromLTWH(
          topLeftArea.position.dx,
          topLeftArea.position.dy,
          topLeftArea.size.width,
          topLeftArea.size.height,
        );
    }
    
    return gameState.calculateCardPosition(cardId, currentArea, areaBounds, cardSize);
  }
  
  

  @override
  Widget build(BuildContext context) {
    final cardConfig = context.cardConfig;
    final backgroundConfig = context.config.background;
    
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardSize = Size(
            cardConfig.dimensions.width,
            cardConfig.dimensions.width * cardConfig.dimensions.aspectRatio
          );


          // Initialize snap areas once
          _initializeSnapAreas(constraints, cardSize);
          
          // Initialize game state with all cards
          if (gameState.getCardCountInArea(GameStateManager.concentricArea0) == 0) {
            final cardIds = deckCards.map((card) => card.id).toList();
            gameState.initializeCards(cardIds);
          }

          return ListenableBuilder(
            listenable: gameState,
            builder: (context, child) => Stack(
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

                return PlayingCard(
                  key: ValueKey(cardId),
                  cardId: cardId,
                  suit: cardMap['suit']!,
                  rank: cardMap['rank']!,
                  renderConfig: _createRenderConfig(cardMap['suit']!, cardMap['rank']!),
                  snapBehavior: snapBehavior,
                  animationBehavior: _createAnimationBehavior(),
                  initialPosition: _calculateInitialPosition(cardId, cardSize),
                  initiallyFaceUp: false,
                  callbacks: CardInteractionCallbacks(
                    onSnapAreaChanged: (snapAreaIndex) {
                      _bringCardToFront(cardId);
                    },
                    onDragStart: () => _startDragging(cardId),
                    onDragEnd: () => _stopDragging(),
                  ),
                );
              }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}