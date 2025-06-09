import 'package:flutter/material.dart';
import 'package:deckopia/helper/sketchy_painter.dart';
import 'package:deckopia/util/config_provider.dart';

class CardSettings extends StatelessWidget {
  final TextEditingController cardsController;
  final String? cardsError;
  final bool fullDistribution;
  final GlobalKey cardsInfoKey;
  final Function(bool?) onFullDistributionChanged;
  final Function() onTooltipPressed;

  const CardSettings({
    super.key,
    required this.cardsController,
    this.cardsError,
    required this.fullDistribution,
    required this.cardsInfoKey,
    required this.onFullDistributionChanged,
    required this.onTooltipPressed,
  });

  @override
  Widget build(BuildContext context) {
    final layoutConfig = context.layoutConfig;
    
    return Column(
      children: [
        // Cards Row
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Cards',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CaveatBrush',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: cardsInfoKey,
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: onTooltipPressed,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Cards input with sketchy style
            Container(
              width: layoutConfig.ui.boxWidth,
              height: layoutConfig.ui.boxHeight,
              child: Stack(
                children: [
                  // Sketchy background
                  CustomPaint(
                    painter: SketchyButtonPainter(
                      context.config.colors.buttonColors.yellow,
                      50,
                      context.config.sketchyButton.noiseMagnitude,
                      context.config.sketchyButton.curveNoiseMagnitude,
                      context.config.sketchy,
                    ),
                    child: Container(
                      width: layoutConfig.ui.boxWidth,
                      height: layoutConfig.ui.boxHeight,
                    ),
                  ),
                  // Text input
                  Center(
                    child: TextField(
                      controller: cardsController,
                      enabled: !fullDistribution,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'CaveatBrush',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // Error message
        if (cardsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              cardsError!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Full Distribution Checkbox
        Row(
          children: [
            Checkbox(
              value: fullDistribution,
              onChanged: onFullDistributionChanged,
              activeColor: context.config.colors.buttonColors.lightBlue,
            ),
            const Expanded(
              child: Text(
                'Distribute all cards equally among players',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'CaveatBrush',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
