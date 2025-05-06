import 'package:deckopia/models/board_entity.dart';
import 'package:deckopia/page/player_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deckopia/util/config_provider.dart';
import '../helper/otp_error_dialog.dart';
import '../helper/sketchy_painter.dart';
import '../models/sketchy_button.dart';
import '../service/game_service.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({Key? key}) : super(key: key);

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  GameService? _gameService;
  bool _isLoading = false;
  final List<TextEditingController> _controllers = List.generate(
    4,
        (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    4,
        (index) => FocusNode(),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameService ??= GameService(context.config.game);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _clearOTPFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpErrorDialog(
        onRetry: () {
          Navigator.of(context).pop();
          _clearOTPFields();
        },
        onExit: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to home screen
        },
      ),
    );
  }

  Future<void> _verifyAndNavigate() async {
    String otp = _controllers.map((controller) => controller.text).join();

    if (otp.length != 4) {
      _showErrorDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure gameService is initialized
      _gameService ??= GameService(context.config.game);
      
      bool isValid = await _gameService!.verifyOTP(otp);

      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerInfoScreen(board: BoardEntity(boardId: '123', numberOfPlayers: 4, type: 'dummy'),),
          ),
        );
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      _showErrorDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = context.appConfig;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                    appConfig.theme.backgroundColor.withOpacity(0.95),
                    appConfig.theme.backgroundColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        'Join Game',
                        style: TextStyle(
                          fontSize: appConfig.theme.fonts.titleSize,
                          fontFamily: appConfig.theme.fonts.fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: appConfig.theme.backgroundColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'We all love OTPs don\'t we :)',
                            style: TextStyle(
                              fontSize: appConfig.theme.fonts.buttonTextSize,
                              fontFamily: appConfig.theme.fonts.fontFamily,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                                (index) => Container(
                              width: 45,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: appConfig.theme.fonts.fontFamily,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SketchyButton(
                          text: 'Join Game',
                          color: context.config.colors.buttonColors.lightBlue,
                          onPressed: _verifyAndNavigate,
                          seed: 1,
                          width: MediaQuery.of(context).size.width / 2,
                          isLoading: _isLoading,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}