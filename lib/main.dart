import 'package:deckopia/page/Board.dart';
import 'package:deckopia/page/settings.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'core/game_builder.dart';
import 'core/game_selection.dart';
import 'page/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await Config.load();
  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  final Config config;

  const MyApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return ConfigProvider(
      config: config,
      child: MaterialApp(
        debugShowCheckedModeBanner: config.app.theme.showDebugBanner,
        title: config.app.title,
        theme: ThemeData(
          primaryColor: config.app.theme.primaryColor,
        ),
        home: const HomePage(),
        routes: {
          '/game-selection': (context) => const GameSelectionScreen(),
          '/game-builder': (context) => const GameBuilderScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/board': (context) => const BoardScreen(),
        },
      ),
    );
  }
}