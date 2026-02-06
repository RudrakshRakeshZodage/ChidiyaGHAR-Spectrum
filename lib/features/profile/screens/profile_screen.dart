import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Working Professional', style: TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 32),
            _buildProfileItem(Icons.person_outline_rounded, 'Edit Profile', () {}),
            _buildProfileItem(Icons.verified_user_outlined, 'Data Verification (Blockchain)', () {}),
            _buildProfileItem(Icons.privacy_tip_outlined, 'Privacy Settings', () {}),
            _buildProfileItem(Icons.file_download_outlined, 'Export Health Data', () {}),
            const Divider(height: 48),
            _buildProfileItem(Icons.logout_rounded, 'Logout', () => Navigator.pushReplacementNamed(context, '/login'), isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : AppColors.textBody, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    );
  }
}
