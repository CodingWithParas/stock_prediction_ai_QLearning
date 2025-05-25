import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: ElevatedButton(
        onPressed: themeProvider.toggleTheme,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.isDark
              ? themeProvider.colors.text
              : themeProvider.colors.background, disabledForegroundColor: themeProvider.colors.white.withOpacity(0.38), disabledBackgroundColor: themeProvider.colors.white.withOpacity(0.12), // Text color
        ),
        child: Text("Toggle Theme"),
      ),
    );
  }
}
