import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ProfessionalConnectScreen extends StatelessWidget {
  const ProfessionalConnectScreen({super.key});

  final List<Expert> experts = const [
    Expert(name: 'Dr. Sarah Smith', expertise: 'Senior Nutritionist', rating: 4.8, image: 'S'),
    Expert(name: 'James Wilson', expertise: 'Physiotherapist', rating: 4.9, image: 'J'),
    Expert(name: 'Elena Rodriguez', expertise: 'Fitness Expert', rating: 4.7, image: 'E'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect with Experts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: experts.length,
        itemBuilder: (context, index) => _buildExpertCard(context, experts[index]),
      ),
    );
  }

  Widget _buildExpertCard(BuildContext context, Expert expert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(expert.image, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expert.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(expert.expertise, style: const TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                        const SizedBox(width: 4),
                        Text(expert.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Book Session'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/demo-call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('2-Min Demo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Expert {
  final String name;
  final String expertise;
  final double rating;
  final String image;
  const Expert({required this.name, required this.expertise, required this.rating, required this.image});
}
