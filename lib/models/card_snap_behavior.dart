import 'package:flutter/material.dart';
import 'card_behavior_interfaces.dart';
import 'game_state_manager.dart';

/// Snap behavior that coordinates between multiple smart snap areas
class SmartSnapBehavior extends SnapBehavior {
  final List<SmartSnapArea> areas;
  final GameStateManager gameState;
  final double snapThreshold;
  
  SmartSnapBehavior({
    required this.areas,
    required this.gameState,
    this.snapThreshold = double.infinity, // No threshold by default
  });
  
  @override
  SnapResult? calculateSnap(Offset cardPosition, Size cardSize, String cardId) {
    if (areas.isEmpty) return null;
    
    final cardCenter = Offset(
      cardPosition.dx + cardSize.width / 2,
      cardPosition.dy + cardSize.height / 2,
    );
    
    SmartSnapArea? nearestArea;
    double minDistance = double.infinity;
    
    // Find nearest snap area
    for (final area in areas) {
      final areaCenter = area.bounds.center;
      final distance = (cardCenter - areaCenter).distance;
      
      if (distance < minDistance && distance <= snapThreshold) {
        minDistance = distance;
        nearestArea = area;
      }
    }
    
    if (nearestArea == null) return null;
    
    // Let the area calculate its own snap position (always preview during drag)
    final snapPosition = nearestArea.calculateSnapPosition(cardSize, cardId, isPreview: true);
    
    return SnapResult(
      snapPosition: snapPosition,
      snapAreaIndex: nearestArea.index,
      allowsRotation: nearestArea.allowsRotation,
    );
  }
  
  @override
  void onCardMoved(String cardId, int? fromAreaIndex, int? toAreaIndex) {
    // Convert area indices to area IDs
    String? fromAreaId;
    String? toAreaId;
    
    if (fromAreaIndex != null) {
      fromAreaId = _getAreaId(fromAreaIndex);
    }
    
    if (toAreaIndex != null) {
      toAreaId = _getAreaId(toAreaIndex);
    }
    
    // Update game state
    if (toAreaId != null) {
      gameState.moveCard(cardId, fromAreaId, toAreaId);
    }
  }
  
  /// Convert area index to area ID
  String _getAreaId(int areaIndex) {
    switch (areaIndex) {
      case 0:
        return GameStateManager.concentricArea0;
      case 1:
        return GameStateManager.concentricArea1;
      case 2:
        return GameStateManager.horizontalArea2;
      default:
        return GameStateManager.concentricArea0;
    }
  }
}

/// Top snap areas: Cards stack concentrically with rotation enabled
class ConcentricStackArea extends SmartSnapArea {
  @override
  final int index;
  @override
  final Rect bounds;
  @override
  bool get allowsRotation => true;
  
  final GameStateManager gameState;
  
  ConcentricStackArea({
    required this.index,
    required this.bounds,
    required this.gameState,
  });
  
  @override
  void addCard(String cardId) {
    // State managed externally - no-op
  }
  
  @override
  void removeCard(String cardId) {
    // State managed externally - no-op
  }
  
  @override
  Offset calculateSnapPosition(Size cardSize, String cardId, {bool isPreview = false}) {
    final areaId = _getAreaId();
    return gameState.calculateCardPosition(
      cardId, 
      areaId, 
      bounds, 
      cardSize, 
      isPreview: isPreview,
    );
  }
  
  /// Get area ID based on index
  String _getAreaId() {
    switch (index) {
      case 0:
        return GameStateManager.concentricArea0;
      case 1:
        return GameStateManager.concentricArea1;
      default:
        return GameStateManager.concentricArea0;
    }
  }
  
  @override
  bool containsPosition(Offset position, Size cardSize) {
    final cardCenter = Offset(
      position.dx + cardSize.width / 2,
      position.dy + cardSize.height / 2,
    );
    return bounds.contains(cardCenter);
  }
}

/// Bottom snap area: Cards stack horizontally without rotation
class HorizontalStackArea extends SmartSnapArea {
  @override
  final int index;
  @override
  final Rect bounds;
  @override
  bool get allowsRotation => false; // No rotation in bottom area
  
  final GameStateManager gameState;
  
  HorizontalStackArea({
    required this.index,
    required this.bounds,
    required this.gameState,
  });
  
  @override
  void addCard(String cardId) {
    // State managed externally - no-op
  }
  
  @override
  void removeCard(String cardId) {
    // State managed externally - no-op
  }
  
  @override
  Offset calculateSnapPosition(Size cardSize, String cardId, {bool isPreview = false}) {
    return gameState.calculateCardPosition(
      cardId, 
      GameStateManager.horizontalArea2, 
      bounds, 
      cardSize, 
      isPreview: isPreview,
    );
  }
  
  @override
  bool containsPosition(Offset position, Size cardSize) {
    final cardCenter = Offset(
      position.dx + cardSize.width / 2,
      position.dy + cardSize.height / 2,
    );
    return bounds.contains(cardCenter);
  }
}

/// Grid-based snap area for structured layouts like Solitaire
class GridSnapArea extends SmartSnapArea {
  @override
  final int index;
  @override
  final Rect bounds;
  @override
  final bool allowsRotation;
  
  final int columns;
  final int rows;
  final Size cellSize;
  final Map<String, GridPosition> _cardPositions = {};
  
  GridSnapArea({
    required this.index,
    required this.bounds,
    required this.columns,
    required this.rows,
    required this.cellSize,
    this.allowsRotation = true,
  });
  
  @override
  void addCard(String cardId) {
    if (!_cardPositions.containsKey(cardId)) {
      // Find next available grid position
      final position = _findNextAvailablePosition();
      if (position != null) {
        _cardPositions[cardId] = position;
      }
    }
  }
  
  @override
  void removeCard(String cardId) {
    _cardPositions.remove(cardId);
  }
  
  @override
  Offset calculateSnapPosition(Size cardSize, String cardId, {bool isPreview = false}) {
    final position = _findNextAvailablePosition();
    if (position == null) return bounds.center;
    
    return Offset(
      bounds.left + (position.col * cellSize.width) + (cellSize.width - cardSize.width) / 2,
      bounds.top + (position.row * cellSize.height) + (cellSize.height - cardSize.height) / 2,
    );
  }
  
  @override
  bool containsPosition(Offset position, Size cardSize) {
    final cardCenter = Offset(
      position.dx + cardSize.width / 2,
      position.dy + cardSize.height / 2,
    );
    return bounds.contains(cardCenter);
  }
  
  GridPosition? _findNextAvailablePosition() {
    final usedPositions = Set.from(_cardPositions.values);
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final position = GridPosition(row: row, col: col);
        if (!usedPositions.contains(position)) {
          return position;
        }
      }
    }
    return null; // Grid is full
  }
}

/// Helper class for grid positions
class GridPosition {
  final int row;
  final int col;
  
  const GridPosition({required this.row, required this.col});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition && row == other.row && col == other.col;
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

