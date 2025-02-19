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