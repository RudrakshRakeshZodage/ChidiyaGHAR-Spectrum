import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme.dart';
import '../../../services/auth_service.dart';

class SignupDetailsScreen extends StatefulWidget {
  final bool isSpecialist;
  const SignupDetailsScreen({super.key, required this.isSpecialist});

  @override
  State<SignupDetailsScreen> createState() => _SignupDetailsScreenState();
}

class _SignupDetailsScreenState extends State<SignupDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  String _category = 'Working Professional';
  String _specialization = 'Nutritionist'; // For Specialists
  
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleGoogleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // 1. Perform Google Sign In
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        
        // 2. Prepare Profile Data
        final profileData = {
          'id': user.uid, // Firebase UID or Supabase ID depending on auth provider usage
          'email': user.email,
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'gender': _gender,
          'category': _category,
          'role': widget.isSpecialist ? 'specialist' : 'user',
          'specialization': widget.isSpecialist ? _specialization : null,
          'created_at': DateTime.now().toIso8601String(),
        };

        // 3. Save to Database (Supabase)
        // Check if user already exists to avoid overwriting or duplicate key errors if using upsert blindly without care, 
        // but here we are "signing up", so upsert is generally safe for profile creation.
        await Supabase.instance.client.from('users').upsert(profileData);

        // 4. Navigate to correct Dashboard
        if (mounted) {
           if (widget.isSpecialist) {
             Navigator.pushNamedAndRemoveUntil(context, '/specialist-dashboard', (route) => false);
           } else {
             Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
           }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSpecialist ? 'Specialist Details' : 'Your Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us a bit about yourself',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'We need this to personalize your experience.',
                  style: TextStyle(color: AppColors.textLight),
                ),
                const SizedBox(height: 32),
                
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                // Age
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                   validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                // Gender
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc_rounded)),
                  items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _gender = val!),
                ),
                const SizedBox(height: 16),

                // Category (User) or Specialization (Specialist)
                if (widget.isSpecialist) 
                  DropdownButtonFormField<String>(
                    value: _specialization,
                    decoration: const InputDecoration(labelText: 'Specialization'),
                     items: ['Nutritionist', 'Physiotherapist', 'Yoga Instructor', 'Psychologist']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _specialization = val!),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                     items: ['Student', 'Working Professional', 'Housewife', 'Senior Native']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                
                const SizedBox(height: 48),

                // Google Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network('https://www.google.com/favicon.ico', width: 24),
                            const SizedBox(width: 12),
                            const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                   child: Text(
                    'By continuing, you agree to our Terms & Conditions.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 12),
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
