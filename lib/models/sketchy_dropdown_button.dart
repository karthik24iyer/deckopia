import 'package:flutter/material.dart';
import 'package:deckopia/helper/sketchy_painter.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:deckopia/config/app_config.dart';
import 'dart:math' show Random;

class SketchyDropdownMenuItem<T> extends DropdownMenuItem<T> {
  SketchyDropdownMenuItem({
    Key? key,
    required T value,
    required Widget child,
  }) : super(key: key, value: value, child: child);
}

class SketchyDropdownButton<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final int seed;
  final double? width;
  final double? height;
  final TextStyle? style;
  final String fontFamily;
  final double? menuWidth; // Add parameter for menu width

  const SketchyDropdownButton({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.seed,
    this.width,
    this.height,
    this.style,
    this.fontFamily = 'CaveatBrush',
    this.menuWidth, // Optional menu width parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorConfig = context.config.colors;
    final buttonConfig = context.config.sketchyButton;
    final sketchyConfig = context.config.sketchy;
    final shadow = buttonConfig.shadow;

    return Container(
      width: width,
      height: height ?? buttonConfig.height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(shadow.opacity),
            blurRadius: shadow.blur,
            offset: Offset(shadow.offsetX, shadow.offsetY),
          ),
        ],
      ),
      child: CustomPaint(
        painter: SketchyButtonPainter(
          colorConfig.buttonColors.yellow, // Yellow color from Load button
          seed,
          buttonConfig.noiseMagnitude,
          buttonConfig.curveNoiseMagnitude,
          sketchyConfig,
        ),
        child: Material(
          color: Colors.transparent,
          child: PopupMenuButton<T>(
            initialValue: value,
            onSelected: onChanged,
            color: colorConfig.buttonColors.yellow, // Yellow color for menu background
            elevation: 8,
            constraints: BoxConstraints(
              minWidth: menuWidth ?? width ?? 140, // Use menuWidth or fall back to button width
              maxWidth: menuWidth ?? width ?? 140, // Constrain max width to ensure consistent size
            ),
            itemBuilder: (context) {
              return items.map((item) {
                return PopupMenuItem<T>(
                  value: item.value,
                  // Apply proper font styling to menu items
                  child: Center(
                    child: Text(
                      item.value.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: fontFamily,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList();
            },
            offset: const Offset(0, 40),
            shape: _SketchyMenuBorder(
              noiseMagnitude: buttonConfig.noiseMagnitude,
              sketchyConfig: sketchyConfig,
              seed: seed + 100,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toString(),
                      style: style ?? TextStyle(
                        fontSize: 20,
                        fontFamily: fontFamily,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SketchyMenuBorder extends ShapeBorder {
  final double noiseMagnitude;
  final SketchyConfig sketchyConfig;
  final int seed;

  const _SketchyMenuBorder({
    required this.noiseMagnitude,
    required this.sketchyConfig,
    required this.seed,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _createSketchyPath(rect);
  }

  Path _createSketchyPath(Rect rect) {
    final random = Random(seed);
    final path = Path();
    
    // Create points with noise
    final points = <Offset>[];
    final segmentLength = sketchyConfig.segmentLength;
    
    final horizontalSegments = (rect.width / segmentLength).ceil();
    final verticalSegments = (rect.height / segmentLength).ceil();
    
    // Top line
    for (int i = 0; i <= horizontalSegments; i++) {
      points.add(Offset(
        rect.left + i * segmentLength + _addNoise(random),
        rect.top + _addNoise(random)
      ));
    }
    
    // Right line
    for (int i = 0; i <= verticalSegments; i++) {
      points.add(Offset(
        rect.right + _addNoise(random),
        rect.top + i * segmentLength + _addNoise(random)
      ));
    }
    
    // Bottom line
    for (int i = horizontalSegments; i >= 0; i--) {
      points.add(Offset(
        rect.left + i * segmentLength + _addNoise(random),
        rect.bottom + _addNoise(random)
      ));
    }
    
    // Left line
    for (int i = verticalSegments; i >= 0; i--) {
      points.add(Offset(
        rect.left + _addNoise(random),
        rect.top + i * segmentLength + _addNoise(random)
      ));
    }
    
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    path.close();
    return path;
  }
  
  double _addNoise(Random random) {
    return (random.nextDouble() - 0.5) * noiseMagnitude * 2;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = sketchyConfig.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = sketchyConfig.strokeWidth;
    
    canvas.drawPath(_createSketchyPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return _SketchyMenuBorder(
      noiseMagnitude: noiseMagnitude * t,
      sketchyConfig: sketchyConfig,
      seed: seed,
    );
  }
}