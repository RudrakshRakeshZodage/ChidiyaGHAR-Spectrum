import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/nutrition/screens/food_scan_screen.dart';
import 'features/ai_chat/screens/ai_chat_screen.dart';
import 'features/menstrual/screens/menstrual_screen.dart';
import 'features/professional/screens/professional_screen.dart';
import 'features/professional/screens/demo_call_screen.dart';
import 'core/user_model.dart';

void main() {
  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaAI Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          return MaterialPageRoute(builder: (context) => DashboardScreen(user: mockUser));
        }
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/scan': (context) => const FoodScanScreen(),
        '/ai-chat': (context) => const AIChatScreen(),
        '/menstrual': (context) => const MenstrualModule(),
        '/professionals': (context) => const ProfessionalConnectScreen(),
        '/demo-call': (context) => const DemoCallScreen(),
      },
    );
  }
}
