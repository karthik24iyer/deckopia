import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import 'card_behavior_interfaces.dart';
import 'card_animation_behavior.dart';

/// Flexible, decoupled PlayingCard widget with dependency injection
class PlayingCard extends StatefulWidget {
  // Core card data
  final String suit;
  final String rank;
  final String? cardId; // Optional unique identifier
  
  // Rendering configuration (no context dependencies)
  final CardRenderConfig renderConfig;

  // Behavior injection
  final SnapBehavior? snapBehavior;
  final CardAnimationBehavior? animationBehavior;
  final CardDragBehavior? dragBehavior;
  
  // Position management (choose between controlled/uncontrolled)
  final Offset? position; // Controlled - parent manages position
  final Offset? initialPosition; // Uncontrolled - card manages own position
  
  // Interaction callbacks
  final CardInteractionCallbacks? callbacks;
  
  // State control
  final bool? isFaceUp; // Controlled face up/down state
  final bool? initiallyFaceUp; // Initial face up/down for uncontrolled
  final bool enabled;
  
  const PlayingCard({
    super.key,
    required this.suit,
    required this.rank,
    required this.renderConfig,
    this.cardId,
    this.snapBehavior,
    this.animationBehavior,
    this.dragBehavior,
    this.position, // Controlled mode
    this.initialPosition, // Uncontrolled mode  
    this.callbacks,
    this.isFaceUp, // Controlled mode
    this.initiallyFaceUp, // Uncontrolled mode
    this.enabled = true,
  }) : assert(
         (position != null) != (initialPosition != null),
         'Must provide either position (controlled) or initialPosition (uncontrolled), not both'
       ),
       assert(
         (isFaceUp != null) != (initiallyFaceUp != null),
         'Must provide either isFaceUp (controlled) or initiallyFaceUp (uncontrolled), not both'
       );
  
  /// Factory for backward compatibility with existing code
  factory PlayingCard.fromLegacy({
    Key? key,
    required String suit,
    required String rank,
    required List<dynamic> snapAreas, // Accept any snap area type
    int initialSnapAreaIndex = 0,
    Function(int? snapAreaIndex)? onSnapToArea,
    VoidCallback? onDragStart,
    VoidCallback? onDragEnd,
    // Legacy context config dependencies would be passed as explicit config
    required CardRenderConfig renderConfig,
    CardAnimationBehavior? animationBehavior,
  }) {
    // Convert legacy snap areas to SnapBehavior if needed
    SnapBehavior? snapBehavior;
    // This would need specific implementation based on snap area type
    
    return PlayingCard(
      key: key,
      suit: suit,
      rank: rank,
      renderConfig: renderConfig,
      snapBehavior: snapBehavior,
      animationBehavior: animationBehavior ?? DefaultCardAnimationBehavior(),
      initialPosition: Offset.zero, // Would calculate from snap areas
      initiallyFaceUp: renderConfig.initiallyFaceUp,
      callbacks: CardInteractionCallbacks(
        onSnapAreaChanged: onSnapToArea,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
      ),
    );
  }
  
  @override
  State<PlayingCard> createState() => _PlayingCardState();
}

