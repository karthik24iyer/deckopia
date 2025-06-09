import 'package:flutter/material.dart';
import 'package:deckopia/models/sketchy_button.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:deckopia/widgets/host_game/player_deck_controls.dart';
import 'package:deckopia/widgets/host_game/card_settings.dart';
import 'package:deckopia/widgets/host_game/time_settings.dart';
import 'package:deckopia/widgets/host_game/tooltip_helper.dart';

class HostGameScreen extends StatefulWidget {
  const HostGameScreen({Key? key}) : super(key: key);

  @override
  State<HostGameScreen> createState() => _HostGameScreenState();
}

class _HostGameScreenState extends State<HostGameScreen> {
  // Values for dropdowns and inputs
  int _players = 4;
  int _decks = 2;
  int _cards = 2;
  String _time = '30 sec';
  bool _fullDistribution = false;
  bool _advanced = false;

  // Controller for cards input
  final TextEditingController _cardsController = TextEditingController(text: '2');

  // Possible validation error
  String? _cardsError;

  // Keys for tooltips
  final GlobalKey _cardsInfoKey = GlobalKey();
  final GlobalKey _timeInfoKey = GlobalKey();

  // Tooltip helper
  final TooltipHelper _tooltipHelper = TooltipHelper();

  // Options for dropdowns
  final List<int> _playerOptions = List.generate(10, (index) => index + 1);
  final List<int> _deckOptions = List.generate(3, (index) => index + 1);
  final List<String> _timeOptions = ['10 sec', '20 sec', '30 sec', '1 min', '2 mins'];

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _cardsController.addListener(_validateCards);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Initialize cards with the default value from config
      _cards = _maxCardsPerPlayer;
      _cardsController.text = _cards.toString();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _cardsController.dispose();
    _tooltipHelper.dispose();
    super.dispose();
  }

  // Calculate max cards allowed per player
  int get _maxCardsPerPlayer {
    return (_decks * context.deckConfig.cardsPerDeck) ~/ _players;
  }

  // Validate card input
  void _validateCards() {
    setState(() {
      if (_fullDistribution) {
        _cards = _maxCardsPerPlayer;
        _cardsError = null;
        return;
      }

      final inputText = _cardsController.text;
      if (inputText.isEmpty) {
        _cardsError = null;
        return;
      }

      try {
        final inputValue = int.parse(inputText);
        _cards = inputValue;

        if (inputValue < 1) {
          _cardsError = 'Minimum 1 card required';
        } else if (inputValue > _maxCardsPerPlayer) {
          _cardsError = 'Number exceeds max possible for 1 player';
        } else {
          _cardsError = null;
        }
      } catch (e) {
        _cardsError = 'Enter a valid number';
      }
    });
  }

  // Event handlers for controls
  void _onPlayersChanged(int? newValue) {
    if (newValue != null) {
      setState(() {
        _players = newValue;
        if (_fullDistribution) {
          _cards = _maxCardsPerPlayer;
          _cardsController.text = _cards.toString();
        } else {
          _cards = _maxCardsPerPlayer;
          _cardsController.text = _cards.toString();
        }
        _validateCards();
      });
    }
  }

  void _onDecksChanged(int? newValue) {
    if (newValue != null) {
      setState(() {
        _decks = newValue;
        if (_fullDistribution) {
          _cards = _maxCardsPerPlayer;
          _cardsController.text = _cards.toString();
        } else {
          _cards = _maxCardsPerPlayer;
          _cardsController.text = _cards.toString();
        }
        _validateCards();
      });
    }
  }

  void _onFullDistributionChanged(bool? value) {
    setState(() {
      _fullDistribution = value ?? false;
      if (_fullDistribution) {
        _cards = _maxCardsPerPlayer;
        _cardsController.text = _cards.toString();
        _cardsError = null;
      }
    });
  }

  void _onTimeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _time = newValue;
      });
    }
  }

  // Tooltip handlers
  void _showCardsTooltip() {
    _tooltipHelper.showTooltip(
      'Number of cards each player will receive at start',
      _cardsInfoKey,
      context,
    );
  }

  void _showTimeTooltip() {
    _tooltipHelper.showTooltip(
      'Total round time per player',
      _timeInfoKey,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = context.appConfig;
    final colorConfig = context.config.colors;
    final spacingConfig = context.config.spacing;
    final backgroundConfig = context.config.background;
    final shadowConfig = context.config.sketchyButton.shadow;

    return Scaffold(
      backgroundColor: appConfig.theme.backgroundColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(colorConfig.whiteGradient.top),
                    Colors.white.withOpacity(colorConfig.whiteGradient.bottom),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                context.assetsConfig.images.homeBackground,
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(backgroundConfig.imageOpacity),
              ),
            ),
          ),
          
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: appConfig.theme.backgroundColor.withOpacity(colorConfig.standardOverlay),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    appConfig.theme.backgroundColor.withOpacity(backgroundConfig.overlay.opacityTop),
                    appConfig.theme.backgroundColor.withOpacity(backgroundConfig.overlay.opacityBottom),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(spacingConfig.default_),
              child: Column(
                children: [
                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: appConfig.theme.backgroundColor.withOpacity(colorConfig.lightOverlay),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(shadowConfig.opacity),
                          blurRadius: shadowConfig.blur * 2,
                          offset: Offset(shadowConfig.offsetX, shadowConfig.offsetY * 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Host Game',
                      style: TextStyle(
                        fontSize: appConfig.theme.fonts.titleSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: appConfig.theme.fonts.fontFamily,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: spacingConfig.large),
                  
                  // Game Settings Container
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(spacingConfig.default_),
                      decoration: BoxDecoration(
                        color: appConfig.theme.backgroundColor.withOpacity(colorConfig.lightOverlay),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(shadowConfig.opacity),
                            blurRadius: shadowConfig.blur,
                            offset: Offset(shadowConfig.offsetX, shadowConfig.offsetY),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Player & Deck Controls
                          PlayerDeckControls(
                            players: _players,
                            decks: _decks,
                            playerOptions: _playerOptions,
                            deckOptions: _deckOptions,
                            onPlayersChanged: _onPlayersChanged,
                            onDecksChanged: _onDecksChanged,
                          ),
                          
                          SizedBox(height: spacingConfig.default_),
                          
                          // Card Settings
                          CardSettings(
                            cardsController: _cardsController,
                            cardsError: _cardsError,
                            fullDistribution: _fullDistribution,
                            cardsInfoKey: _cardsInfoKey,
                            onFullDistributionChanged: _onFullDistributionChanged,
                            onTooltipPressed: _showCardsTooltip,
                          ),
                          
                          SizedBox(height: spacingConfig.default_),
                          
                          // Time Settings
                          TimeSettings(
                            time: _time,
                            timeOptions: _timeOptions,
                            timeInfoKey: _timeInfoKey,
                            onTimeChanged: _onTimeChanged,
                            onTooltipPressed: _showTimeTooltip,
                          ),
                          
                          const Spacer(),
                          
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SketchyButton(
                                text: 'Back',
                                color: colorConfig.buttonColors.red,
                                onPressed: () => Navigator.of(context).pop(),
                                seed: 100,
                                width: 120,
                              ),
                              SketchyButton(
                                text: 'Start Game',
                                color: colorConfig.buttonColors.lightBlue,
                                onPressed: (_cardsError == null) 
                                    ? () => Navigator.pushNamed(context, '/board')
                                    : null,
                                seed: 101,
                                width: 140,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
