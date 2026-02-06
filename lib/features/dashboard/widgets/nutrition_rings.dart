import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class NutritionRings extends StatelessWidget {
  const NutritionRings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nutrition Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('1,240 / 2,000 kcal', style: TextStyle(color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRing(0.6, 'Protein', AppColors.primary, '45/80g'),
              _buildRing(0.4, 'Carbs', AppColors.accent, '120/250g'),
              _buildRing(0.8, 'Fats', AppColors.secondary, '50/65g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRing(double progress, String label, Color color, String value) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                color: color,
                backgroundColor: color.withOpacity(0.1),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }
}
