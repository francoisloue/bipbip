import 'package:flutter/material.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  int userId = 2;
  ThemeMode themeMode = ThemeMode.light;

  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  void setUserId(int id) {
    userId = id;
    _notify();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _notify();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _notify();
  }
}
