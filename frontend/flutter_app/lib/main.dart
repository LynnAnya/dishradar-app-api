import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'screens/home_screen.dart'; 
import 'screens/auth_screen.dart'; 
import 'providers/user_provider.dart'; // Import your new provider

void main() {
  runApp(
    // 2. Wrap your entire app in ProviderScope (The Master Backpack)
    const ProviderScope(
      child: DishRadarApp(),
    ),
  );
}

// 3. Change StatelessWidget to ConsumerWidget
class DishRadarApp extends ConsumerWidget {
  const DishRadarApp({super.key});

  @override
  // 4. Add WidgetRef to the build method
  Widget build(BuildContext context, WidgetRef ref) {
    
    // 5. 🎒 Listen to the UserProvider right at the root of your app!
    final userState = ref.watch(userProvider);

    return MaterialApp(
      title: 'DishRadar',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => const AuthScreen(),
      },
      
      // 6. ✨ Riverpod magically handles the Startup Flow!
      home: userState.when(
        // App just opened: Waiting for the backend to verify the user
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        
        // Token is expired, missing, or internet failed -> Kick to Login
        error: (error, stack) => const AuthScreen(),
        
        // Backend answered: Did we get a user?
        data: (user) {
          if (user != null) {
            return const HomeScreen(); // Valid user! Welcome in.
          } else {
            return const AuthScreen(); // No user, please log in.
          }
        },
      ),
    );
  }
}