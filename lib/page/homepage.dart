import 'package:flutter/material.dart';
import 'package:deckopia/util/config_provider.dart';
import '../models/sketchy_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfig = context.appConfig;
    final colorConfig = context.config.colors;
    final spacingConfig = context.config.spacing;
    final backgroundConfig = context.config.background;
    final shadowConfig = context.config.sketchyButton.shadow;

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
                    Colors.white.withOpacity(colorConfig.whiteGradient.top),
                    Colors.white.withOpacity(colorConfig.whiteGradient.bottom),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                context.assetsConfig.images.homeBackground,
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(backgroundConfig.imageOpacity),
              ),
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: appConfig.theme.backgroundColor.withOpacity(colorConfig.standardOverlay),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    appConfig.theme.backgroundColor.withOpacity(backgroundConfig.overlay.opacityTop),
                    appConfig.theme.backgroundColor.withOpacity(backgroundConfig.overlay.opacityBottom),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Container(
            padding: EdgeInsets.all(spacingConfig.default_),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: appConfig.theme.backgroundColor.withOpacity(colorConfig.lightOverlay),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(shadowConfig.opacity),
                          blurRadius: shadowConfig.blur * 2,
                          offset: Offset(
                            shadowConfig.offsetX, 
                            shadowConfig.offsetY * 2
                          ),
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
                  SizedBox(height: spacingConfig.large),
                  LayoutBuilder(
                    builder: (context, constraints) => Column(
                      children: [
                        SketchyButton(
                          text: 'Join Game',
                          color: colorConfig.buttonColors.lightBlue,
                          onPressed: () => Navigator.pushNamed(context, '/join-game'),
                          seed: 1,
                          width: constraints.maxWidth / 2,
                        ),
                        SizedBox(height: spacingConfig.default_),
                        SketchyButton(
                          text: 'Host Game',
                          color: colorConfig.buttonColors.lightBlue,
                          onPressed: () => Navigator.pushNamed(context, '/host-game'),
                          seed: 2,
                          width: constraints.maxWidth / 2,
                        ),
                        SizedBox(height: spacingConfig.default_),
                        SketchyButton(
                          text: 'Settings',
                          color: colorConfig.buttonColors.yellow,
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                          seed: 3,
                          width: constraints.maxWidth / 2,
                        ),
                        SizedBox(height: spacingConfig.default_),
                        SketchyButton(
                          text: 'What to Play!',
                          color: colorConfig.buttonColors.pink,
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