import 'package:flutter/material.dart';
import '../models/theme_colors.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeColors get colors => _isDark ? darkColors : lightColors;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
