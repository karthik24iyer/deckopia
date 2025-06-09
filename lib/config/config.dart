import 'dart:convert';
import 'package:flutter/services.dart';

// Export all configuration modules
export 'assets_config.dart';
export 'deck_config.dart';
export 'player_config.dart';
export 'card_config.dart';
export 'layout_config.dart';
export 'app_theme_config.dart';
export 'ui_styles_config.dart';
export 'board_config.dart';
export 'game_config.dart';

// Import all configuration modules
import 'assets_config.dart';
import 'deck_config.dart';
import 'player_config.dart';
import 'card_config.dart';
import 'layout_config.dart';
import 'app_theme_config.dart';
import 'ui_styles_config.dart';
import 'board_config.dart';
import 'game_config.dart';

// Main configuration class
class Config {
  final AssetsConfig assets;
  final DeckConfig deck;
  final PlayerConfig player;
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
      : assets = AssetsConfig.fromJson(json['assets']),
        deck = DeckConfig.fromJson(json['deck']),
        player = PlayerConfig.fromJson(json['player']),
        card = CardConfig.fromJson(json['card']),
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
