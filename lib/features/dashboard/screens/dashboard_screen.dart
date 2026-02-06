import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/user_model.dart';
import '../widgets/nutrition_rings.dart';
import '../widgets/quick_actions.dart';

class DashboardScreen extends StatelessWidget {
  final UserData user;
  const DashboardScreen({super.key, required this.user});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()},',
                        style: const TextStyle(color: AppColors.textLight, fontSize: 16),
                      ),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const NutritionRings(),
              const SizedBox(height: 32),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const QuickActionsGrid(),
              const SizedBox(height: 32),
              _buildHealthTip(user),
              if (user.isFemale) ...[
                const SizedBox(height: 24),
                _buildMenstrualPreview(context),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/scan');
          if (index == 2) Navigator.pushNamed(context, '/ai-chat');
          if (index == 3) Navigator.pushNamed(context, '/professionals');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_rounded), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Experts'),
        ],
      ),
    );
  }

  Widget _buildHealthTip(UserData user) {
    String tip = "Stay hydrated and keep moving!";
    if (user.category == 'Working Professional') {
      tip = "Remember to take a 5-minute break every hour to stretch your back.";
    } else if (user.category == 'Senior Citizen') {
      tip = "A 10-minute walk after breakfast can significantly boost your digestion.";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Health Tip', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(tip, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenstrualPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop_rounded, color: Colors.pink),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cycle Tracking', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                Text('Your next cycle starts in 4 days. Stay prepared!', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/menstrual'),
            child: const Text('Track', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
    );
  }
}
