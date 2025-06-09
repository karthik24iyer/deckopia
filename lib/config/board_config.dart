// Board configurations
class SnapAreaSizes {
  final double upperWidthFactor;
  final double upperHeightFactor;
  final double lowerWidthFactor;
  final double lowerHeightFactor;

  SnapAreaSizes.fromJson(Map<String, dynamic> json)
      : upperWidthFactor = json['upperWidthFactor'].toDouble(),
        upperHeightFactor = json['upperHeightFactor'].toDouble(),
        lowerWidthFactor = json['lowerWidthFactor'].toDouble(),
        lowerHeightFactor = json['lowerHeightFactor'].toDouble();
}

class RotationConfig {
  final double maxRadians;

  RotationConfig.fromJson(Map<String, dynamic> json)
      : maxRadians = json['maxRadians'].toDouble();
}

class BoardConfig {
  final double stackOffset;
  final SnapAreaSizes snapAreaSizes;
  final RotationConfig rotation;

  BoardConfig.fromJson(Map<String, dynamic> json)
      : stackOffset = json['stackOffset'].toDouble(),
        snapAreaSizes = SnapAreaSizes.fromJson(json['snapAreaSizes']),
        rotation = RotationConfig.fromJson(json['rotation']);
}
