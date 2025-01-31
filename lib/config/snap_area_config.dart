import 'package:flutter/material.dart';
import 'dart:math' as math;

class SnapAreaConfig {
  final Size size;
  final Offset position;

  const SnapAreaConfig({
    required this.size,
    required this.position,
  });

  bool containsPoint(Offset point, Size cardSize) {
    final cardCenter = Offset(
      point.dx + cardSize.width / 2,
      point.dy + cardSize.height / 2,
    );

    return cardCenter.dx >= position.dx &&
        cardCenter.dx <= position.dx + size.width &&
        cardCenter.dy >= position.dy &&
        cardCenter.dy <= position.dy + size.height;
  }

  Offset clampPosition(Offset point, Size cardSize) {
    // Calculate the bounds for the card's position
    final minX = position.dx;
    final maxX = position.dx + size.width - cardSize.width;
    final minY = position.dy;
    final maxY = position.dy + size.height - cardSize.height;

    // If the snap area is smaller than the card, center the card
    if (maxX < minX) {
      return Offset(
        position.dx + (size.width - cardSize.width) / 2,
        point.dy.clamp(minY, math.max(minY, maxY))
      );
    }
    if (maxY < minY) {
      return Offset(
        point.dx.clamp(minX, maxX),
        position.dy + (size.height - cardSize.height) / 2
      );
    }

    return Offset(
      point.dx.clamp(minX, maxX),
      point.dy.clamp(minY, maxY),
    );
  }

  // Add this getter
  Offset get center => Offset(
    position.dx + size.width / 2,
    position.dy + size.height / 2,
  );
}