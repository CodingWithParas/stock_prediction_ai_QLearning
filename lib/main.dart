import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Import the package
import 'package:stock_ai/screens/home_screen.dart';
import 'package:stock_ai/screens/portfolio_screen.dart';
import 'package:stock_ai/screens/settings_screen.dart';
import 'package:stock_ai/screens/watchlist_screen.dart';
import 'theme/theme_provider.dart'; // Make sure the theme provider is correctly imported

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Stock Q-Learning App',
      theme: ThemeData(
        scaffoldBackgroundColor: themeProvider.colors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: themeProvider.colors.cardBackground,
          titleTextStyle: TextStyle(color: themeProvider.colors.text),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation();

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PortfolioScreen(),
    WatchlistScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Q-Learning App'),
        backgroundColor: themeProvider.colors.cardBackground, // AppBar background color
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        height: 50.0,
        color: themeProvider.colors.cardBackground, // Set the background color here
        backgroundColor: themeProvider.colors.background, // Set the background color of the container
        buttonBackgroundColor: themeProvider.colors.primary, // Button background color
        items: const [
          Icon(Icons.home, size: 25),
          Icon(Icons.pie_chart, size: 25),
          Icon(Icons.visibility, size: 25),
          Icon(Icons.settings, size: 25),
        ],
        animationDuration: const Duration(milliseconds: 200),
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}