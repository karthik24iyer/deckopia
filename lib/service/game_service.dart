import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deckopia/util/config_provider.dart';

import '../config/config.dart';

// Mock API service
class GameService {
  final GameConfig _config;

  GameService(this._config);

  Future<bool> verifyOTP(String otp) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: _config.otpDelay));
    return otp == _config.mockOTP;
  }
}