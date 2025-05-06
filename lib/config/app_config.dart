import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Color utility function
Color parseColor(String hexColor) {
  hexColor = hexColor.replaceFirst('#', '');
  if (hexColor.length == 8) {
    return Color(int.parse('0x$hexColor'));
  }
  return Color(int.parse('0xFF$hexColor'));
}

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

class BoardLayout {
  final double horizontalPadding;
  final double verticalPadding;
  final double centerSpacing;
  
  BoardLayout.fromJson(Map<String, dynamic> json)
      : horizontalPadding = json['horizontalPadding'].toDouble(),
        verticalPadding = json['verticalPadding'].toDouble(),
        centerSpacing = json['centerSpacing'].toDouble();
}

class LayoutConfig {
  final LayoutContainers containers;
  final BoardLayout board;

  LayoutConfig.fromJson(Map<String, dynamic> json)
      : containers = LayoutContainers.fromJson(json['containers']),
        board = BoardLayout.fromJson(json['board']);
}

// Snap area configurations
class SnapAreaStyle {
  final Color borderColor;
  final double borderRadius;
  final double labelTextSize;
  final double labelPadding;
  final double borderOpacity;

  SnapAreaStyle.fromJson(Map<String, dynamic> json)
      : borderColor = parseColor(json['borderColor']),
        borderRadius = json['borderRadius'].toDouble(),
        labelTextSize = json['labelTextSize'].toDouble(),
        labelPadding = json['labelPadding'].toDouble(),
        borderOpacity = json['borderOpacity'].toDouble();
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
      : primaryColor = parseColor(json['primaryColor']),
        backgroundColor = parseColor(json['backgroundColor']),
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

// Sketchy button configurations
class SketchyButtonShadow {
  final double blur;
  final double offsetX;
  final double offsetY;
  final double opacity;

  SketchyButtonShadow.fromJson(Map<String, dynamic> json)
      : blur = json['blur'].toDouble(),
        offsetX = json['offsetX'].toDouble(),
        offsetY = json['offsetY'].toDouble(),
        opacity = json['opacity'].toDouble();
}

class SketchyButtonConfig {
  final double height;
  final SketchyButtonShadow shadow;
  final double noiseMagnitude;
  final double curveNoiseMagnitude;

  SketchyButtonConfig.fromJson(Map<String, dynamic> json)
      : height = json['height'].toDouble(),
        shadow = SketchyButtonShadow.fromJson(json['shadow']),
        noiseMagnitude = json['noiseMagnitude'].toDouble(),
        curveNoiseMagnitude = json['curveNoiseMagnitude'].toDouble();
}

// Background configurations
class BackgroundOverlay {
  final double opacityTop;
  final double opacityBottom;
  
  BackgroundOverlay.fromJson(Map<String, dynamic> json)
      : opacityTop = json['opacityTop'].toDouble(),
        opacityBottom = json['opacityBottom'].toDouble();
}

class BackgroundConfig {
  final BackgroundOverlay overlay;
  final double imageOpacity;
  
  BackgroundConfig.fromJson(Map<String, dynamic> json)
      : overlay = BackgroundOverlay.fromJson(json['overlay']),
        imageOpacity = json['imageOpacity'].toDouble();
}

// Dialog configurations
class DialogPadding {
  final double horizontal;
  final double vertical;

  DialogPadding.fromJson(Map<String, dynamic> json)
      : horizontal = json['horizontal'].toDouble(),
        vertical = json['vertical'].toDouble();
}

class OtpErrorConfig {
  final Color backgroundColor;
  final double fontSize;
  final DialogPadding padding;
  final double spacing;
  final double titleSpacing;
  final Color retryColor;
  final Color exitColor;

  OtpErrorConfig.fromJson(Map<String, dynamic> json)
      : backgroundColor = parseColor(json['backgroundColor']),
        fontSize = json['fontSize'].toDouble(),
        padding = DialogPadding.fromJson(json['padding']),
        spacing = json['spacing'].toDouble(),
        titleSpacing = json['titleSpacing'].toDouble(),
        retryColor = parseColor(json['retryColor']),
        exitColor = parseColor(json['exitColor']);
}

class DialogConfig {
  final OtpErrorConfig otpError;

  DialogConfig.fromJson(Map<String, dynamic> json)
      : otpError = OtpErrorConfig.fromJson(json['otpError']);
}

// Animation configurations
class AnimationConfig {
  final int pageTransitionDuration;

  AnimationConfig.fromJson(Map<String, dynamic> json)
      : pageTransitionDuration = json['pageTransition']['duration'];
}

// Spacing configurations
class SpacingConfig {
  final double default_;
  final double small;
  final double large;

  SpacingConfig.fromJson(Map<String, dynamic> json)
      : default_ = json['default'].toDouble(),
        small = json['small'].toDouble(),
        large = json['large'].toDouble();
}

// Color configurations
class ButtonColors {
  final Color lightBlue;
  final Color yellow;
  final Color pink;
  final Color red;

