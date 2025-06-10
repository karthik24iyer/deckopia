import 'package:flutter/material.dart';

/// Behavior that coordinates between multiple smart snap areas
abstract class SnapBehavior {
  /// Calculate the best snap position for given card position
  /// Returns null if no snapping should occur
  SnapResult? calculateSnap(Offset cardPosition, Size cardSize, String cardId);
  
  /// Get visual feedback during drag (e.g., highlight snap areas)
  Widget? buildSnapFeedback(Offset currentPosition, Size cardSize) => null;
  
  /// Notify behavior that a card has moved between areas
  void onCardMoved(String cardId, int? fromAreaIndex, int? toAreaIndex);
}

/// Result of snap calculation
class SnapResult {
  final Offset snapPosition;
  final int? snapAreaIndex; // Optional area identifier
  final bool allowsRotation; // Whether rotation is enabled in this area
  final Map<String, dynamic>? metadata; // Extra data for specific behaviors
  
  const SnapResult({
    required this.snapPosition,
    required this.allowsRotation,
    this.snapAreaIndex,
    this.metadata,
  });
}

/// Smart snap area that manages its own behavior and state
abstract class SmartSnapArea {
  int get index;
  Rect get bounds;
  bool get allowsRotation;
  
  /// Add a card to this snap area
  void addCard(String cardId);
  
  /// Remove a card from this snap area  
  void removeCard(String cardId);
  
  /// Calculate position for a new card being snapped to this area
  Offset calculateSnapPosition(Size cardSize, String cardId);
  
  /// Check if a position is within this snap area
  bool containsPosition(Offset position, Size cardSize);
  
  /// Get visual feedback while dragging over this area
  Widget? buildSnapFeedback(Offset currentPosition, Size cardSize) => null;
  
  /// Called when a card is successfully snapped to this area
  void onCardSnapped(String cardId) => addCard(cardId);
  
  /// Called when a card leaves this area
  void onCardLeft(String cardId) => removeCard(cardId);
}

/// Abstract behavior for card animation logic
abstract class CardAnimationBehavior {
  /// Get flip animation duration
  Duration get flipDuration;
  
  /// Get rotation animation parameters  
  Duration get rotationDuration;
  double get maxRotationRadians;
  Duration get rotationUpdateInterval;
  
  /// Called when card should start animating
  void onAnimationStart() {}
  
  /// Called when card should stop animating
  void onAnimationStop() {}
}

/// Abstract behavior for card drag interactions
abstract class CardDragBehavior {
  /// Called when drag starts
  void onDragStart(Offset position) {}
  
  /// Called during drag with current position
  void onDragUpdate(Offset position) {}
  
  /// Called when drag ends with final position
  void onDragEnd(Offset position) {}
  
  /// Whether drag is currently enabled
  bool get isDragEnabled => true;
}

/// Configuration for card rendering independent of board layout
class CardRenderConfig {
  final Size cardSize;
  final double borderRadius;
  final String frontImagePath;
  final String backImagePath;
  final bool initiallyFaceUp;
  final double initialRotation;
  final Color? shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;
  
  const CardRenderConfig({
    required this.cardSize,
    required this.borderRadius,
    required this.frontImagePath,
    required this.backImagePath,
    this.initiallyFaceUp = false,
    this.initialRotation = 0.0,
    this.shadowColor,
    this.shadowBlur = 4.0,
    this.shadowOffset = const Offset(0, 2),
  });
  
  /// Create from existing card config for backward compatibility
  factory CardRenderConfig.fromCardConfig({
    required double width,
    required double aspectRatio,
    required double borderRadius,
    required String frontImagePath,
    required String backImagePath,
    required bool initiallyFaceUp,
    required double initialRotation,
    Color? shadowColor,
    double shadowBlur = 4.0,
    Offset shadowOffset = const Offset(0, 2),
  }) {
    return CardRenderConfig(
      cardSize: Size(width, width * aspectRatio),
      borderRadius: borderRadius,
      frontImagePath: frontImagePath,
      backImagePath: backImagePath,
      initiallyFaceUp: initiallyFaceUp,
      initialRotation: initialRotation,
      shadowColor: shadowColor,
      shadowBlur: shadowBlur,
      shadowOffset: shadowOffset,
    );
  }
}

/// Comprehensive callback interface for card interactions
class CardInteractionCallbacks {
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Function(Offset position)? onPositionChanged;
  final Function(int? snapAreaIndex)? onSnapAreaChanged;
  final VoidCallback? onFlip;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  
  const CardInteractionCallbacks({
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onPositionChanged,
    this.onSnapAreaChanged,
    this.onFlip,
    this.onDragStart,
    this.onDragEnd,
  });
}