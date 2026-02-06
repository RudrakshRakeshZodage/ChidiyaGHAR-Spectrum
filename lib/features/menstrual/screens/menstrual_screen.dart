import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class MenstrualModule extends StatefulWidget {
  const MenstrualModule({super.key});

  @override
  State<MenstrualModule> createState() => _MenstrualModuleState();
}

class _MenstrualModuleState extends State<MenstrualModule> {
  final List<String> _symptoms = ['Cramps', 'Headache', 'Bloating', 'Mood Swings', 'Fatigue'];
  final Set<String> _selectedSymptoms = {};
  bool _isPrivacyEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menstrual Health'),
        actions: [
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 16),
              Switch(
                value: _isPrivacyEnabled,
                onChanged: (val) => setState(() => _isPrivacyEnabled = val),
                activeColor: Colors.pink,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCycleTimeline(),
            const SizedBox(height: 32),
            const Text('How are you feeling today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptoms.map((s) {
                final isSelected = _selectedSymptoms.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) _selectedSymptoms.add(s);
                      else _selectedSymptoms.remove(s);
                    });
                  },
                  selectedColor: Colors.pink.withOpacity(0.2),
                  checkmarkColor: Colors.pink,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            _buildAIRecommendation(),
            const SizedBox(height: 32),
            _buildNutrientTracking(),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.pink.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text('Day 18 of 28', style: TextStyle(fontSize: 16, color: Colors.pink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Ovulation Phase', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = 15 + index;
              final isToday = day == 18;
              return Column(
                children: [
                  Text('D$day', style: TextStyle(fontSize: 12, color: isToday ? Colors.pink : AppColors.textLight)),
                  const SizedBox(height: 8),
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.pink : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isToday ? Colors.pink : Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        '${day - 14}',
                        style: TextStyle(color: isToday ? Colors.white : AppColors.textBody, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('AI Food Recommendation', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'During the ovulation phase, focus on anti-inflammatory foods like fatty fish and leafy greens to maintain energy levels.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientTracking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nutrient Focus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildNutrientProgress('Iron', 0.6, Colors.redAccent),
        const SizedBox(height: 12),
        _buildNutrientProgress('Magnesium', 0.4, Colors.purpleAccent),
      ],
    );
  }

  Widget _buildNutrientProgress(String label, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${(value * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: color.withOpacity(0.1),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
