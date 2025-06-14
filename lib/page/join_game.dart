import 'package:deckopia/models/board_entity.dart';
import 'package:deckopia/page/player_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deckopia/util/config_provider.dart';
import 'package:deckopia/widgets/shared/game_screen_background.dart';
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
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameService ??= GameService(context.config.game);
    
    // Initialize controllers and focus nodes based on config
    final otpLength = context.gameConfig.otp.length;
    if (_controllers.isEmpty) {
      _controllers = List.generate(otpLength, (index) => TextEditingController());
      _focusNodes = List.generate(otpLength, (index) => FocusNode());
    }
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
    final otpLength = context.gameConfig.otp.length;

    if (otp.length != otpLength) {
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
      backgroundColor: appConfig.theme.backgroundColor,
      body: GameScreenBackground(
        child: SafeArea(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: appConfig.theme.backgroundColor.withOpacity(context.config.colors.lightOverlay),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(context.config.sketchyButton.shadow.opacity),
                            blurRadius: context.config.sketchyButton.shadow.blur * 2,
                            offset: Offset(context.config.sketchyButton.shadow.offsetX, context.config.sketchyButton.shadow.offsetY * 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Join Game',
                        style: TextStyle(
                          fontSize: appConfig.theme.fonts.titleSize,
                          fontFamily: appConfig.theme.fonts.fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
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
                          context.gameConfig.otp.length,
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
                                final otpLength = context.gameConfig.otp.length;
                                if (value.isNotEmpty && index < otpLength - 1) {
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
