import '../config/config.dart';

enum CardSuit {
  spade,
  heart,
  dice,
  club;

  String get asString => name;
}

enum CardRank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king;

  String get asString {
    switch (this) {
      case CardRank.ace: return 'ace';
      case CardRank.two: return '2';
      case CardRank.three: return '3';
      case CardRank.four: return '4';
      case CardRank.five: return '5';
      case CardRank.six: return '6';
      case CardRank.seven: return '7';
      case CardRank.eight: return '8';
      case CardRank.nine: return '9';
      case CardRank.ten: return '10';
      case CardRank.jack: return 'jack';
      case CardRank.queen: return 'queen';
      case CardRank.king: return 'king';
    }
  }
}

class PlayingCardModel {
  final CardSuit? suit;
  final CardRank? rank;
  final bool isJoker;
  final String jokerColor;

  PlayingCardModel({
    this.suit,
    this.rank,
    this.isJoker = false,
    this.jokerColor = 'red',
  }) : assert(
  (isJoker && suit == null && rank == null) ||
      (!isJoker && suit != null && rank != null),
  'Card must be either a regular card with suit and rank or a joker'
  );

  String get id => isJoker ? 'joker-$jokerColor' : '${suit!.asString}-${rank!.asString}';

  Map<String, String> toMap() => {
    'suit': isJoker ? 'joker' : suit!.asString,
    'rank': isJoker ? jokerColor : rank!.asString,
  };

  static List<PlayingCardModel> generateDeck({bool includeJokers = false, DeckConfig? deckConfig}) {
    List<PlayingCardModel> deck = [];

    // Add standard cards
    for (var suit in CardSuit.values) {
      for (var rank in CardRank.values) {
        deck.add(PlayingCardModel(suit: suit, rank: rank));
      }
    }

    // Add jokers if requested
    bool shouldIncludeJokers = includeJokers;
    if (deckConfig != null) {
      shouldIncludeJokers = includeJokers || deckConfig.jokers.includeByDefault;
    }
    
    if (shouldIncludeJokers && deckConfig != null) {
      for (var color in deckConfig.jokers.colors) {
        deck.add(PlayingCardModel(isJoker: true, jokerColor: color));
      }
    } else if (shouldIncludeJokers) {
      // Fallback for when no config is provided
      deck.add(PlayingCardModel(isJoker: true, jokerColor: 'red'));
      deck.add(PlayingCardModel(isJoker: true, jokerColor: 'black'));
    }

    return deck;
  }
}