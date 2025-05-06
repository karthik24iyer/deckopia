import 'package:flutter/material.dart';
import 'package:deckopia/util/config_provider.dart';

class PageTransition extends PageRouteBuilder {
  final Widget child;

  PageTransition({required this.child})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final config = context.tryReadConfig();
      final duration = config?.animations.pageTransitionDuration ?? 200;
      
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200), // Default, will be overridden in transitions
    reverseTransitionDuration: const Duration(milliseconds: 200),
  );
}