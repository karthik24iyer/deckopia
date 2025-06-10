import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'card_behavior_interfaces.dart';

/// Snap behavior that coordinates between multiple smart snap areas
class SmartSnapBehavior extends SnapBehavior {
  final List<SmartSnapArea> areas;
  final double snapThreshold;
  
  SmartSnapBehavior({
    required this.areas,
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
    
    // Let the area calculate its own snap position
    final snapPosition = nearestArea.calculateSnapPosition(cardSize, cardId);
    
    return SnapResult(
      snapPosition: snapPosition,
      snapAreaIndex: nearestArea.index,
      allowsRotation: nearestArea.allowsRotation,
    );
  }
  
  @override
  void onCardMoved(String cardId, int? fromAreaIndex, int? toAreaIndex) {
    // Remove card from old area
    if (fromAreaIndex != null) {
      final fromArea = areas.firstWhere((area) => area.index == fromAreaIndex);
      fromArea.onCardLeft(cardId);
    }
    
    // Add card to new area
    if (toAreaIndex != null) {
      final toArea = areas.firstWhere((area) => area.index == toAreaIndex);
      toArea.onCardSnapped(cardId);
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
  
  final List<String> _cards = [];
  final double stackOffset;
  
  ConcentricStackArea({
    required this.index,
    required this.bounds,
    this.stackOffset = 2.0,
  });
  
  @override
  void addCard(String cardId) {
    if (!_cards.contains(cardId)) {
      _cards.add(cardId);
    }
  }
  
  @override
  void removeCard(String cardId) {
    _cards.remove(cardId);
  }
  
  @override
  Offset calculateSnapPosition(Size cardSize, String cardId) {
    // Cards stack concentrically at center with small offset
    final center = Offset(
      bounds.left + (bounds.width - cardSize.width) / 2,
      bounds.top + (bounds.height - cardSize.height) / 2,
    );
    
    // Add small random offset for visual stacking effect
    final cardCount = _cards.length;
    final offsetX = cardCount * stackOffset;
    final offsetY = cardCount * stackOffset;
    
    return Offset(center.dx + offsetX, center.dy + offsetY);
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
  
  final double cardSpacing;
  final Function() getCardCount; // Get count from external source
  
  HorizontalStackArea({
    required this.index,
    required this.bounds,
    required this.getCardCount,
    this.cardSpacing = 10.0,
  });
  
  @override
  void addCard(String cardId) {
    // External tracking handles this
  }
  
  @override
  void removeCard(String cardId) {
    // External tracking handles this
  }
  
  @override
  Offset calculateSnapPosition(Size cardSize, String cardId) {
    // Cards stack horizontally from left edge
    final leftEdge = bounds.left;
    final verticalCenter = bounds.top + (bounds.height - cardSize.height) / 2;
    
    // Get current card count from external source
    final cardCount = getCardCount();
    final horizontalOffset = cardCount * cardSpacing;
    final position = Offset(leftEdge + horizontalOffset, verticalCenter);
    
    print('HorizontalStackArea: calculateSnapPosition - cardCount: $cardCount, offset: $horizontalOffset, position: $position');
    
    return position;
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
  Offset calculateSnapPosition(Size cardSize, String cardId) {
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

