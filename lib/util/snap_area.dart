import 'package:deckopia/config/snap_area_config.dart';
import 'package:deckopia/util/config_provider.dart';
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
    final snapAreaConfig = context.snapAreaConfig;
    final style = snapAreaConfig.style;

    return Positioned(
      left: config.position.dx,
      top: config.position.dy,
      child: Container(
        width: config.size.width,
        height: config.size.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(style.borderOpacity)),
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        child: Column(
          children: [
            if (label.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(style.labelPadding),
                child: Text(
                  label,
                  style: TextStyle(
                    color: style.borderColor,
                    fontSize: style.labelTextSize,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}