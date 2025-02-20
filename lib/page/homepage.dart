import 'package:flutter/material.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:deckopia/helper/page_transition.dart';

import '../models/sketchy_button.dart';
import 'join_game.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfig = context.appConfig;

    return Scaffold(
      backgroundColor: appConfig.theme.backgroundColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.3),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/home_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: appConfig.theme.backgroundColor.withOpacity(0.85),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    appConfig.theme.backgroundColor.withOpacity(0.95),
                    appConfig.theme.backgroundColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: appConfig.theme.backgroundColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Deckopia - Digital Deck',
                      style: TextStyle(
                        fontSize: appConfig.theme.fonts.titleSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: appConfig.theme.fonts.fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  LayoutBuilder(
                    builder: (context, constraints) => Column(
                      children: [
                        SketchyButton(
                          text: 'Join Game',
                          color: Colors.lightBlue.shade100,
                          onPressed: () => Navigator.pushNamed(context, '/join-game'),
                          seed: 1,
                          width: constraints.maxWidth / 2,
                        ),
                        const SizedBox(height: 20),
                        SketchyButton(
                          text: 'Host Game',
                          color: Colors.lightBlue.shade100,
                          onPressed: () => print('Host Game pressed'),
                          seed: 2,
                          width: constraints.maxWidth / 2,
                        ),
                        const SizedBox(height: 20),
                        SketchyButton(
                          text: 'Settings',
                          color: Colors.yellow.shade100,
                          onPressed: () => print('Settings pressed'),
                          seed: 3,
                          width: constraints.maxWidth / 2,
                        ),
                        const SizedBox(height: 20),
                        SketchyButton(
                          text: 'What to Play!',
                          color: Colors.pink.shade100,
                          onPressed: () => Navigator.pushNamed(context, '/board'),
                          seed: 4,
                          width: constraints.maxWidth / 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}