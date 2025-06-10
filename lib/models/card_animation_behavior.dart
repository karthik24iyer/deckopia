import 'dart:async';
import 'dart:math' as math;
import 'card_behavior_interfaces.dart';

/// Default animation behavior matching current card behavior
class DefaultCardAnimationBehavior extends CardAnimationBehavior {
  final Duration _flipDuration;
  final Duration _rotationDuration;
  final double _maxRotationRadians;
  final Duration _rotationUpdateInterval;
  
  Timer? _rotationTimer;
  final math.Random _random = math.Random();
  
  DefaultCardAnimationBehavior({
    Duration flipDuration = const Duration(milliseconds: 800),
    Duration rotationDuration = const Duration(milliseconds: 150),
    double maxRotationDegrees = 20.0,
    Duration rotationUpdateInterval = const Duration(milliseconds: 500),
  }) : _flipDuration = flipDuration,
       _rotationDuration = rotationDuration,
       _maxRotationRadians = maxRotationDegrees * math.pi / 180,
       _rotationUpdateInterval = rotationUpdateInterval;
  
  @override
  Duration get flipDuration => _flipDuration;
  
  @override
  Duration get rotationDuration => _rotationDuration;
  
  @override
  double get maxRotationRadians => _maxRotationRadians;
  
  @override
  Duration get rotationUpdateInterval => _rotationUpdateInterval;
  
  @override
  void onAnimationStart() {
    // Start random rotation timer when animation begins
    _startRandomRotation();
  }
  
  @override
  void onAnimationStop() {
    // Stop random rotation timer
    _stopRandomRotation();
  }
  
  void _startRandomRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(_rotationUpdateInterval, (timer) {
      // This would need to be connected to the card's rotation controller
      // The actual rotation update would be handled by the card widget
    });
  }
  
  void _stopRandomRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }
  
  /// Get random rotation value for use by card widget
  double getRandomRotation() {
    return (_random.nextDouble() * 2 - 1) * _maxRotationRadians;
  }
  
  void dispose() {
    _rotationTimer?.cancel();
  }
}

/// Simple animation behavior with no rotation effects
class SimpleCardAnimationBehavior extends CardAnimationBehavior {
  final Duration _flipDuration;
  
  SimpleCardAnimationBehavior({
    Duration flipDuration = const Duration(milliseconds: 400),
  }) : _flipDuration = flipDuration;
  
  @override
  Duration get flipDuration => _flipDuration;
  
  @override
  Duration get rotationDuration => Duration.zero;
  
  @override
  double get maxRotationRadians => 0.0;
  
  @override
  Duration get rotationUpdateInterval => Duration.zero;
}

/// Smooth animation behavior with gentle effects
class SmoothCardAnimationBehavior extends CardAnimationBehavior {
  final Duration _flipDuration;
  final Duration _rotationDuration;
  final double _maxRotationRadians;
  
  SmoothCardAnimationBehavior({
    Duration flipDuration = const Duration(milliseconds: 600),
    Duration rotationDuration = const Duration(milliseconds: 300),
    double maxRotationDegrees = 10.0,
  }) : _flipDuration = flipDuration,
       _rotationDuration = rotationDuration,
       _maxRotationRadians = maxRotationDegrees * math.pi / 180;
  
  @override
  Duration get flipDuration => _flipDuration;
  
  @override
  Duration get rotationDuration => _rotationDuration;
  
  @override
  double get maxRotationRadians => _maxRotationRadians;
  
  @override
  Duration get rotationUpdateInterval => const Duration(milliseconds: 1000);
}

/// Fast animation behavior for quick gameplay
class FastCardAnimationBehavior extends CardAnimationBehavior {
  @override
  Duration get flipDuration => const Duration(milliseconds: 200);
  
  @override
  Duration get rotationDuration => const Duration(milliseconds: 50);
  
  @override
  double get maxRotationRadians => 5.0 * math.pi / 180; // 5 degrees
  
  @override
  Duration get rotationUpdateInterval => const Duration(milliseconds: 200);
}