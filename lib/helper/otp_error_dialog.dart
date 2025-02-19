import 'package:flutter/material.dart';
import 'package:deckopia/util/config_provider.dart';
import '../helper/sketchy_button_painter.dart';
import '../models/sketchy_button.dart';

class OtpErrorDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const OtpErrorDialog({
    Key? key,
    required this.onRetry,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfig = context.appConfig;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: CustomPaint(
        painter: SketchyButtonPainter(
          const Color(0xFFFFFDF0), // Light yellow background
          0, // Using 0 as seed for container
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Umm.. you sure that\'s right?',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: appConfig.theme.fonts.fontFamily,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SketchyButton(
                text: 'Retry',
                color: Colors.lightBlue.shade100,
                onPressed: onRetry,
                seed: 1,
              ),
              const SizedBox(height: 16),
              SketchyButton(
                text: 'I\'m done with this',
                color: Colors.red.shade100,
                onPressed: onExit,
                seed: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}