import 'package:flutter/material.dart';

class TooltipHelper {
  OverlayEntry? _overlayEntry;
  String? _tooltipMessage;

  void showTooltip(String message, GlobalKey key, BuildContext context) {
    hideTooltip();

    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final position = renderBox.localToGlobal(Offset.zero);
    _tooltipMessage = message;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 50,
        top: position.dy - 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFECB3)),
            ),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontFamily: 'CaveatBrush',
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-hide tooltip after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      hideTooltip();
    });
  }

  void hideTooltip() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _tooltipMessage = null;
  }

  String? get tooltipMessage => _tooltipMessage;

  void dispose() {
    hideTooltip();
  }
}
