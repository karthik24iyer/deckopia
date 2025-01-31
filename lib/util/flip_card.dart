import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Function(bool)? onFlipDone;

  const FlipCard({
    Key? key,
    required this.front,
    required this.back,
    this.onFlipDone,
  }) : super(key: key);

  @override
  FlipCardState createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animation.addListener(() {
      if (_animation.value >= math.pi / 2) {
        setState(() {
          _isFrontVisible = false;
        });
      } else {
        setState(() {
          _isFrontVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flipToFront() {
    if (!_isFrontVisible && !_controller.isAnimating) {
      _controller.reverse();
    }
  }

  void flipToBack() {
    if (_isFrontVisible && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  void toggleCard() {
    if (_controller.isAnimating) return;
    if (_isFrontVisible) {
      flipToBack();
    } else {
      flipToFront();
    }
  }

  bool isFrontVisible() => _isFrontVisible;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          var transform = Matrix4.identity();
          transform.setEntry(3, 2, 0.001);
          transform.rotateY(_animation.value);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _isFrontVisible
                ? widget.front
                : Transform(
              transform: Matrix4.identity()..rotateY(math.pi),
              alignment: Alignment.center,
              child: widget.back,
            ),
          );
        },
      ),
    );
  }
}