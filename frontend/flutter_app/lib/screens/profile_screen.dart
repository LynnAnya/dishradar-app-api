import 'package:flutter/material.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 🎨 Exact Same Theme Colors
  final Color bgColor = const Color(0xFFFEFDF7);
  final Color cardColor = Colors.white;
  final Color accentColor = const Color.fromARGB(255, 187, 182, 242);
  final Color textMain = const Color.fromARGB(255, 48, 48, 48);
  final Color textMuted = const Color(0xFF757575);
  final Color outlineColor = const Color.fromARGB(255, 88, 88, 88);

  bool _notificationsEnabled = true;

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textMain),
        title: Text(
          'Account Settings 👤',
          style: TextStyle(color: textMain, fontWeight: FontWeight.w600, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Profile Header Draft
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _doodleDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: accentColor,
                  child: Icon(Icons.person, color: textMain, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guest User 🍕',
                      style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'guestuser@example.com',
                      style: TextStyle(color: textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Settings List Draft (Fixed: Material placed inside Container)
          Container(
            decoration: _doodleDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.5),
              child: Material(
                color: Colors.transparent, // Keeps original white card color behind it
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_outline, color: textMain),
                      title: Text('Edit Profile', style: TextStyle(color: textMain, fontWeight: FontWeight.w500)),
                      trailing: Icon(Icons.chevron_right, color: textMuted),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit Profile coming soon!')),
                        );
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_none, color: textMain),
                      title: Text('Push Notifications', style: TextStyle(color: textMain, fontWeight: FontWeight.w500)),
                      activeColor: accentColor,
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: Icon(Icons.lock_outline, color: textMain),
                      title: Text('Privacy Policy', style: TextStyle(color: textMain, fontWeight: FontWeight.w500)),
                      trailing: Icon(Icons.chevron_right, color: textMuted),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (context) => const AuthScreen()), 
                          (route) => false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}