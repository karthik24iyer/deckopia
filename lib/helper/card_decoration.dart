import 'package:flutter/material.dart';

class CardProperties {
  // Card Dimensions
  static const double cardWidth = 200.0;
  static const double cardHeight = 350.0;
  static const double cardBorderRadius = 5;

  // Spacing and Padding
  static const double cornerPadding = 10.0;
  static const double symbolSpacing = 0.0;

  // Font Sizes
  static const double cornerRankSize = 24.0;
  static const double cornerSuitSize = 24.0;
  static const double centerSuitSize = 100.0;

  // Colors
  static const Color redSuitColor = Colors.red;
  static const Color blackSuitColor = Colors.black;
  static const Color cardBackground = Colors.white;
  static const Color shadowColor = Colors.black26;

  // Shadow Properties
  static const double shadowBlur = 8.0;
  static const Offset shadowOffset = Offset(0, 2);

  // Pattern Properties
  static const double patternOpacity = 0.6;

  // Text Styles
  static TextStyle cornerRankStyle(bool isRed) => TextStyle(
    fontSize: cornerRankSize,
    fontWeight: FontWeight.bold,
    color: isRed ? redSuitColor : blackSuitColor,
  );

  static TextStyle cornerSuitStyle(bool isRed) => TextStyle(
    fontSize: cornerSuitSize,
    color: isRed ? redSuitColor : blackSuitColor,
  );

  static TextStyle centerSuitStyle(bool isRed) => TextStyle(
    fontSize: centerSuitSize,
    color: isRed ? redSuitColor : blackSuitColor,
  );

  // Card Decoration
  static BoxDecoration cardDecoration(bool isRed) => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(cardBorderRadius),
    boxShadow: [
      BoxShadow(
        color: shadowColor,
        blurRadius: shadowBlur,
        offset: shadowOffset,
      ),
    ],
    image: DecorationImage(
      image: AssetImage(
        isRed ? 'assets/red_pattern.png' : 'assets/black_pattern.png',
      ),
      opacity: patternOpacity,
      fit: BoxFit.cover,
    ),
  );
}