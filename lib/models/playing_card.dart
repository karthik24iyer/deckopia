import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:deckopia/config/snap_area_config.dart';

class PlayingCardConfig {
  final double maxRotationDegrees;
  final Duration rotationUpdateInterval;
  final Duration rotationTransitionDuration;
  final Duration flipDuration;
  final double cardWidth;
  final double cardAspectRatio;
  final Offset? initialPosition;
  final double? initialRotation;
  final bool initiallyFaceUp;

  const PlayingCardConfig({
    this.maxRotationDegrees = 20.0,
    this.rotationUpdateInterval = const Duration(milliseconds: 500),
    this.rotationTransitionDuration = const Duration(milliseconds: 150),
    this.flipDuration = const Duration(milliseconds: 800),
    this.cardWidth = 200.0,
    this.cardAspectRatio = 1.4981,
    this.initialPosition,
    this.initialRotation,
    this.initiallyFaceUp = true,
  });
}

class PlayingCard extends StatefulWidget {
  final String suit;
  final String rank;
  final List<SnapAreaConfig> snapAreas;
  final int initialSnapAreaIndex;
  final PlayingCardConfig config;
  final VoidCallback? onDragStart;

  const PlayingCard({
    super.key,
    required this.suit,
    required this.rank,
    required this.snapAreas,
    this.initialSnapAreaIndex = 0,
    this.config = const PlayingCardConfig(),
    this.onDragStart,
  });

  @override
  State<PlayingCard> createState() => _PlayingCardState();
}

class _PlayingCardState extends State<PlayingCard> with TickerProviderStateMixin {
  late Offset position;
  int? currentSnapAreaIndex;
  late AnimationController _flipController;
  late AnimationController _rotationController;
  late Animation<double> _flipAnimation;
  late Animation<double> _rotationAnimation;
  late bool _isFrontVisible;
  final _random = math.Random();
  Timer? _rotationTimer;
  double _currentRotation = 0.0;
  double _targetRotation = 0.0;

  @override
  void initState() {
    super.initState();
    currentSnapAreaIndex = widget.initialSnapAreaIndex;
    _currentRotation = widget.config.initialRotation ?? 0.0;
    _isFrontVisible = widget.config.initiallyFaceUp;
    _initializePosition();
    _initializeAnimations();

    // Set initial flip animation value based on card face
    if (!_isFrontVisible) {
      _flipController.value = 1.0; // Start with back side showing
    }
  }

  void _initializeAnimations() {
    _flipController = AnimationController(
      duration: widget.config.flipDuration,
      vsync: this,
    );

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

    _rotationController = AnimationController(
      duration: widget.config.rotationTransitionDuration,
      vsync: this,
    );

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

  void _startRandomRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(widget.config.rotationUpdateInterval, (timer) {
      if (mounted) {
        final maxRadians = widget.config.maxRotationDegrees * math.pi / 180;
        _targetRotation = (_random.nextDouble() * 2 - 1) * maxRadians;
        _rotationController.forward(from: 0);
      }
    });
  }

  void _stopRandomRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }

  void _initializePosition() {
    if (widget.config.initialPosition != null) {
      position = widget.config.initialPosition!;
    } else {
      final snapArea = widget.snapAreas[widget.initialSnapAreaIndex];
      position = Offset(
        snapArea.position.dx + (snapArea.size.width - cardSize.width) / 2,
        snapArea.position.dy + (snapArea.size.height - cardSize.height) / 2,
      );
    }
  }

  Size get cardSize => Size(
    widget.config.cardWidth,
    widget.config.cardWidth * widget.config.cardAspectRatio,
  );

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

    // Find the nearest snap area
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

    // Always snap to the nearest area, regardless of current position
    setState(() {
      currentSnapAreaIndex = nearestAreaIndex;
      position = widget.snapAreas[nearestAreaIndex].clampPosition(position, cardSize);

      // Apply a small random rotation when snapping
      final maxRadians = widget.config.maxRotationDegrees * math.pi / 180;
      _targetRotation = (_random.nextDouble() - 0.5) * 2 * maxRadians;
      _rotationController.forward(from: 0);
    });
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
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          _startRandomRotation();
          widget.onDragStart?.call();
        },
        onPanUpdate: (details) {
          final newPosition = Offset(
            position.dx + details.delta.dx,
            position.dy + details.delta.dy,
          );

          setState(() {
            // Allow free movement while dragging
            position = newPosition;
            // Check if we're in a snap area
            _updateSnapArea(position);
          });
        },
        onPanEnd: (details) => _snapToNearestArea(),
        onPanCancel: () => _stopRandomRotation(),
        onTap: _flipCard,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_currentRotation),
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
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(
                        _isFrontVisible
                            ? 'assets/cards/${widget.suit}/${widget.suit}-${widget.rank}.png'
                            : 'assets/cards/back.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
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