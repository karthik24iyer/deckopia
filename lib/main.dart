import 'package:deckopia/helper/page_transition.dart';
import 'package:deckopia/page/board.dart';
import 'package:deckopia/page/join_game.dart';
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
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const HomePage(),
        onGenerateRoute: (settings) {
          Widget page;

          switch (settings.name) {
            case '/host-game':
              page = const GameSelectionScreen();
              break;
            case '/join-game':
              page = const JoinGameScreen();
              break;
            case '/settings':
              page = const SettingsScreen();
              break;
            case '/board':
              page = const BoardScreen();
              break;

            default:
              page = const HomePage();
          }

          return PageTransition(child: page);
        },
      ),
    );
  }
}
// () => Navigator.pushNamed(context, '/board'),

// case '/host-game-temp':
//   final args = settings.arguments as String; // Your custom arguments class
//   page = GameSelectionScreen(gameId: args.gameId);
//   break;
// Navigator.pushNamed(
//   context,
//   '/host-game',
//   arguments: GameArguments(gameId: 'abc123'),
// );