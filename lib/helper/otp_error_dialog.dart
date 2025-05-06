import 'package:flutter/material.dart';
import 'package:deckopia/util/config_provider.dart';
import '../helper/sketchy_painter.dart';
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
    final dialogConfig = context.config.dialogs.otpError;
    final sketchyConfig = context.config.sketchy;
    final sketchyButtonConfig = context.config.sketchyButton;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: CustomPaint(
        painter: SketchyButtonPainter(
          dialogConfig.backgroundColor,
          0, // Using 0 as seed for container
          sketchyButtonConfig.noiseMagnitude,
          sketchyButtonConfig.curveNoiseMagnitude,
          sketchyConfig,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: dialogConfig.padding.horizontal,
            vertical: dialogConfig.padding.vertical,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Umm.. you sure that\'s right?',
                style: TextStyle(
                  fontSize: dialogConfig.fontSize,
                  fontFamily: appConfig.theme.fonts.fontFamily,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: dialogConfig.titleSpacing),
              SketchyButton(
                text: 'Retry',
                color: dialogConfig.retryColor,
                onPressed: onRetry,
                seed: 1,
              ),
              SizedBox(height: dialogConfig.spacing),
              SketchyButton(
                text: 'I\'m done with this',
                color: dialogConfig.exitColor,
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