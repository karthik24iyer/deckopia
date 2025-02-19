import 'dart:convert';
import 'package:flutter/services.dart';

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
      : redSuit = _parseColor(json['redSuit']),
        blackSuit = _parseColor(json['blackSuit']),
        background = _parseColor(json['background']),
        shadow = _parseColor(json['shadow']);

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    }
    return Color(int.parse('0xFF$hexColor'));
  }
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

// Layout configurations
class LayoutContainers {
  final double width;
  final double deckHeight;
  final double playAreaHeight;

  LayoutContainers.fromJson(Map<String, dynamic> json)
      : width = json['width'].toDouble(),
        deckHeight = json['deckHeight'].toDouble(),
        playAreaHeight = json['playAreaHeight'].toDouble();
}

class LayoutConfig {
  final LayoutContainers containers;

  LayoutConfig.fromJson(Map<String, dynamic> json)
      : containers = LayoutContainers.fromJson(json['containers']);
}

// Snap area configurations
class SnapAreaStyle {
  final Color borderColor;
  final double borderRadius;
  final double labelTextSize;
  final double labelPadding;

  SnapAreaStyle.fromJson(Map<String, dynamic> json)
      : borderColor = CardColors._parseColor(json['borderColor']),
        borderRadius = json['borderRadius'].toDouble(),
        labelTextSize = json['labelTextSize'].toDouble(),
        labelPadding = json['labelPadding'].toDouble();
}

class SnapConfig {
  final SnapAreaStyle style;

  SnapConfig.fromJson(Map<String, dynamic> json)
      : style = SnapAreaStyle.fromJson(json['style']);
}

// App configurations
class AppTheme {
  final Color primaryColor;
  final Color backgroundColor;
  final bool showDebugBanner;
  final AppFonts fonts;

  AppTheme.fromJson(Map<String, dynamic> json)
      : primaryColor = CardColors._parseColor(json['primaryColor']),
        backgroundColor = CardColors._parseColor(json['backgroundColor']),
        showDebugBanner = json['showDebugBanner'],
        fonts = AppFonts.fromJson(json['fonts']);
}

class AppConfig {
  final AppTheme theme;
  final String title;

  AppConfig.fromJson(Map<String, dynamic> json)
      : theme = AppTheme.fromJson(json['theme']),
        title = json['title'];
}

// Main configuration class
class Config {
  final CardConfig card;
  final LayoutConfig layout;
  final SnapConfig snapArea;
  final AppConfig app;

  Config.fromJson(Map<String, dynamic> json)
      : card = CardConfig.fromJson(json['card']),
        layout = LayoutConfig.fromJson(json['layout']),
        snapArea = SnapConfig.fromJson(json['snapArea']),
        app = AppConfig.fromJson(json['app']);

  // Static method to load configuration from asset
  static Future<Config> load() async {
    final jsonString = await rootBundle.loadString('assets/config/app_config.json');
    final jsonMap = json.decode(jsonString);
    return Config.fromJson(jsonMap);
  }
}

class AppFonts {
  final String fontFamily;
  final double titleSize;
  final double buttonTextSize;

  AppFonts.fromJson(Map<String, dynamic> json)
      : fontFamily = json['fontFamily'],
        titleSize = json['titleSize'].toDouble(),
        buttonTextSize = json['buttonTextSize'].toDouble();
}