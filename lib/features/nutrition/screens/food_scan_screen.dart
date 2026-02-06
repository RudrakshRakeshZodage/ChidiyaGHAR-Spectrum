import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  bool _isScanning = false;

  void _simulateScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isScanning = false);
      _showResult();
    }
  }

  void _showResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => const NutritionResultSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Food')),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 100),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          if (_isScanning)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Analyzing Food...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _simulateScan,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionResultSheet extends StatelessWidget {
  const NutritionResultSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grilled Salmon Salad',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Scanning Result', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 24),
          _buildMetricRow('Calories', '450 kcal', Icons.local_fire_department_rounded, Colors.orange),
          _buildMetricRow('Protein', '35g', Icons.fitness_center_rounded, AppColors.primary),
          _buildMetricRow('Carbs', '12g', Icons.grain_rounded, AppColors.accent),
          _buildMetricRow('Fats', '22g', Icons.opacity_rounded, AppColors.secondary),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add to Daily Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
