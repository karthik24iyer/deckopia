import 'package:deckopia/util/config_provider.dart';
import 'package:flutter/material.dart';

import '../helper/sketchy_button_painter.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfig = context.appConfig;

    return Scaffold(
      backgroundColor: appConfig.theme.backgroundColor,
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Deckopia - Digital Deck',
                style: TextStyle(
                  fontSize: appConfig.theme.fonts.titleSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: appConfig.theme.fonts.fontFamily,
                ),
              ),
              const SizedBox(height: 40),
              _buildSketchyButton(
                context,
                'Join Game',
                Colors.lightBlue.shade100,
                    () => print('Join Game pressed'),
                1,
              ),
              const SizedBox(height: 20),
              _buildSketchyButton(
                context,
                'Host Game',
                Colors.lightBlue.shade100,
                    () => print('Host Game pressed'),
                2,
              ),
              const SizedBox(height: 20),
              _buildSketchyButton(
                context,
                'Settings',
                Colors.yellow.shade100,
                    () => print('Settings pressed'),
                3,
              ),
              const SizedBox(height: 20),
              _buildSketchyButton(
                context,
                'What to Play!',
                Colors.pink.shade100,
                    () => Navigator.pushNamed(context, '/board'),
                4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSketchyButton(
      BuildContext context,
      String text,
      Color color,
      VoidCallback onPressed,
      int seed,
      ) {
    final appConfig = context.appConfig;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth/2,
          height: 60,
          child: CustomPaint(
            painter: SketchyButtonPainter(color, seed),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: appConfig.theme.fonts.buttonTextSize,
                      color: Colors.black87,
                      fontFamily: appConfig.theme.fonts.fontFamily,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}