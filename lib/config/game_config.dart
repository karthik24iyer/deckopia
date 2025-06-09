import 'package:flutter/material.dart';
import 'assets_config.dart';

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
class FlipCardAnimation {
  final Duration duration;

  FlipCardAnimation.fromJson(Map<String, dynamic> json)
      : duration = Duration(milliseconds: json['durationMs']);
}

class AnimationConfig {
  final int pageTransitionDuration;
  final FlipCardAnimation flipCard;

  AnimationConfig.fromJson(Map<String, dynamic> json)
      : pageTransitionDuration = json['pageTransition']['duration'],
        flipCard = FlipCardAnimation.fromJson(json['flipCard']);
}

// Game configurations
class OtpConfig {
  final int length;
  final String mockValue;
  final int delayMs;

  OtpConfig.fromJson(Map<String, dynamic> json)
      : length = json['length'],
        mockValue = json['mockValue'],
        delayMs = json['delayMs'];
}

class GameConfig {
  final OtpConfig otp;

  GameConfig.fromJson(Map<String, dynamic> json)
      : otp = OtpConfig.fromJson(json['otp']);

  // Legacy getters for backward compatibility
  String get mockOTP => otp.mockValue;
  int get otpDelay => otp.delayMs;
}
