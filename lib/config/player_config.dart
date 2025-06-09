import 'package:flutter/material.dart';
import 'assets_config.dart';

// Player configurations
class PlayerConfig {
  final int nameLength;
  final List<Color> colorOptions;

  PlayerConfig.fromJson(Map<String, dynamic> json)
      : nameLength = json['nameLength'],
        colorOptions = (json['colorOptions'] as List)
            .map((colorHex) => parseColor(colorHex))
            .toList();
}
