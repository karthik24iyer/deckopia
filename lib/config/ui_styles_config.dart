import 'package:flutter/material.dart';
import 'assets_config.dart';

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
