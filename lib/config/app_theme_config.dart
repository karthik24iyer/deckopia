import 'package:flutter/material.dart';
import 'assets_config.dart';

// App theme configurations
class AppFonts {
  final String fontFamily;
  final double titleSize;
  final double buttonTextSize;

  AppFonts.fromJson(Map<String, dynamic> json)
      : fontFamily = json['fontFamily'],
        titleSize = json['titleSize'].toDouble(),
        buttonTextSize = json['buttonTextSize'].toDouble();
}

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
