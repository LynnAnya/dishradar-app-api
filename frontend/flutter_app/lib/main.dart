import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const DishRadarApp());
}

class DishRadarApp extends StatelessWidget {
  const DishRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DishRadar',
      debugShowCheckedModeBanner: false, // Hides the top-right DEBUG ribbon
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1F1D2B), // Prevents white flashes while loading
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const MainScreen(), // Launches your search & filter UI on startup
    );
  }
}