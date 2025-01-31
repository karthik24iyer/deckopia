import 'package:flutter/material.dart';

import '../config/app_config.dart';

class ConfigProvider extends InheritedWidget {
  final Config config;

  const ConfigProvider({
    super.key,
    required this.config,
    required super.child,
  });

  static Config of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ConfigProvider>();
    assert(provider != null, 'No ConfigProvider found in context');
    return provider!.config;
  }

  @override
  bool updateShouldNotify(ConfigProvider oldWidget) {
    return config != oldWidget.config;
  }
}

extension ConfigProviderExtension on BuildContext {
  Config get config => ConfigProvider.of(this);
  CardConfig get cardConfig => config.card;
  LayoutConfig get layoutConfig => config.layout;
  SnapConfig get snapAreaConfig => config.snapArea;
  AppConfig get appConfig => config.app;
}