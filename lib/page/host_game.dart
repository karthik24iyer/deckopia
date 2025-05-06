import 'package:flutter/material.dart';
import 'package:deckopia/models/sketchy_button.dart';

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

  // Current tooltip message
  String? _tooltipMessage;
  OverlayEntry? _overlayEntry;

  // Keys for tooltips
  final GlobalKey _cardsInfoKey = GlobalKey();
  final GlobalKey _timeInfoKey = GlobalKey();

  // Options for dropdowns
  final List<int> _playerOptions = List.generate(10, (index) => index + 1);
  final List<int> _deckOptions = List.generate(3, (index) => index + 1);
  final List<String> _timeOptions = ['10 sec', '20 sec', '30 sec', '1 min', '2 mins'];

  @override
  void initState() {
    super.initState();
    _cardsController.addListener(_validateCards);
  }

  @override
  void dispose() {
    _cardsController.dispose();
    _hideTooltip();
    super.dispose();
  }

  // Calculate max cards allowed per player
  int get _maxCardsPerPlayer {
    return (_decks * 52) ~/ _players;
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

  // Update card distribution when full distribution checkbox changes
  void _updateFullDistribution(bool? value) {
    setState(() {
      _fullDistribution = value ?? false;
      if (_fullDistribution) {
        _cards = _maxCardsPerPlayer;
        _cardsController.text = _cards.toString();
        _cardsError = null;
      }
    });
  }

  // Show tooltip
  void _showTooltip(String message, GlobalKey key) {
    _hideTooltip();

    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    setState(() {
      _tooltipMessage = message;
    });

    _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: position.dx - 50,
          top: position.dy - 40,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFFECB3))
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'CaveatBrush',
                ),
              ),
            ),
          ),
        )
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-hide tooltip after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _hideTooltip();
    });
  }

  // Hide tooltip
  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    setState(() {
      _tooltipMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EE),
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
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.3),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/home_background.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.8),
              ),
            ),
          ),
          
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F1EE).withOpacity(0.85),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF8F1EE).withOpacity(0.95),
                    const Color(0xFFF8F1EE).withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Header
                  const Center(
                    child: Text(
                      'Cheers to your heavy-lifting :)',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'CaveatBrush',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Main content - scrollable section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Players row
                          Row(
                            children: [
                              const Text(
                                'Players',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'CaveatBrush',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 140,
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _players,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    elevation: 8,
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'CaveatBrush',
                                    ),
                                    alignment: Alignment.center,
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _players = newValue;
                                          _validateCards();
                                        });
                                      }
                                    },
                                    items: _playerOptions.map<DropdownMenuItem<int>>((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        alignment: Alignment.center,
                                        child: Text(value.toString()),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 80,),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Deck row
                          Row(
                            children: [
                              const Text(
                                'Deck',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'CaveatBrush',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 140,
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _decks,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    elevation: 8,
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'CaveatBrush',
                                    ),
                                    alignment: Alignment.center,
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _decks = newValue;
                                          _validateCards();
                                        });
                                      }
                                    },
                                    items: _deckOptions.map<DropdownMenuItem<int>>((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        alignment: Alignment.center,
                                        child: Text(value.toString()),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 80,),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Cards row
                          Row(
                            children: [
                              const Text(
                                'Cards',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'CaveatBrush',
                                ),
                              ),
                              IconButton(
                                key: _cardsInfoKey,
                                icon: const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _showTooltip('Number of cards per player', _cardsInfoKey),
                              ),
                              const Spacer(),
                              Container(
                                width: 140,
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _cardsError != null ? Colors.red : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _cardsController,
                                  enabled: !_fullDistribution,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'CaveatBrush',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'full',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'CaveatBrush',
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: 1.2,
                                        child: Checkbox(
                                          value: _fullDistribution,
                                          onChanged: _updateFullDistribution,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Error message
                          if (_cardsError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 48.0),
                              child: Text(
                                _cardsError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontFamily: 'CaveatBrush',
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Time row
                          Row(
                            children: [
                              const Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'CaveatBrush',
                                ),
                              ),
                              IconButton(
                                key: _timeInfoKey,
                                icon: const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _showTooltip('Total round time per player', _timeInfoKey),
                              ),
                              const Spacer(),
                              Container(
                                width: 140,
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _time,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    elevation: 8,
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'CaveatBrush',
                                    ),
                                    alignment: Alignment.center,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _time = newValue;
                                        });
                                      }
                                    },
                                    items: _timeOptions.map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        alignment: Alignment.center,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 80,)
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Advanced settings
                          Row(
                            children: [
                              const Text(
                                'Advanced',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'CaveatBrush',
                                  color: Colors.grey,
                                ),
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: _advanced,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _advanced = value ?? false;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Divider
                          const Divider(thickness: 1),

                          // Advanced settings placeholder
                          if (_advanced)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Advanced settings placeholder. Additional options will be displayed here.',
                                style: TextStyle(fontFamily: 'CaveatBrush'),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Layout row
                          Row(
                            children: [
                              const Text(
                                'Layout',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'CaveatBrush',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8E8B8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    // Placeholder for Load button
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Load button pressed')),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: Text(
                                      'Load',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'CaveatBrush',
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8BBD0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    // Placeholder for Create button
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Create button pressed')),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: Text(
                                      'Create',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'CaveatBrush',
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Let's Go button
                  Center(
                    child: SketchyButton(
                      text: 'Lets Go',
                      color: Colors.lightBlue.shade100,
                      onPressed: () {
                        // Check if we have any errors first
                        if (_cardsError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please fix errors: $_cardsError')),
                          );
                          return;
                        }

                        // Proceed to board screen with game settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Let\'s Go button pressed')),
                        );
                      },
                      seed: 3,
                      width: 240,
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