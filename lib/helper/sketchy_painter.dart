import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../config/config.dart';

class SketchyButtonPainter extends CustomPainter {
  final Color color;
  final int seed;
  final double noiseMagnitude;
  final double curveNoiseMagnitude;
  final SketchyConfig sketchyConfig; // Use config object instead of individual parameters
  late final math.Random random;
  Path? _cachedPath;

  SketchyButtonPainter(
    this.color, 
    this.seed, 
    this.noiseMagnitude, 
    this.curveNoiseMagnitude,
    this.sketchyConfig,
  ) {
    random = math.Random(seed); // Initialize with fixed seed
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Create the path only once and cache it
    _cachedPath ??= getSketchyPath(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw the fill
    canvas.drawPath(_cachedPath!, paint);

    // Draw the border
    paint
      ..color = sketchyConfig.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = sketchyConfig.strokeWidth;

    canvas.drawPath(_cachedPath!, paint);
  }

  Path getSketchyPath(Size size) {
    final path = Path();

    // Add random offsets to make it look hand-drawn
    final topLeft = Offset(
      addNoise(0, noiseMagnitude),
      addNoise(0, noiseMagnitude),
    );
    final topRight = Offset(
      addNoise(size.width, noiseMagnitude),
      addNoise(0, noiseMagnitude),
    );
    final bottomRight = Offset(
      addNoise(size.width, noiseMagnitude),
      addNoise(size.height, noiseMagnitude),
    );
    final bottomLeft = Offset(
      addNoise(0, noiseMagnitude),
      addNoise(size.height, noiseMagnitude),
    );

    // Create slightly curved lines between points
    path.moveTo(topLeft.dx, topLeft.dy);

    // Top line
    _addCurvedLine(path, topLeft, topRight);

    // Right line
    _addCurvedLine(path, topRight, bottomRight);

    // Bottom line
    _addCurvedLine(path, bottomRight, bottomLeft);

    // Left line
    _addCurvedLine(path, bottomLeft, topLeft);

    return path;
  }

  void _addCurvedLine(Path path, Offset start, Offset end) {
    final controlPoint1 = Offset(
      start.dx + (end.dx - start.dx) * sketchyConfig.firstControlPoint + addNoise(0, curveNoiseMagnitude),
      start.dy + (end.dy - start.dy) * sketchyConfig.firstControlPoint + addNoise(0, curveNoiseMagnitude),
    );
    final controlPoint2 = Offset(
      start.dx + (end.dx - start.dx) * sketchyConfig.secondControlPoint + addNoise(0, curveNoiseMagnitude),
      start.dy + (end.dy - start.dy) * sketchyConfig.secondControlPoint + addNoise(0, curveNoiseMagnitude),
    );

    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
    );
  }

  double addNoise(double value, double magnitude) {
    return value + (random.nextDouble() - sketchyConfig.randomOffset) * magnitude;
  }

  @override
  bool shouldRepaint(covariant SketchyButtonPainter oldDelegate) {
    return color != oldDelegate.color || 
           seed != oldDelegate.seed ||
           noiseMagnitude != oldDelegate.noiseMagnitude ||
           curveNoiseMagnitude != oldDelegate.curveNoiseMagnitude;
  }
}

class SketchyContainerPainter extends CustomPainter {
  final int seed;
  final double noiseMagnitude;
  final SketchyConfig sketchyConfig;
  
  SketchyContainerPainter(
    this.seed, 
    this.sketchyConfig,
    this.noiseMagnitude,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()
      ..color = sketchyConfig.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = sketchyConfig.strokeWidth;

    final points = <Offset>[];
    final segmentLength = sketchyConfig.segmentLength;

    final horizontalSegments = (size.width / segmentLength).ceil();
    final verticalSegments = (size.height / segmentLength).ceil();

    // Top line
    for (int i = 0; i <= horizontalSegments; i++) {
      points.add(Offset(
          i * segmentLength + random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude,
          random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude
      ));
    }

    // Right line
    for (int i = 0; i <= verticalSegments; i++) {
      points.add(Offset(
          size.width + random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude,
          i * segmentLength + random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude
      ));
    }

    // Bottom line
    for (int i = horizontalSegments; i >= 0; i--) {
      points.add(Offset(
          i * segmentLength + random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude,
          size.height + random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude
      ));
    }

    // Left line
    for (int i = verticalSegments; i >= 0; i--) {
      points.add(Offset(
          random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude,
          i * segmentLength + random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude
      ));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SketchyContainerPainter oldDelegate) {
    return seed != oldDelegate.seed || 
           noiseMagnitude != oldDelegate.noiseMagnitude;
    // Skip config checks as they rarely change
  }
}

class SketchyCircle extends CustomPainter {
  final Color color;
  final int seed;
  final bool isSelected;
  final double noiseMagnitude;
  final SketchyConfig sketchyConfig;

  SketchyCircle(
    this.color, 
    this.seed, 
    this.isSelected,
    this.sketchyConfig,
    this.noiseMagnitude,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the main circle
    canvas.drawCircle(center, radius, paint);

    // Draw sketchy outline
    final outlinePaint = Paint()
      ..color = isSelected ? sketchyConfig.selectedBorderColor : sketchyConfig.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? sketchyConfig.selectedBorderWidth : sketchyConfig.borderWidth;
    
    var path = Path();
    var firstPoint = true;

    for (var i = 0; i <= sketchyConfig.numberOfPoints; i++) {
      final angle = (i / sketchyConfig.numberOfPoints) * 2 * math.pi;
      final variance = random.nextDouble() * noiseMagnitude * 2 - noiseMagnitude;
      final x = center.dx + (radius + variance) * math.cos(angle);
      final y = center.dy + (radius + variance) * math.sin(angle);

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant SketchyCircle oldDelegate) {
    return color != oldDelegate.color || 
           seed != oldDelegate.seed || 
           isSelected != oldDelegate.isSelected ||
           noiseMagnitude != oldDelegate.noiseMagnitude;
    // Skip config checks as they rarely change
  }
}
