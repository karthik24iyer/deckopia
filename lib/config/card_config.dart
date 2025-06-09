import 'package:flutter/material.dart';
import 'assets_config.dart';

// Card-specific configurations
class CardDimensions {
  final double width;
  final double aspectRatio;
  final double borderRadius;

  CardDimensions.fromJson(Map<String, dynamic> json)
      : width = json['width'].toDouble(),
        aspectRatio = json['aspectRatio'].toDouble(),
        borderRadius = json['borderRadius'].toDouble();
}

class CardSpacing {
  final double cornerPadding;
  final double symbolSpacing;
  final double deckOffset;

  CardSpacing.fromJson(Map<String, dynamic> json)
      : cornerPadding = json['cornerPadding'].toDouble(),
        symbolSpacing = json['symbolSpacing'].toDouble(),
        deckOffset = json['deckOffset'].toDouble();
}

class CardFonts {
  final double cornerRankSize;
  final double cornerSuitSize;
  final double centerSymbolSize;

  CardFonts.fromJson(Map<String, dynamic> json)
      : cornerRankSize = json['cornerRankSize'].toDouble(),
        cornerSuitSize = json['cornerSuitSize'].toDouble(),
        centerSymbolSize = json['centerSymbolSize'].toDouble();
}

class CardColors {
  final Color redSuit;
  final Color blackSuit;
  final Color background;
  final Color shadow;

  CardColors.fromJson(Map<String, dynamic> json)
      : redSuit = parseColor(json['redSuit']),
        blackSuit = parseColor(json['blackSuit']),
        background = parseColor(json['background']),
        shadow = parseColor(json['shadow']);
}

class CardShadow {
  final double blur;
  final double spread;
  final double offsetX;
  final double offsetY;
  final double opacity;

  CardShadow.fromJson(Map<String, dynamic> json)
      : blur = json['blur'].toDouble(),
        spread = json['spread'].toDouble(),
        offsetX = json['offsetX'].toDouble(),
        offsetY = json['offsetY'].toDouble(),
        opacity = json['opacity'].toDouble();
}

class CardAnimation {
  final double maxRotationDegrees;
  final Duration rotationUpdateInterval;
  final Duration rotationTransitionDuration;
  final Duration flipDuration;

  CardAnimation.fromJson(Map<String, dynamic> json)
      : maxRotationDegrees = json['maxRotationDegrees'].toDouble(),
        rotationUpdateInterval = Duration(milliseconds: json['rotationUpdateIntervalMs']),
        rotationTransitionDuration = Duration(milliseconds: json['rotationTransitionDurationMs']),
        flipDuration = Duration(milliseconds: json['flipDurationMs']);
}

class CardInitial {
  final bool isFaceUp;
  final double rotation;

  CardInitial.fromJson(Map<String, dynamic> json)
      : isFaceUp = json['isFaceUp'],
        rotation = json['rotation'].toDouble();
}

class CardConfig {
  final CardDimensions dimensions;
  final CardSpacing spacing;
  final CardFonts fonts;
  final CardColors colors;
  final CardShadow shadow;
  final CardAnimation animation;
  final CardInitial initial;
  final double patternOpacity;

  CardConfig.fromJson(Map<String, dynamic> json)
      : dimensions = CardDimensions.fromJson(json['dimensions']),
        spacing = CardSpacing.fromJson(json['spacing']),
        fonts = CardFonts.fromJson(json['fonts']),
        colors = CardColors.fromJson(json['colors']),
        shadow = CardShadow.fromJson(json['shadow']),
        animation = CardAnimation.fromJson(json['animation']),
        initial = CardInitial.fromJson(json['initial']),
        patternOpacity = json['pattern']['opacity'].toDouble();
}
