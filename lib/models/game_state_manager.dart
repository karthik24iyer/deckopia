import 'package:flutter/material.dart';
import '../config/snap_behavior_config.dart';

/// Centralized state manager for all card positions and area management
class GameStateManager extends ChangeNotifier {
  // Area type definitions
  static const String concentricArea0 = 'concentric_0';
  static const String concentricArea1 = 'concentric_1'; 
  static const String horizontalArea2 = 'horizontal_2';
  
  // Configuration for snap behaviors
  final SnapBehaviorConfig config;
  
  // Card tracking: areaId -> [cardIds]
  final Map<String, List<String>> _areaCards = {
    concentricArea0: [],
    concentricArea1: [],
    horizontalArea2: [],
  };
  
  // Reverse mapping: cardId -> areaId (for quick lookups)
  final Map<String, String> _cardToArea = {};
  
  GameStateManager({this.config = SnapBehaviorConfig.defaultConfig});
  
  /// Initialize all cards in the starting area (concentric_0)
  void initializeCards(List<String> cardIds) {
    _areaCards[concentricArea0]!.clear();
    _areaCards[concentricArea1]!.clear();
    _areaCards[horizontalArea2]!.clear();
    _cardToArea.clear();
    
    for (final cardId in cardIds) {
      _areaCards[concentricArea0]!.add(cardId);
      _cardToArea[cardId] = concentricArea0;
    }
    notifyListeners();
  }
  
  /// Move a card from one area to another
  void moveCard(String cardId, String? fromAreaId, String toAreaId) {
    // Remove from old area
    if (fromAreaId != null && _areaCards.containsKey(fromAreaId)) {
      _areaCards[fromAreaId]!.remove(cardId);
    }
    
    // Add to new area
    if (_areaCards.containsKey(toAreaId)) {
      if (!_areaCards[toAreaId]!.contains(cardId)) {
        _areaCards[toAreaId]!.add(cardId);
      }
      _cardToArea[cardId] = toAreaId;
    }
    
    notifyListeners();
  }
  
  /// Get number of cards in an area
  int getCardCountInArea(String areaId) {
    return _areaCards[areaId]?.length ?? 0;
  }
  
  /// Get the index position of a card within its area
  int getCardIndex(String cardId, String areaId) {
    final cards = _areaCards[areaId];
    if (cards == null) return 0;
    final index = cards.indexOf(cardId);
    return index >= 0 ? index : cards.length; // If not found, put at end
  }
  
  /// Check if a card is in a specific area
  bool isCardInArea(String cardId, String areaId) {
    return _cardToArea[cardId] == areaId;
  }
  
  /// Get which area a card is currently in
  String? getCardArea(String cardId) {
    return _cardToArea[cardId];
  }
  
  /// Calculate position for a card in a specific area
  Offset calculateCardPosition(
    String cardId, 
    String areaId, 
    Rect areaBounds, 
    Size cardSize, {
    bool isPreview = false,
  }) {
    switch (areaId) {
      case concentricArea0:
      case concentricArea1:
        return _calculateConcentricPosition(cardId, areaId, areaBounds, cardSize, isPreview: isPreview);
      case horizontalArea2:
        return _calculateHorizontalPosition(cardId, areaId, areaBounds, cardSize, isPreview: isPreview);
      default:
        // Default to center of area
        return Offset(
          areaBounds.left + (areaBounds.width - cardSize.width) / 2,
          areaBounds.top + (areaBounds.height - cardSize.height) / 2,
        );
    }
  }
  
  /// Calculate concentric stacking position (for top areas)
  Offset _calculateConcentricPosition(
    String cardId,
    String areaId, 
    Rect areaBounds,
    Size cardSize, {
    bool isPreview = false,
  }) {
    // Center position
    final center = Offset(
      areaBounds.left + (areaBounds.width - cardSize.width) / 2,
      areaBounds.top + (areaBounds.height - cardSize.height) / 2,
    );
    
    // Calculate offset based on card position in stack
    int cardPosition;
    if (isPreview && !isCardInArea(cardId, areaId)) {
      // Card being dragged to area - calculate future position
      cardPosition = getCardCountInArea(areaId);
    } else {
      // Card already in area or not preview - use current position
      cardPosition = getCardIndex(cardId, areaId);
    }
    
    // Apply offset based on configuration
    if (config.enableConcentricOffset) {
      final offsetX = cardPosition * config.concentricStackOffset;
      final offsetY = cardPosition * config.concentricStackOffset;
      return Offset(center.dx + offsetX, center.dy + offsetY);
    } else {
      // No offset - all cards at exact center
      return center;
    }
  }
  
  /// Calculate horizontal stacking position (for bottom area)
  Offset _calculateHorizontalPosition(
    String cardId,
    String areaId,
    Rect areaBounds, 
    Size cardSize, {
    bool isPreview = false,
  }) {
    // Left edge and vertical center
    final leftEdge = areaBounds.left;
    final verticalCenter = areaBounds.top + (areaBounds.height - cardSize.height) / 2;
    
    // Calculate position based on card order in horizontal stack
    int cardPosition;
    if (isPreview && !isCardInArea(cardId, areaId)) {
      // Card being dragged to area - calculate future position
      cardPosition = getCardCountInArea(areaId);
    } else {
      // Card already in area or not preview - use current position
      cardPosition = getCardIndex(cardId, areaId);
    }
    
    // Horizontal spacing between cards (from configuration)
    final cardSpacing = config.horizontalCardSpacing;
    final horizontalOffset = cardPosition * cardSpacing;
    
    return Offset(leftEdge + horizontalOffset, verticalCenter);
  }
  
  /// Get all cards in an area (for debugging)
  List<String> getCardsInArea(String areaId) {
    return List.unmodifiable(_areaCards[areaId] ?? []);
  }
  
  /// Clear all state (for reset)
  void clear() {
    for (final areaCards in _areaCards.values) {
      areaCards.clear();
    }
    _cardToArea.clear();
    notifyListeners();
  }
}