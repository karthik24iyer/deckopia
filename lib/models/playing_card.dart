import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:deckopia/config/snap_area_config.dart';
import 'package:deckopia/util/config_provider.dart';

class PlayingCard extends StatefulWidget {
  final String suit;
  final String rank;
  final List<SnapAreaConfig> snapAreas;
  final int initialSnapAreaIndex;
  final Function(int snapAreaIndex)? onSnapToArea;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const PlayingCard({
    super.key,
    required this.suit,
    required this.rank,
    required this.snapAreas,
    this.initialSnapAreaIndex = 0,
    this.onSnapToArea,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<PlayingCard> createState() => _PlayingCardState();
}

class _PlayingCardState extends State<PlayingCard> with TickerProviderStateMixin {
  late Offset position;
  int? currentSnapAreaIndex;
  int? dragStartSnapAreaIndex; // Track which area drag started from
  late AnimationController _flipController;
  late AnimationController _rotationController;
  late Animation<double> _flipAnimation;
  late Animation<double> _rotationAnimation;
  late bool _isFrontVisible;
  final _random = math.Random();
  Timer? _rotationTimer;
  double _currentRotation = 0.0;
  double _targetRotation = 0.0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    currentSnapAreaIndex = widget.initialSnapAreaIndex;

    // Initialize controllers without duration (will be set in didChangeDependencies)
    _flipController = AnimationController(vsync: this);
    _rotationController = AnimationController(vsync: this);

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
          _isFrontVisible = _flipAnimation.value <= math.pi / 2;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final cardConfig = context.cardConfig;

      // Initialize state variables that depend on config
      _isFrontVisible = cardConfig.initial.isFaceUp;
      _currentRotation = cardConfig.initial.rotation;

      // Set controller durations
      _flipController.duration = cardConfig.animation.flipDuration;
      _rotationController.duration = cardConfig.animation.rotationTransitionDuration;

      // Initialize position
      _initializePosition();

      // Set initial flip state
      if (!_isFrontVisible) {
        _flipController.value = 1.0;
      }

      _initialized = true;
    }
  }

  void _initializePosition() {
    final snapArea = widget.snapAreas[widget.initialSnapAreaIndex];
    position = Offset(
      snapArea.position.dx + (snapArea.size.width - cardSize.width) / 2,
      snapArea.position.dy + (snapArea.size.height - cardSize.height) / 2,
    );
  }

  Size get cardSize => Size(
    context.cardConfig.dimensions.width,
    context.cardConfig.dimensions.width * context.cardConfig.dimensions.aspectRatio,
  );

  void _startRandomRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(
      context.cardConfig.animation.rotationUpdateInterval,
          (timer) {
        if (mounted) {
          final maxRadians = context.cardConfig.animation.maxRotationDegrees * math.pi / 180;
          _targetRotation = (_random.nextDouble() * 2 - 1) * maxRadians;
          _rotationController.forward(from: 0);
        }
      },
    );
  }

  void _stopRandomRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }

  void _updateSnapArea(Offset newPosition) {
    int? newSnapAreaIndex;

    for (int i = 0; i < widget.snapAreas.length; i++) {
      if (widget.snapAreas[i].containsPoint(newPosition, cardSize)) {
        newSnapAreaIndex = i;
        break;
      }
    }

    if (newSnapAreaIndex != currentSnapAreaIndex) {
      setState(() {
        currentSnapAreaIndex = newSnapAreaIndex;
      });
    }
  }

  void _snapToNearestArea() {
    _stopRandomRotation();

    int nearestAreaIndex = 0;
    double minDistance = double.infinity;

    final cardCenter = Offset(
      position.dx + cardSize.width / 2,
      position.dy + cardSize.height / 2,
    );

    for (int i = 0; i < widget.snapAreas.length; i++) {
      final distance = (cardCenter - widget.snapAreas[i].center).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearestAreaIndex = i;
      }
    }

    setState(() {
      currentSnapAreaIndex = nearestAreaIndex;
      position = widget.snapAreas[nearestAreaIndex].clampPosition(position, cardSize);

      final maxRadians = context.cardConfig.animation.maxRotationDegrees * math.pi / 180;
      _targetRotation = (_random.nextDouble() - 0.5) * 2 * maxRadians;
      _rotationController.forward(from: 0);
    });

    // Only trigger callback if card moved from one area to another
    if (dragStartSnapAreaIndex != null && dragStartSnapAreaIndex != nearestAreaIndex) {
      widget.onSnapToArea?.call(nearestAreaIndex);
    }
    
    // Reset drag start area
    dragStartSnapAreaIndex = null;
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;
    if (_isFrontVisible) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _flipController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardConfig = context.cardConfig;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          _startRandomRotation();
          // Record which snap area we started dragging from
          dragStartSnapAreaIndex = currentSnapAreaIndex;
          // Notify that drag started (brings card to front during drag)
          widget.onDragStart?.call();
        },
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              position.dx + details.delta.dx,
              position.dy + details.delta.dy,
            );
            _updateSnapArea(position);
          });
        },
        onPanEnd: (details) {
          _snapToNearestArea();
          widget.onDragEnd?.call();
        },
        onPanCancel: () {
          _stopRandomRotation();
          widget.onDragEnd?.call();
        },
        onTap: _flipCard,
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
                  width: cardSize.width,
                  height: cardSize.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cardConfig.dimensions.borderRadius),
                    image: DecorationImage(
                      image: AssetImage(
                        _isFrontVisible
                            ? context.assetsConfig.cards.getCardPath(widget.suit, widget.rank)
                            : context.assetsConfig.cards.backCardPath,
                      ),
                      fit: BoxFit.cover,
                    ),
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