  ButtonColors.fromJson(Map<String, dynamic> json)
      : lightBlue = parseColor(json['lightBlue']),
        yellow = parseColor(json['yellow']),
        pink = parseColor(json['pink']),
        red = parseColor(json['red']);
}

class GradientOpacities {
  final double top;
  final double bottom;

  GradientOpacities.fromJson(Map<String, dynamic> json)
      : top = json['top'].toDouble(),
        bottom = json['bottom'].toDouble();
}

class ColorConfig {
  final ButtonColors buttonColors;
  final GradientOpacities whiteGradient;
  final double standardOverlay;
  final double lightOverlay;

  ColorConfig.fromJson(Map<String, dynamic> json)
      : buttonColors = ButtonColors.fromJson(json['buttonColors']),
        whiteGradient = GradientOpacities.fromJson(json['gradientOpacities']['white']),
        standardOverlay = json['overlayOpacities']['standard'].toDouble(),
        lightOverlay = json['overlayOpacities']['light'].toDouble();
}

// Sketchy art configurations
class SketchyConfig {
  final Color borderColor;
  final double borderWidth;
  final Color selectedBorderColor;
  final double selectedBorderWidth;
  final double strokeWidth;
  final double segmentLength;
  final int numberOfPoints;
  final double randomOffset;
  // Constants for control points (not configurable)
  final double firstControlPoint = 1.0/3.0; 
  final double secondControlPoint = 2.0/3.0;

  SketchyConfig.fromJson(Map<String, dynamic> json)
      : borderColor = parseColor(json['borderColor']),
        borderWidth = json['borderWidth'].toDouble(),
        selectedBorderColor = parseColor(json['selectedBorderColor']),
        selectedBorderWidth = json['selectedBorderWidth'].toDouble(),
        strokeWidth = json['strokeWidth'].toDouble(),
        segmentLength = json['segmentLength'].toDouble(),
        numberOfPoints = json['numberOfPoints'],
        randomOffset = json['randomOffset'].toDouble();
}

// Board configurations
class SnapAreaSizes {
  final double upperWidthFactor;
  final double upperHeightFactor;
  final double lowerWidthFactor;
  final double lowerHeightFactor;

  SnapAreaSizes.fromJson(Map<String, dynamic> json)
      : upperWidthFactor = json['upperWidthFactor'].toDouble(),
        upperHeightFactor = json['upperHeightFactor'].toDouble(),
        lowerWidthFactor = json['lowerWidthFactor'].toDouble(),
        lowerHeightFactor = json['lowerHeightFactor'].toDouble();
}

class RotationConfig {
  final double maxRadians;

  RotationConfig.fromJson(Map<String, dynamic> json)
      : maxRadians = json['maxRadians'].toDouble();
}

class BoardConfig {
  final double stackOffset;
  final SnapAreaSizes snapAreaSizes;
  final RotationConfig rotation;

  BoardConfig.fromJson(Map<String, dynamic> json)
      : stackOffset = json['stackOffset'].toDouble(),
        snapAreaSizes = SnapAreaSizes.fromJson(json['snapAreaSizes']),
        rotation = RotationConfig.fromJson(json['rotation']);
}

// Game configurations
class GameConfig {
  final String mockOTP;
  final int otpDelay;

  GameConfig.fromJson(Map<String, dynamic> json)
      : mockOTP = json['mockOTP'],
        otpDelay = json['otpDelay'];
}

// Main configuration class
class Config {
  final CardConfig card;
  final LayoutConfig layout;
  final SnapConfig snapArea;
  final AppConfig app;
  final SketchyButtonConfig sketchyButton;
  final BackgroundConfig background;
  final DialogConfig dialogs;
  final AnimationConfig animations;
  final SpacingConfig spacing;
  final ColorConfig colors;
  final SketchyConfig sketchy;
  final BoardConfig board;
  final GameConfig game;

  Config.fromJson(Map<String, dynamic> json)
      : card = CardConfig.fromJson(json['card']),
        layout = LayoutConfig.fromJson(json['layout']),
        snapArea = SnapConfig.fromJson(json['snapArea']),
        app = AppConfig.fromJson(json['app']),
        sketchyButton = SketchyButtonConfig.fromJson(json['sketchyButton']),
        background = BackgroundConfig.fromJson(json['background']),
        dialogs = DialogConfig.fromJson(json['dialogs']),
        animations = AnimationConfig.fromJson(json['animations']),
        spacing = SpacingConfig.fromJson(json['spacing']),
        colors = ColorConfig.fromJson(json['colors']),
        sketchy = SketchyConfig.fromJson(json['sketchy']),
        board = BoardConfig.fromJson(json['board']),
        game = GameConfig.fromJson(json['game']);

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