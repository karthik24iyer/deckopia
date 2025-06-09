import 'package:flutter/material.dart';

// Color utility function
Color parseColor(String hexColor) {
  hexColor = hexColor.replaceFirst('#', '');
  if (hexColor.length == 8) {
    return Color(int.parse('0x$hexColor'));
  }
  return Color(int.parse('0xFF$hexColor'));
}

// Asset configurations
class CardAssets {
  final String basePath;
  final String backCardPath;
  final String cardTemplate;

  CardAssets.fromJson(Map<String, dynamic> json)
      : basePath = json['basePath'],
        backCardPath = json['backCardPath'],
        cardTemplate = json['cardTemplate'];

  String getCardPath(String suit, String rank) {
    return cardTemplate.replaceAll('{suit}', suit).replaceAll('{rank}', rank);
  }
}

class MetadataAssets {
  final String actionsPath;

  MetadataAssets.fromJson(Map<String, dynamic> json)
      : actionsPath = json['actionsPath'];
}

class ImageAssets {
  final String homeBackground;

  ImageAssets.fromJson(Map<String, dynamic> json)
      : homeBackground = json['homeBackground'];
}

class AssetsConfig {
  final CardAssets cards;
  final MetadataAssets metadata;
  final ImageAssets images;

  AssetsConfig.fromJson(Map<String, dynamic> json)
      : cards = CardAssets.fromJson(json['cards']),
        metadata = MetadataAssets.fromJson(json['metadata']),
        images = ImageAssets.fromJson(json['images']);
}
