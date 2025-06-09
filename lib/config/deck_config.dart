// Deck configurations
class DeckJokers {
  final List<String> colors;
  final bool includeByDefault;

  DeckJokers.fromJson(Map<String, dynamic> json)
      : colors = List<String>.from(json['colors']),
        includeByDefault = json['includeByDefault'];
}

class DeckConfig {
  final int cardsPerDeck;
  final DeckJokers jokers;

  DeckConfig.fromJson(Map<String, dynamic> json)
      : cardsPerDeck = json['cardsPerDeck'],
        jokers = DeckJokers.fromJson(json['jokers']);
}
