/// Configuration for snap area behaviors
class SnapBehaviorConfig {
  /// Horizontal spacing between cards in bottom area (in pixels)
  final double horizontalCardSpacing;
  
  /// Stack offset for concentric areas (when enabled)
  final double concentricStackOffset;
  
  /// Whether to enable concentric stacking offset
  final bool enableConcentricOffset;
  
  const SnapBehaviorConfig({
    this.horizontalCardSpacing = 30.0,
    this.concentricStackOffset = 2.0,
    this.enableConcentricOffset = false,
  });
  
  /// Default configuration
  static const SnapBehaviorConfig defaultConfig = SnapBehaviorConfig();
  
  /// Configuration with concentric offset enabled
  static const SnapBehaviorConfig withConcentricOffset = SnapBehaviorConfig(
    enableConcentricOffset: true,
  );
  
  /// Configuration with custom spacing
  static SnapBehaviorConfig withSpacing(double spacing) => SnapBehaviorConfig(
    horizontalCardSpacing: spacing,
  );
}