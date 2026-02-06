import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api_keys.dart';

class MenstrualModule extends StatefulWidget {
  const MenstrualModule({super.key});

  @override
  State<MenstrualModule> createState() => _MenstrualModuleState();
}

class _MenstrualModuleState extends State<MenstrualModule> {
  final List<String> _symptoms = ['Cramps', 'Headache', 'Bloating', 'Mood Swings', 'Fatigue'];
  final Set<String> _selectedSymptoms = {};
  bool _isPrivacyEnabled = true;
  bool _isAILoading = false;
  String _aiAdvice = "Tap to generate AI advice based on your current phase and symptoms.";

  // New Dynamic States
  int _cycleLength = 28;
  int _periodLength = 5;
  int _currentDay = 18;

  void _showSettingsDialog() {
    int tempCycle = _cycleLength;
    int tempPeriod = _periodLength;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cycle Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _cycleLength.toString(),
              decoration: const InputDecoration(labelText: 'Cycle Length (days)'),
              keyboardType: TextInputType.number,
              onChanged: (val) => tempCycle = int.tryParse(val) ?? 28,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _periodLength.toString(),
              decoration: const InputDecoration(labelText: 'Period Duration (days)'),
              keyboardType: TextInputType.number,
              onChanged: (val) => tempPeriod = int.tryParse(val) ?? 5,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cycleLength = tempCycle;
                _periodLength = tempPeriod;
              });
              Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _getAIAdvice() async {
    setState(() => _isAILoading = true);
    
    String phase = "Follicular Phase";
    if (_currentDay <= _periodLength) phase = "Menstrual Phase";
    else if (_currentDay > 13 && _currentDay < 17) phase = "Ovulation Phase";
    else if (_currentDay >= 17) phase = "Luteal Phase";

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${ApiKeys.geminiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are a specialized women health advisor. \n'
                          'Patient is on Day $_currentDay of her $_cycleLength-day cycle (Phase: $phase). \n'
                          'Current Symptoms: ${_selectedSymptoms.join(', ')}. \n'
                          'Provide 2-3 specific, empathetic nutritional and activity tips to manage these symptoms and improve wellness during this phase.'
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiAdvice = data['candidates'][0]['content']['parts'][0]['text'];
        });
      }
    } catch (e) {
      setState(() => _aiAdvice = "Could not fetch advice. Please check your connection.");
    } finally {
      setState(() => _isAILoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menstrual Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettingsDialog,
          ),
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
    String phase = "Follicular Phase";
    if (_currentDay <= _periodLength) phase = "Menstrual Phase";
    else if (_currentDay > 13 && _currentDay < 17) phase = "Ovulation Phase";
    else if (_currentDay >= 17) phase = "Luteal Phase";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.pink.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text('Day $_currentDay of $_cycleLength', style: const TextStyle(fontSize: 16, color: Colors.pink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(phase, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNum = (_currentDay - 3 + index);
              final isToday = dayNum == _currentDay;
              final isPeriod = dayNum <= _periodLength && dayNum > 0;

              return Column(
                children: [
                  Text(dayNum > 0 ? 'D$dayNum' : '', style: TextStyle(fontSize: 12, color: isToday ? Colors.pink : AppColors.textLight)),
                  const SizedBox(height: 8),
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.pink : (isPeriod ? Colors.pink.withOpacity(0.1) : Colors.white),
                      shape: BoxShape.circle,
                      border: Border.all(color: isToday ? Colors.pink : (isPeriod ? Colors.pink : Colors.grey.shade300)),
                    ),
                    child: Center(
                      child: dayNum > 0 ? Text(
                        '$dayNum',
                        style: TextStyle(
                            color: isToday ? Colors.white : (isPeriod ? Colors.pink : AppColors.textBody), 
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                        ),
                      ) : null,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Your period duration is set to $_periodLength days.',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendation() {
    return InkWell(
      onTap: _isAILoading ? null : _getAIAdvice,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('AI Food & Activity Advice', style: TextStyle(fontWeight: FontWeight.bold)),
                if (_isAILoading) ...[
                  const Spacer(),
                  const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                ]
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _aiAdvice,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            if (!_isAILoading && _aiAdvice.startsWith('Tap')) 
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Tap to refresh', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientTracking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nutrient Focus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildNutrientProgress('Iron', _currentDay <= _periodLength ? 0.9 : 0.6, Colors.redAccent),
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
