import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CustomText(text: 'Profile', style: AppStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const CustomText(text: 'Sakshi Raut', style: AppStyles.heading1),
            const SizedBox(height: 8),
            CustomText(text: 'sakshi@example.com', style: AppStyles.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 40),
            
            _buildActionItem(context, Icons.settings, 'Settings', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }),
            const SizedBox(height: 16),
            _buildActionItem(context, Icons.help_outline, 'Help & Support', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help & Support tapped')));
            }),
            const SizedBox(height: 16),
            _buildActionItem(context, Icons.logout, 'Logout', isDestructive: true, onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logout functionality removed')));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$title tapped'),
          duration: const Duration(seconds: 1),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red : AppColors.textPrimary),
            const SizedBox(width: 16),
            CustomText(
              text: title,
              style: AppStyles.title.copyWith(color: isDestructive ? Colors.red : AppColors.textPrimary),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark Mode'),
            trailing: Switch(value: false, onChanged: null),
          ),
        ],
      ),
    );
  }
}