class _PlayingCardState extends State<PlayingCard> 
    with TickerProviderStateMixin {
  
  // Position management
  late Offset _currentPosition;
  bool get _isPositionControlled => widget.position != null;
  
  // Face up/down state management  
  late bool _isFaceUp;
  bool get _isFaceUpControlled => widget.isFaceUp != null;
  
  // Animation controllers
  late AnimationController _flipController;
  late AnimationController _rotationController;
  late Animation<double> _flipAnimation;
  late Animation<double> _rotationAnimation;
  
  // Rotation state
  double _currentRotation = 0.0;
  double _targetRotation = 0.0;
  Timer? _rotationTimer;
  final _random = math.Random();
  
  // Snap state
  int? _currentSnapArea;
  int? _dragStartSnapArea;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize position
    _currentPosition = widget.position ?? widget.initialPosition ?? Offset.zero;
    
    // Initialize face up state
    _isFaceUp = widget.isFaceUp ?? widget.initiallyFaceUp ?? 
               widget.renderConfig.initiallyFaceUp;
    
    // Initialize animation controllers
    final animBehavior = widget.animationBehavior ?? DefaultCardAnimationBehavior();
    
    _flipController = AnimationController(
      duration: animBehavior.flipDuration,
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: animBehavior.rotationDuration, 
      vsync: this,
    );
    
    _setupAnimations();
    
    // Set initial flip state
    if (!_isFaceUp) {
      _flipController.value = 1.0;
    }
  }
  
  void _setupAnimations() {
    _flipAnimation = Tween<double>(
      begin: 0,
      end: math.pi,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
    
    _flipAnimation.addListener(() {
      setState(() {
        if (_flipController.isAnimating) {
          _isFaceUp = _flipAnimation.value <= math.pi / 2;
        }
      });
    });
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation.addListener(() {
      setState(() {
        _currentRotation = lerpDouble(
          _currentRotation,
          _targetRotation,
          _rotationAnimation.value,
        )!;
      });
    });
  }
  
  @override
  void didUpdateWidget(PlayingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update controlled position
    if (_isPositionControlled && widget.position != oldWidget.position) {
      setState(() {
        _currentPosition = widget.position!;
      });
    }
    
    // Update controlled face up state
    if (_isFaceUpControlled && widget.isFaceUp != oldWidget.isFaceUp) {
      _setFaceUp(widget.isFaceUp!);
    }
  }
  
  void _setFaceUp(bool faceUp) {
    if (faceUp == _isFaceUp) return;
    
    if (faceUp) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }
  
  void _flipCard() {
    if (_flipController.isAnimating) return;
    
    if (_isFaceUpControlled) {
      // In controlled mode, notify parent instead of changing state directly
      widget.callbacks?.onFlip?.call();
    } else {
      // In uncontrolled mode, manage flip state internally
      _setFaceUp(!_isFaceUp);
    }
  }
  
  void _startRandomRotation() {
    final animBehavior = widget.animationBehavior;
    if (animBehavior == null || animBehavior.maxRotationRadians == 0) return;
    
    animBehavior.onAnimationStart();
    
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(
      animBehavior.rotationUpdateInterval,
      (timer) {
        if (mounted) {
          if (animBehavior is DefaultCardAnimationBehavior) {
            _targetRotation = animBehavior.getRandomRotation();
          } else {
            _targetRotation = (_random.nextDouble() * 2 - 1) * 
                             animBehavior.maxRotationRadians;
          }
          _rotationController.forward(from: 0);
        }
      },
    );
  }
  
  void _stopRandomRotation() {
    widget.animationBehavior?.onAnimationStop();
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }
  
  void _handlePanStart(DragStartDetails details) {
    if (!widget.enabled) return;
    
    _startRandomRotation();
    _dragStartSnapArea = _currentSnapArea;
    
    widget.dragBehavior?.onDragStart(_currentPosition);
    widget.callbacks?.onDragStart?.call();
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    
    final newPosition = _currentPosition + details.delta;
    
    if (!_isPositionControlled) {
      setState(() {
        _currentPosition = newPosition;
      });
    }
    
    // Update snap area if we have snap behavior
    if (widget.snapBehavior != null && widget.cardId != null) {
      final snapResult = widget.snapBehavior!.calculateSnap(
        newPosition, 
        widget.renderConfig.cardSize,
        widget.cardId!
      );
      final newSnapArea = snapResult?.snapAreaIndex;
      if (newSnapArea != _currentSnapArea) {
        setState(() {
          _currentSnapArea = newSnapArea;
        });
      }
    }
    
    widget.dragBehavior?.onDragUpdate(newPosition);
    widget.callbacks?.onPositionChanged?.call(newPosition);
  }
  
  void _handlePanEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    
    _stopRandomRotation();
    
    // Handle snapping
    if (widget.snapBehavior != null && widget.cardId != null) {
      final snapResult = widget.snapBehavior!.calculateSnap(
        _currentPosition,
        widget.renderConfig.cardSize,
        widget.cardId!
      );
      
      if (snapResult != null) {
        if (!_isPositionControlled) {
          setState(() {
            _currentPosition = snapResult.snapPosition;
          });
        }
        
        // Control rotation based on snap area
        if (!snapResult.allowsRotation) {
          _stopRandomRotation();
          // Reset rotation to 0 for areas that don't allow it
          setState(() {
            _currentRotation = 0.0;
            _targetRotation = 0.0;
          });
        }
        
        // Notify snap behavior about card movement
        if (_dragStartSnapArea != snapResult.snapAreaIndex) {
          widget.snapBehavior!.onCardMoved(
            widget.cardId!,
            _dragStartSnapArea,
            snapResult.snapAreaIndex
          );
          widget.callbacks?.onSnapAreaChanged?.call(snapResult.snapAreaIndex);
        }
        
        setState(() {
          _currentSnapArea = snapResult.snapAreaIndex;
        });
      }
    }
    
    widget.dragBehavior?.onDragEnd(_currentPosition);
    widget.callbacks?.onDragEnd?.call();
    
    _dragStartSnapArea = null;
  }
  
  @override
  void dispose() {
    _rotationTimer?.cancel();
    _flipController.dispose();
    _rotationController.dispose();
    
    // Dispose animation behavior if it has cleanup
    if (widget.animationBehavior is DefaultCardAnimationBehavior) {
      (widget.animationBehavior as DefaultCardAnimationBehavior).dispose();
    }
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final config = widget.renderConfig;
    final position = _isPositionControlled ? widget.position! : _currentPosition;
    
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTap: () {
          widget.callbacks?.onTap?.call();
          _flipCard(); // Default tap behavior is flip
        },
        onDoubleTap: widget.callbacks?.onDoubleTap,
        onLongPress: widget.callbacks?.onLongPress,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateZ(_currentRotation),
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value),
                child: Container(
                  width: config.cardSize.width,
                  height: config.cardSize.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(config.borderRadius),
                    image: DecorationImage(
                      image: AssetImage(
                        _isFaceUp ? config.frontImagePath : config.backImagePath,
                      ),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: config.shadowColor != null ? [
                      BoxShadow(
                        color: config.shadowColor!,
                        blurRadius: config.shadowBlur,
                        offset: config.shadowOffset,
                      ),
                    ] : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}