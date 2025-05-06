import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deckopia/util/config_provider.dart';
import '../helper/sketchy_painter.dart';
import '../models/board_entity.dart';
import '../models/sketchy_button.dart';
import 'dart:math' as math;

class PlayerInfoScreen extends StatefulWidget {
  final BoardEntity board;

  const PlayerInfoScreen({
    Key? key,
    required this.board,
  }) : super(key: key);

  @override
  State<PlayerInfoScreen> createState() => _PlayerInfoScreenState();
}

class _PlayerInfoScreenState extends State<PlayerInfoScreen> {
  Color? _selectedColor = Colors.grey.shade100;
  final List<String> _nameChars = List.filled(6, '');
  int _currentCharIndex = 0;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Color> _colorOptions = [
    Colors.red.shade200,
    Colors.lightBlue.shade200,
    Colors.purple.shade200,
    Colors.orange.shade200,
    Colors.pink.shade200,
    Colors.green.shade200,
    Colors.yellow.shade200,
    Colors.brown.shade200,
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final text = _textController.text.toUpperCase();
    setState(() {
      _nameChars.fillRange(0, _nameChars.length, '');
      for (var i = 0; i < math.min(text.length, 6); i++) {
        _nameChars[i] = text[i];
      }
      _currentCharIndex = text.length;
    });
  }

  bool get _isNameComplete => _currentCharIndex == 6;

  void _navigateToBoardScreen() {
    if (_selectedColor != null && _isNameComplete) {
      Navigator.pushReplacementNamed(
        context,
        '/board',
        arguments: {
          'board': widget.board,
          'playerName': _nameChars.join(),
          'playerColor': _selectedColor,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = context.appConfig;
    final size = MediaQuery.of(context).size;
    final sketchyConfig = context.config.sketchy;
    final sketchyButtonConfig = context.config.sketchyButton;
    final backgroundConfig = context.config.background;
    final colorConfig = context.config.colors;

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
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.3),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/home_background.png',
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(backgroundConfig.imageOpacity),
              ),
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: appConfig.theme.backgroundColor.withOpacity(0.85),
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
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.vertical,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.02),

                      // Header
                      Text(
                        'We Entered "${widget.board.boardId}"',
                        style: TextStyle(
                          fontSize: appConfig.theme.fonts.titleSize,
                          fontFamily: appConfig.theme.fonts.fontFamily,
                          color: Colors.red,
                        ),
                      ),

                      SizedBox(height: size.height * 0.06),

                      // Who Are You section
                      Text(
                        'Who Are You Thou?',
                        style: TextStyle(
                          fontSize: appConfig.theme.fonts.titleSize,
                          fontFamily: appConfig.theme.fonts.fontFamily,
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Name input section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_selectedColor != null)
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 16),
                              child: CustomPaint(
                                painter: SketchyCircle(
                                  _selectedColor!, 
                                  0, 
                                  true,
                                  sketchyConfig,
                                  sketchyButtonConfig.noiseMagnitude,
                                ),
                              ),
                            ),
                          Stack(
                            children: [
                              Row(
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 30,
                                    height: 40,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      _nameChars[index],
                                      style: TextStyle(
                                        fontSize: appConfig.theme.fonts.buttonTextSize,
                                        fontFamily: appConfig.theme.fonts.fontFamily,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(
                                height: 40,
                                width: 230,
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  enableSuggestions: false,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    counterText: '',
                                  ),
                                  maxLength: 6,
                                  style: const TextStyle(
                                    color: Colors.transparent,
                                  ),
                                  showCursor: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.08),

                      // Color selection grid
                      CustomPaint(
                        painter: SketchyContainerPainter(
                          1,
                          sketchyConfig,
                          sketchyButtonConfig.noiseMagnitude,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.height * 0.02),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: size.height * 0.02,
                              mainAxisSpacing: size.height * 0.02,
                              childAspectRatio: 1,
                            ),
                            itemCount: _colorOptions.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = _colorOptions[index];
                                  });
                                },
                                child: CustomPaint(
                                  painter: SketchyCircle(
                                    _colorOptions[index],
                                    index + 1,
                                    true,
                                    sketchyConfig,
                                    sketchyButtonConfig.noiseMagnitude,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // GLHF Button
                      SketchyButton(
                        text: 'GLHF',
                        color: (_colorOptions.contains(_selectedColor) && _isNameComplete)
                            ? colorConfig.buttonColors.lightBlue
                            : Colors.grey.shade300,
                        onPressed: (_colorOptions.contains(_selectedColor) && _isNameComplete)
                            ? _navigateToBoardScreen
                            : null,
                        seed: 5,
                        width: size.width / 2,
                      ),

                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}