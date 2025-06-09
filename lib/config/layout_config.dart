// Layout configurations
class LayoutContainers {
  final double width;
  final double deckHeight;
  final double playAreaHeight;

  LayoutContainers.fromJson(Map<String, dynamic> json)
      : width = json['width'].toDouble(),
        deckHeight = json['deckHeight'].toDouble(),
        playAreaHeight = json['playAreaHeight'].toDouble();
}

class BoardLayout {
  final double horizontalPadding;
  final double verticalPadding;
  final double centerSpacing;
  
  BoardLayout.fromJson(Map<String, dynamic> json)
      : horizontalPadding = json['horizontalPadding'].toDouble(),
        verticalPadding = json['verticalPadding'].toDouble(),
        centerSpacing = json['centerSpacing'].toDouble();
}

class UILayout {
  final double boxWidth;
  final double boxHeight;
  final double menuWidth;

  UILayout.fromJson(Map<String, dynamic> json)
      : boxWidth = json['boxWidth'].toDouble(),
        boxHeight = json['boxHeight'].toDouble(),
        menuWidth = json['menuWidth'].toDouble();
}

class DemoLayout {
  final double cardWidth;
  final double cardHeight;
  final double cardBorderRadius;

  DemoLayout.fromJson(Map<String, dynamic> json)
      : cardWidth = json['cardWidth'].toDouble(),
        cardHeight = json['cardHeight'].toDouble(),
        cardBorderRadius = json['cardBorderRadius'].toDouble();
}

class LayoutConfig {
  final LayoutContainers containers;
  final BoardLayout board;
  final UILayout ui;
  final DemoLayout demo;

  LayoutConfig.fromJson(Map<String, dynamic> json)
      : containers = LayoutContainers.fromJson(json['containers']),
        board = BoardLayout.fromJson(json['board']),
        ui = UILayout.fromJson(json['ui']),
        demo = DemoLayout.fromJson(json['demo']);
}
