import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Mock API service
class GameService {
  static const String mockOTP = '123456';

  Future<bool> verifyOTP(String otp) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1));
    return otp == mockOTP;
  }
}