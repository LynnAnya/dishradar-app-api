import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_screen.dart'; 
import 'screens/auth_screen.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MealFinderApp(),
    ),
  );
}

class MealFinderApp extends ConsumerWidget {
  const MealFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return MaterialApp(
      title: 'MealFinder',
      debugShowCheckedModeBanner: false,
      routes: {
        '/main': (context) => const MainScreen(), 
        '/auth': (context) => const AuthScreen(),
      },
      
      // Startup Flow Handler
      home: userState.when(
        // App is checking token on launch
        loading: () => const Scaffold(
          backgroundColor: Color(0xFFFEFDF7),
          body: Center(child: CircularProgressIndicator()),
        ),
        
        error: (error, stack) => const AuthScreen(),
        
        // Backend verification result
        data: (user) {
          if (user != null) {
            return const MainScreen(); 
          } else {
            return const AuthScreen(); 
          }
        },
      ),
    );
  }
}