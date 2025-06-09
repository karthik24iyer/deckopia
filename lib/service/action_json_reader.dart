import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../config/game_rule.dart';
import '../config/config.dart';

Future<List<Section>> loadSections() async {
  try {
    // Load configuration to get metadata path
    final config = await Config.load();
    String jsonString = await rootBundle.loadString(config.assets.metadata.actionsPath);
    final jsonResponse = json.decode(jsonString);
    //print(jsonResponse); // Add this line to debug JSON content
    List<Section> sections = (jsonResponse['sections'] as List)
        .map((data) => Section.fromJson(data))
        .toList();
    return sections;
  } catch (e) {
    print('Error loading JSON: $e');
    rethrow;
  }
}
