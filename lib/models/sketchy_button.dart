import 'package:flutter/material.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:deckopia/helper/sketchy_painter.dart';

class SketchyButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;
  final int seed;
  final double? width;
  final double height;
  final bool isLoading;

  const SketchyButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.seed,
    this.width,
    this.height = 60,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfig = context.appConfig;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: SketchyButtonPainter(color, seed),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(
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
  }
}