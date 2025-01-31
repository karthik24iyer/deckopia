import 'package:flutter/material.dart';

// Card style constants
class CardProperties {
  // Card dimensions
  static const double width = 100.0;
  static const double height = 150.0;
  static const double cornerRadius = 10.0;

  // Spacing and offsets
  static const double deckCardOffset = 2.0;
  static const double cornerPadding = 10.0;

  // Font sizes
  static const double cornerFontSize = 24.0;
  static const double centerSymbolSize = 50.0;

  // Colors
  static const Color cardBackground = Colors.white;
  static const Color redSuits = Colors.red;
  static const Color blackSuits = Colors.black;

  // Shadow properties
  static const double shadowSpread = 2.0;
  static const double shadowBlur = 5.0;
  static const Offset shadowOffset = Offset(0, 3);
  static const double shadowOpacity = 0.5;

  // Container sizes
  static const double containerWidth = 260.0;
  static const double deckHeight = 400.0;
  static const double playAreaHeight = 360.0;
}

class PlayingCardOld {
  final String rank;
  final String suit;
  final Color color;

  PlayingCardOld(this.rank, this.suit, this.color);

  // Factory method to create a card with standard color based on suit
  factory PlayingCardOld.create(String rank, String suit) {
    final color = (suit == '♥' || suit == '♦')
        ? CardProperties.redSuits
        : CardProperties.blackSuits;
    return PlayingCardOld(rank, suit, color);
  }
}

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final List<PlayingCardOld> deck = [];
  final List<PlayingCardOld> playArea = [];

  @override
  void initState() {
    super.initState();
    _initializeDeck();
  }

  void _initializeDeck() {
    final ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    final suits = ['♥', '♦', '♣', '♠'];

    // Initialize play area with Ace of Spades
    playArea.add(PlayingCardOld.create('A', '♠'));

    // Initialize deck with remaining cards
    for (var suit in suits) {
      for (var rank in ranks) {
        if (!(rank == 'A' && suit == '♠')) {
          deck.add(PlayingCardOld.create(rank, suit));
        }
      }
    }
  }

  Widget _buildCardCorner(PlayingCardOld card, {bool isBottom = false}) {
    Widget corner = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.suit,
          style: TextStyle(
            fontSize: CardProperties.cornerFontSize,
            color: card.color,
          ),
        ),
        Text(
          card.rank,
          style: TextStyle(
            fontSize: CardProperties.cornerFontSize,
            color: card.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (isBottom) {
      corner = Transform.rotate(
        angle: 3.14159,
        child: corner,
      );
    }

    return corner;
  }

  Widget _buildCard(PlayingCardOld card, {bool isDeck = false, int index = 0}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isDeck) {
            playArea.add(deck.removeAt(index));
          } else {
            deck.add(playArea.removeAt(index));
          }
        });
      },
      child: Container(
        width: CardProperties.width,
        height: CardProperties.height,
        margin: EdgeInsets.only(top: isDeck ? index * CardProperties.deckCardOffset : 0),
        decoration: BoxDecoration(
          color: CardProperties.cardBackground,
          borderRadius: BorderRadius.circular(CardProperties.cornerRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(CardProperties.shadowOpacity),
              spreadRadius: CardProperties.shadowSpread,
              blurRadius: CardProperties.shadowBlur,
              offset: CardProperties.shadowOffset,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Top left corner
            Positioned(
              top: CardProperties.cornerPadding,
              left: CardProperties.cornerPadding,
              child: _buildCardCorner(card),
            ),
            // Center symbol
            Center(
              child: Text(
                card.suit,
                style: TextStyle(
                  fontSize: CardProperties.centerSymbolSize,
                  color: card.color,
                ),
              ),
            ),
            // Bottom right corner
            Positioned(
              bottom: CardProperties.cornerPadding,
              right: CardProperties.cornerPadding,
              child: _buildCardCorner(card, isBottom: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardArea(List<PlayingCardOld> cards, {bool isDeck = false}) {
    return SizedBox(
      width: CardProperties.containerWidth,
      height: isDeck ? CardProperties.deckHeight : CardProperties.playAreaHeight,
      child: Stack(
        children: [
          for (int i = 0; i < cards.length; i++)
            Positioned(
              top: isDeck ? i * CardProperties.deckCardOffset : 0,
              left: 0,
              child: _buildCard(cards[i], isDeck: isDeck, index: i),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Simulator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCardArea(deck, isDeck: true),  // Deck on top
            _buildCardArea(playArea),            // Play area on bottom
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Simulator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CardPage(),
    );
  }
}