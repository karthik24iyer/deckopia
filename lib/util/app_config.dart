// import 'package:flutter/material.dart';
//
// /// Global application configuration
// class AppConfig {
//   /// Card-related configurations
//   static const cardConfig = CardConfig();
//
//   /// Animation-related configurations
//   static const animationConfig = AnimationConfig();
//
//   /// Layout-related configurations
//   static const layoutConfig = LayoutConfig();
//
//   /// Visual style configurations
//   static const styleConfig = StyleConfig();
//
//   /// Asset path configurations
//   static const assetConfig = AssetConfig();
// }
//
// /// Configuration for card properties and dimensions
// class CardConfig {
//   // Card Dimensions
//   final double cardWidth = 200.0;
//   final double cardHeight = 350.0;
//   final double cornerRadius = 20.0;
//   final double cardAspectRatio = 1.4981;
//
//   // Card Interaction
//   final double dragSensitivity = 1.0;
//   final double snapThreshold = 0.5;
//   final double velocityThreshold = 1000.0;
//
//   // Card Stack
//   final int maxStackSize = 5;
//   final double stackSpacing = 2.0;
//
//   const CardConfig();
// }
//
// /// Configuration for animations and transitions
// class AnimationConfig {
//   // Duration Settings
//   final Duration flipDuration = const Duration(milliseconds: 800);
//   final Duration snapDuration = const Duration(milliseconds: 300);
//   final Duration rotationUpdateInterval = const Duration(milliseconds: 500);
//   final Duration rotationTransitionDuration = const Duration(milliseconds: 150);
//
//   // Animation Properties
//   final double maxRotationDegrees = 20.0;
//   final Curve flipCurve = Curves.easeInOut;
//   final Curve rotationCurve = Curves.easeInOut;
//   final Curve snapCurve = Curves.easeOutBack;
//
//   const AnimationConfig();
// }
//
// /// Configuration for layout and positioning
// class LayoutConfig {
//   // Spacing and Padding
//   final double snapAreaSpacing = 40.0;
//   final double screenEdgePadding = 20.0;
//   final double snapDetectionPadding = 20.0;
//   final double cornerPadding = 10.0;
//   final double symbolSpacing = 0.0;
//
//   // Area Ratios
//   final double upperSnapAreaHeightRatio = 0.38;
//   final double lowerSnapAreaHeightRatio = 0.38;
//   final double upperSnapAreaWidthRatio = 0.4;
//   final double lowerSnapAreaWidthRatio = 0.9;
//
//   const LayoutConfig();
// }
//
// /// Configuration for visual styles and decorations
// class StyleConfig {
//   // Colors
//   final Color redSuitColor = Colors.red;
//   final Color blackSuitColor = Colors.black;
//   final Color cardBackground = Colors.white;
//   final Color shadowColor = Colors.black26;
//
//   // Font Sizes
//   final double cornerRankSize = 24.0;
//   final double cornerSuitSize = 24.0;
//   final double centerSuitSize = 100.0;
//
//   // Shadow Properties
//   final double shadowBlur = 8.0;
//   final Offset shadowOffset = const Offset(0, 2);
//   final double shadowOpacity = 0.2;
//
//   // Pattern Properties
//   final double patternOpacity = 0.6;
//
//   const StyleConfig();
// }
//
// /// Configuration for asset paths and resources
// class AssetConfig {
//   // Card Assets
//   final String cardBackPath = 'assets/cards/back.png';
//   final String cardFacePath = 'assets/cards/{suit}/{suit}-{rank}.png';
//
//   // Pattern Assets
//   final String redPatternPath = 'assets/red_pattern.png';
//   final String blackPatternPath = 'assets/black_pattern.png';
//
//   const AssetConfig();
// }