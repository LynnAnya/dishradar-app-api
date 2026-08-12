import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'auth_screen.dart';
import '../providers/user_provider.dart'; 

// 3. Change to ConsumerStatefulWidget
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

// 4. ✨ Change to ConsumerState
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // 🎨 Exact Same Theme Colors
  final Color bgColor = const Color(0xFFFEFDF7);
  final Color cardColor = Colors.white;
  final Color accentColor = const Color.fromARGB(255, 187, 182, 242);
  final Color textMain = const Color.fromARGB(255, 48, 48, 48);
  final Color textMuted = const Color(0xFF757575);
  final Color outlineColor = const Color.fromARGB(255, 88, 88, 88);

  // This is purely local UI state, so it stays here! No need to put this in Riverpod.
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

  // The final delete action
  Future<void> _executeDeleteAccount() async {
    Navigator.of(context).pop(); // Pop the confirmation dialog
    
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 🚀 Tell Riverpod to handle the deletion logic (API + Token + RAM)
      await ref.read(userProvider.notifier).deleteAccount();
      
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading indicator
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const AuthScreen()), 
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  //  Step 2 of Delete: Are you sure?
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          title: Text('Delete Account', style: TextStyle(color: textMain, fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.',
            style: TextStyle(color: textMain),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _executeDeleteAccount, // Calls the updated function above
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 📄 Step 1 of Details: Show User Details Modal
  void _showUserDetails(String joinedDate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: outlineColor, width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textMain)),
              const SizedBox(height: 20),
              
              _buildDetailRow(Icons.calendar_today, 'First joined', joinedDate),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.login, 'Logged in via', 'Email and Password'),
              
              const SizedBox(height: 32),
              const Divider(),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text('Delete my account and data', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context); 
                  _showDeleteConfirmation(); 
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: textMuted, size: 20),
        const SizedBox(width: 12),
        Text('$label: ', style: TextStyle(color: textMuted, fontSize: 16)),
        Expanded(child: Text(value, style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.w600))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //  5. Listen to the Riverpod state!
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textMain),
        title: Text(
          'My Profile',
          style: TextStyle(color: textMain, fontWeight: FontWeight.w600, fontSize: 22),
        ),
      ),
      // 6. Use .when() to automatically draw the correct UI based on the API status
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (user) {
          // Fallback if data somehow got wiped but they are still on the screen
          if (user == null) return const Center(child: Text('No user found.'));

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Dynamic Interactive Profile Header
              GestureDetector(
                onTap: () => _showUserDetails('Recently'), // Pass any formatted date if needed
                child: Container(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.username} 🍕', // Directly reads from Riverpod's memory
                              style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email, // Directly reads from Riverpod's memory
                              style: TextStyle(color: textMuted, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Settings List
              Container(
                decoration: _doodleDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.5),
                  child: Material(
                    color: Colors.transparent,
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
                          activeThumbColor: accentColor,
                          activeTrackColor: accentColor.withValues(alpha: 0.5),
                          value: _notificationsEnabled,
                          onChanged: (val) {
                            setState(() {
                              _notificationsEnabled = val; // We still use setState for simple local toggles!
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
                          onTap: () async {
                            // 🚀 Tell Riverpod to clear the session!
                            await ref.read(userProvider.notifier).clearSession();
                            
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context, 
                                MaterialPageRoute(builder: (context) => const AuthScreen()), 
                                (route) => false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}