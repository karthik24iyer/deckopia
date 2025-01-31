import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/game_rule.dart';

Future<List<Section>> loadSections() async {
  try {
    String jsonString = await rootBundle.loadString('metadata/actions.json');
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
