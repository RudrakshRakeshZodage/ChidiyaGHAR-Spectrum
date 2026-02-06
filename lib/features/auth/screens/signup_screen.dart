import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'Male';
  String _userRole = 'User'; // 'User' or 'Professional'
  String _specialistType = 'Nutritionist';
  String _userCategory = 'Working Professional';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset('assets/logo.jpeg', width: 100, height: 100),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Join VitaAI',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Your journey to a healthier lifestyle starts here',
                  style: TextStyle(color: AppColors.textLight),
                ),
                const SizedBox(height: 48),
                const Spacer(),
                const Text(
                  'Join a community of thousands improving their health with AI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Role Selection after Google Auth
                    Navigator.pushNamed(context, '/role-selection');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network('https://www.google.com/favicon.ico', width: 20),
                      const SizedBox(width: 12),
                      const Text('Sign Up with Google'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Already have an account? Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
