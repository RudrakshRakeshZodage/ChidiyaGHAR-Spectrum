import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/user_model.dart';
import '../widgets/nutrition_rings.dart';
import '../widgets/quick_actions.dart';
import '../../nutrition/screens/food_scan_screen.dart';
import '../../../services/health_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  final UserData user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _hydrationTimer;
  final HealthService _healthService = HealthService();

  @override
  void initState() {
    super.initState();
    _healthService.addListener(_onHealthUpdate);
    // Vitals Simulation (Real-time feel)
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        _healthService.addSteps(3); // Simulate few steps every 15s
      }
    });

    _hydrationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.local_drink_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Time to drink water! Keep your hydration goal on track. 💧')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.cyan,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _healthService.removeListener(_onHealthUpdate);
    _hydrationTimer?.cancel();
    super.dispose();
  }

  void _onHealthUpdate() {
    if (mounted) setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingPhrase(UserData user) {
    if (user.category == 'Teenager') return 'Stay active,';
    if (user.category == 'Senior Citizen') return 'Take it easy,';
    return '${_getGreeting()},';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Premium Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/dashboard_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withOpacity(0.8),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
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
                            _getGreetingPhrase(widget.user),
                            style: const TextStyle(color: AppColors.textLight, fontSize: 16),
                          ),
                          Text(
                            _healthService.currentData.userName,
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBody,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Hero(
                          tag: 'profile_avatar',
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const NutritionRings(),
                  const SizedBox(height: 32),
                  const Text(
                    'Health Hub',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const QuickActionsGrid(),
                  const SizedBox(height: 32),
                  _buildActiveGoals(),
                  const SizedBox(height: 32),
                  _buildHealthTip(context, widget.user),
                  if (widget.user.isFemale) ...[
                    const SizedBox(height: 24),
                    _buildMenstrualPreview(context),
                  ],
                  const SizedBox(height: 80), // Extra space for bottom nav
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildActiveGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Goals',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Column(
            children: [
              _buildGoalItem('Hydration', 'Drink 3L of water', 0.4, Colors.cyan),
              const SizedBox(height: 16),
              _buildGoalItem('Activity', '10k steps daily', 0.64, Colors.blue),
              const SizedBox(height: 16),
              _buildGoalItem('Protein', '80g daily intake', 0.55, AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalItem(String title, String subtitle, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(10),
          minHeight: 10,
        ),
      ],
    );
  }

  Widget _buildHealthTip(BuildContext context, UserData user) {
    String title = "Daily Wellness";
    String tip = "Stay hydrated and keep moving!";
    
    if (user.category == 'Working Professional') {
      title = "Office Wellness";
      tip = "Take a 5-min walk every 90 mins to improve circulation.";
    } else if (user.category == 'Senior Citizen') {
      title = "Gentle Care";
      tip = "Morning sunlight for 15 mins helps with Vitamin D and sleep.";
    } else if (user.category == 'Teenager') {
      title = "Growth Tip";
      tip = "Consistent 8-hour sleep is vital for hormone regulation and growth.";
    } else if (user.category == 'Housewife') {
      title = "Home Health";
      tip = "Small intervals of yoga can help manage daily household stress.";
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/ai-chat'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(tip, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
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
