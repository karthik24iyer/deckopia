import 'package:flutter/material.dart';
import 'package:deckopia/models/sketchy_dropdown_button.dart';
import 'package:deckopia/util/config_provider.dart';

class TimeSettings extends StatelessWidget {
  final String time;
  final List<String> timeOptions;
  final GlobalKey timeInfoKey;
  final Function(String?) onTimeChanged;
  final Function() onTooltipPressed;

  const TimeSettings({
    super.key,
    required this.time,
    required this.timeOptions,
    required this.timeInfoKey,
    required this.onTimeChanged,
    required this.onTooltipPressed,
  });

  @override
  Widget build(BuildContext context) {
    final layoutConfig = context.layoutConfig;
    
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                'Time',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CaveatBrush',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: timeInfoKey,
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: onTooltipPressed,
              ),
            ],
          ),
        ),
        const Spacer(),
        SketchyDropdownButton<String>(
          width: layoutConfig.ui.boxWidth,
          height: layoutConfig.ui.boxHeight,
          menuWidth: layoutConfig.ui.menuWidth,
          value: time,
          seed: 30,
          fontFamily: 'CaveatBrush',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'CaveatBrush',
          ),
          onChanged: onTimeChanged,
          items: timeOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              alignment: Alignment.center,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
