// card_decoration.dart
import 'package:deckopia/util/config_provider.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';

class CardDecorationBuilder {
  final BuildContext context;

  // Constructor requires BuildContext to access configuration
  const CardDecorationBuilder(this.context);

  // Get card config for shorter access
  CardConfig get _config => context.cardConfig;

  // Card Dimensions
  Size get cardSize => Size(
    _config.dimensions.width,
    _config.dimensions.width * _config.dimensions.aspectRatio,
  );

  double get borderRadius => _config.dimensions.borderRadius;

  // Spacing and Padding
  double get cornerPadding => _config.spacing.cornerPadding;
  double get symbolSpacing => _config.spacing.symbolSpacing;

  // Font Sizes
  double get cornerRankSize => _config.fonts.cornerRankSize;
  double get cornerSuitSize => _config.fonts.cornerSuitSize;
  double get centerSymbolSize => _config.fonts.centerSymbolSize;

  // Colors
  Color get redSuitColor => _config.colors.redSuit;
  Color get blackSuitColor => _config.colors.blackSuit;
  Color get cardBackground => _config.colors.background;
  Color get shadowColor => _config.colors.shadow;

  // Shadow Properties
  double get shadowBlur => _config.shadow.blur;
  double get shadowSpread => _config.shadow.spread;
  Offset get shadowOffset => Offset(
    _config.shadow.offsetX,
    _config.shadow.offsetY,
  );
  double get shadowOpacity => _config.shadow.opacity;

  // Pattern Properties
  double get patternOpacity => _config.patternOpacity;

  // Text Styles
  TextStyle cornerRankStyle(bool isRed) => TextStyle(
    fontSize: cornerRankSize,
    fontWeight: FontWeight.bold,
    color: isRed ? redSuitColor : blackSuitColor,
  );

  TextStyle cornerSuitStyle(bool isRed) => TextStyle(
    fontSize: cornerSuitSize,
    color: isRed ? redSuitColor : blackSuitColor,
  );

  TextStyle centerSuitStyle(bool isRed) => TextStyle(
    fontSize: centerSymbolSize,
    color: isRed ? redSuitColor : blackSuitColor,
  );

  // Card Decoration
  BoxDecoration cardDecoration(bool isRed) => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(borderRadius),
    image: DecorationImage(
      image: AssetImage(
        isRed ? 'assets/images/red_pattern.png' : 'assets/images/black_pattern.png',
      ),
      opacity: patternOpacity,
      fit: BoxFit.cover,
    ),
  );
}