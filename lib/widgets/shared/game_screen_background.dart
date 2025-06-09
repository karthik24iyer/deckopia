import 'package:flutter/material.dart';
import 'package:deckopia/util/config_provider.dart';

class GameScreenBackground extends StatelessWidget {
  final Widget child;

  const GameScreenBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(context),
        _buildOverlay(context),
        child,
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(context.config.colors.whiteGradient.top),
            Colors.white.withOpacity(context.config.colors.whiteGradient.bottom),
          ],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: Image.asset(
          context.assetsConfig.images.homeBackground,
          fit: BoxFit.cover,
          opacity: AlwaysStoppedAnimation(context.config.background.imageOpacity),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: context.appConfig.theme.backgroundColor.withOpacity(context.config.colors.standardOverlay),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.appConfig.theme.backgroundColor.withOpacity(context.config.background.overlay.opacityTop),
              context.appConfig.theme.backgroundColor.withOpacity(context.config.background.overlay.opacityBottom),
            ],
          ),
        ),
      ),
    );
  }
}
