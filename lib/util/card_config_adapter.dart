import 'package:flutter/material.dart';
import '../models/card_behavior_interfaces.dart';
import '../models/card_snap_behavior.dart';
import '../models/card_animation_behavior.dart';
import '../config/snap_area_config.dart';
import '../util/config_provider.dart';

/// Utility class to convert from legacy context-based configs to new behavior system
class CardConfigAdapter {
  /// Create CardRenderConfig from context (backward compatibility)
  static CardRenderConfig createRenderConfig(
    BuildContext context, 
    String suit, 
    String rank
  ) {
    final cardConfig = context.cardConfig;
    final assetsConfig = context.assetsConfig;
    
    return CardRenderConfig(
      cardSize: Size(
        cardConfig.dimensions.width,
        cardConfig.dimensions.width * cardConfig.dimensions.aspectRatio,
      ),
      borderRadius: cardConfig.dimensions.borderRadius,
      frontImagePath: assetsConfig.cards.getCardPath(suit, rank),
      backImagePath: assetsConfig.cards.backCardPath,
      initiallyFaceUp: cardConfig.initial.isFaceUp,
      initialRotation: cardConfig.initial.rotation,
      shadowColor: null, // No shadows in original implementation
      shadowBlur: 0,
      shadowOffset: Offset.zero,
    );
  }
  
  /// Create animation behavior from context config
  static CardAnimationBehavior createAnimationBehavior(BuildContext context) {
    final cardConfig = context.cardConfig;
    
    return DefaultCardAnimationBehavior(
      flipDuration: cardConfig.animation.flipDuration,
      rotationDuration: cardConfig.animation.rotationTransitionDuration,
      maxRotationDegrees: cardConfig.animation.maxRotationDegrees,
      rotationUpdateInterval: cardConfig.animation.rotationUpdateInterval,
    );
  }
  
  /// Create smart snap behavior with different area behaviors
  static SnapBehavior createSnapBehavior(
    List<SnapAreaConfig> snapAreas, {
    Function()? getBottomAreaCardCount,
  }) {
    final smartAreas = <SmartSnapArea>[];
    
    for (int i = 0; i < snapAreas.length; i++) {
      final snapArea = snapAreas[i];
      final bounds = Rect.fromLTWH(
        snapArea.position.dx,
        snapArea.position.dy,
        snapArea.size.width,
        snapArea.size.height,
      );
      
      SmartSnapArea smartArea;
      
      if (i == 2) {
        // Bottom area - horizontal stacking without rotation
        smartArea = HorizontalStackArea(
          index: i,
          bounds: bounds,
          getCardCount: getBottomAreaCardCount ?? () => 0,
          cardSpacing: 20.0,
        );
      } else {
        // Top areas - concentric stacking with rotation
        smartArea = ConcentricStackArea(
          index: i,
          bounds: bounds,
          stackOffset: 2.0,
        );
      }
      
      smartAreas.add(smartArea);
    }
    
    return SmartSnapBehavior(areas: smartAreas);
  }
  
  /// Create callbacks that bridge old callback system to new one
  static CardInteractionCallbacks createCallbacks({
    Function(int? snapAreaIndex)? onSnapToArea,
    VoidCallback? onDragStart,
    VoidCallback? onDragEnd,
    VoidCallback? onTap,
  }) {
    return CardInteractionCallbacks(
      onSnapAreaChanged: onSnapToArea,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd,
      onTap: onTap,
    );
  }
  
  /// Calculate initial position for card in snap area (backward compatibility)
  static Offset calculateInitialPosition(
    SnapAreaConfig snapArea,
    Size cardSize,
    int stackIndex,
    double stackOffset,
  ) {
    final centerX = snapArea.position.dx + (snapArea.size.width - cardSize.width) / 2;
    final centerY = snapArea.position.dy + (snapArea.size.height - cardSize.height) / 2;
    
    return Offset(
      centerX + (stackOffset * stackIndex),
      centerY + (stackOffset * stackIndex),
    );
  }
}