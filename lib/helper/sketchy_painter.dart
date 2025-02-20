import 'package:flutter/material.dart';
import 'dart:math' as math;

class SketchyButtonPainter extends CustomPainter {
  final Color color;
  final int seed;
  late final math.Random random;
  Path? _cachedPath;

  SketchyButtonPainter(this.color, this.seed) {
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
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(_cachedPath!, paint);
  }

  Path getSketchyPath(Size size) {
    final path = Path();

    // Add random offsets to make it look hand-drawn
    final topLeft = Offset(
      addNoise(0, 2),
      addNoise(0, 2),
    );
    final topRight = Offset(
      addNoise(size.width, 2),
      addNoise(0, 2),
    );
    final bottomRight = Offset(
      addNoise(size.width, 2),
      addNoise(size.height, 2),
    );
    final bottomLeft = Offset(
      addNoise(0, 2),
      addNoise(size.height, 2),
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
      start.dx + (end.dx - start.dx) / 3 + addNoise(0, 3),
      start.dy + (end.dy - start.dy) / 3 + addNoise(0, 3),
    );
    final controlPoint2 = Offset(
      start.dx + (end.dx - start.dx) * 2 / 3 + addNoise(0, 3),
      start.dy + (end.dy - start.dy) * 2 / 3 + addNoise(0, 3),
    );

    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
    );
  }

  double addNoise(double value, double magnitude) {
    return value + (random.nextDouble() - 0.9) * magnitude;
  }

  @override
  bool shouldRepaint(covariant SketchyButtonPainter oldDelegate) {
    return color != oldDelegate.color || seed != oldDelegate.seed;
  }
}

class SketchyContainerPainter extends CustomPainter {
  final int seed;

  SketchyContainerPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final points = <Offset>[];
    final segmentLength = 20.0;

    final horizontalSegments = (size.width / segmentLength).ceil();
    final verticalSegments = (size.height / segmentLength).ceil();

    // Top line
    for (int i = 0; i <= horizontalSegments; i++) {
      points.add(Offset(
          i * segmentLength + random.nextDouble() * 4 - 2,
          random.nextDouble() * 4 - 2
      ));
    }

    // Right line
    for (int i = 0; i <= verticalSegments; i++) {
      points.add(Offset(
          size.width + random.nextDouble() * 4 - 2,
          i * segmentLength + random.nextDouble() * 4 - 2
      ));
    }

    // Bottom line
    for (int i = horizontalSegments; i >= 0; i--) {
      points.add(Offset(
          i * segmentLength + random.nextDouble() * 4 - 2,
          size.height + random.nextDouble() * 4 - 2
      ));
    }

    // Left line
    for (int i = verticalSegments; i >= 0; i--) {
      points.add(Offset(
          random.nextDouble() * 4 - 2,
          i * segmentLength + random.nextDouble() * 4 - 2
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SketchyCircle extends CustomPainter {
  final Color color;
  final int seed;
  final bool isSelected;

  SketchyCircle(this.color, this.seed, this.isSelected);

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
      ..color = isSelected ? Colors.black : Colors.black38
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2 : 1;

    const numberOfPoints = 20;
    var path = Path();
    var firstPoint = true;

    for (var i = 0; i <= numberOfPoints; i++) {
      final angle = (i / numberOfPoints) * 2 * math.pi;
      final variance = random.nextDouble() * 4 - 2;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
