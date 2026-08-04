import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void useSystemTheme() {
    state = ThemeMode.system;
  }

  void useLightTheme() {
    state = ThemeMode.light;
  }

  void useDarkTheme() {
    state = ThemeMode.dark;
  }

  void toggle(Brightness platformBrightness) {
    switch (state) {
      case ThemeMode.light:
        state = ThemeMode.dark;
      case ThemeMode.dark:
        state = ThemeMode.light;
      case ThemeMode.system:
        state = platformBrightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark;
    }
  }
}
