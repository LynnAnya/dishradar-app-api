import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 🔑 This single boolean controls whether we show Login or Register mode!
  bool _isLogin = true;

  // 🎨 Exact Same Doodle Theme Colors
  final Color bgColor = const Color(0xFFFEFDF7);
  final Color cardColor = Colors.white;
  final Color accentColor = const Color.fromARGB(255, 187, 182, 242);
  final Color registerAccent = const Color(0xFFFF8FA3);
  final Color textMain = const Color.fromARGB(255, 48, 48, 48);
  final Color textMuted = const Color(0xFF757575);
  final Color outlineColor = const Color.fromARGB(255, 88, 88, 88);

  BoxDecoration _doodleDecoration({Color? color, double borderRadius = 12.5}) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: outlineColor, width: 1.0),
      boxShadow: [
        BoxShadow(
          color: outlineColor,
          offset: const Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🍔 App Header Title
                Text(
                  'Meal Finder 🍔',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                      ? 'Welcome back! Sign in to view your profile.' 
                      : 'Create an account to join the community!',
                  style: TextStyle(color: textMuted, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 📝 Single Card Container for both views
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _doodleDecoration(),
                  child: Column(
                    children: [
                      // Show Name field ONLY when in Register mode
                      if (!_isLogin) ...[
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline, color: textMain),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field (Always visible)
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined, color: textMain),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field (Always visible)
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, color: textMain),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🚀 Dynamic Action Button
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isLogin ? 'Signed in! 🎉' : 'Account created! 🎉',
                              ),
                              backgroundColor: outlineColor,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: _doodleDecoration(
                            color: _isLogin ? accentColor : registerAccent,
                            borderRadius: 10,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _isLogin ? 'Sign In 🔑' : 'Register ✨',
                            style: TextStyle(
                              color: textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🔄 Toggle Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? "Don't have an account?" : "Already have an account?",
                      style: TextStyle(color: textMuted),
                    ),
                    TextButton(
                      onPressed: () {
                        // ⚡ Instant state toggle!
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Register' : 'Sign In',
                        style: TextStyle(
                          color: textMain,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}