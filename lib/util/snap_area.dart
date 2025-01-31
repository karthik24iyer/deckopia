import 'package:deckopia/config/snap_area_config.dart';
import 'package:flutter/material.dart';

class SnapArea extends StatelessWidget {
  final SnapAreaConfig config;
  final String label;

  const SnapArea({
    super.key,
    required this.config,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: config.position.dx,
      top: config.position.dy,
      child: Container(
        width: config.size.width,
        height: config.size.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.blue.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}