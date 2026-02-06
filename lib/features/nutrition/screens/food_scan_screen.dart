import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme.dart';
import '../../../core/api_keys.dart';
import 'package:health_ai/services/health_service.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  bool _isScanning = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final HealthService _healthService = HealthService();

  Future<void> _pickImage(ImageSource source) async {
    // Check permissions every time as requested
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await (Platform.isIOS ? Permission.photos.request() : Permission.storage.request());
    }

    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _analyzeImage();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied. Please enable it in settings.')),
        );
      }
    }
  }

  Future<String?> _uploadToImgBB(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=${ApiKeys.imgBBKey}'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['data']['url'];
      }
    } catch (e) {
      debugPrint('ImgBB Upload Error: $e');
    }
    return null;
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isScanning = true);

    try {
      final dailyData = _healthService.currentData;
      final contextStr = "User Context: ${dailyData.userName}, ${dailyData.height}cm, ${dailyData.weight}kg. TODAY: ${dailyData.steps} steps so far, ${dailyData.water}L water. \n";

      // 1. Upload to ImgBB
      final imageUrl = await _uploadToImgBB(_selectedImage!);
      if (imageUrl == null) throw 'Failed to host image on ImgBB. Check your connection.';

      // 2. Call Grok API with the link
      final response = await http.post(
        Uri.parse('https://api.x.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.grokKey}',
        },
        body: jsonEncode({
          'model': 'grok-vision-beta',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': '$contextStr Analyze this image. \n'
                          '1. If it is a MEAL: Breakdown EVERY item. Return a "meal_content" list.\n'
                          '2. If it is a PACKED FOOD LABEL: Deep dive into the nutrition table. Return a "label_analysis" object with "health_verdict" (Eat/Not), "reasons", and "contextual_advice" based on the user\'s water/steps today.\n'
                          'ALWAYS return ONLY a valid raw JSON object (no markdown blocks): {"is_label": boolean, "meal_content": [{"name": "string", "calories": int, "protein": int, "carbs": int, "fats": int, "calcium": int}], "label_analysis": {"verdict": "string", "carbs_percent": "string", "fats_percent": "string", "advice": "string"}, "is_healthy": boolean, "summary": "string"}'
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': imageUrl
                  }
                }
              ]
            }
          ],
          'temperature': 0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];
        
        // Clean markdown if present
        if (content.contains('```json')) {
          content = content.split('```json')[1].split('```')[0].trim();
        } else if (content.contains('```')) {
          content = content.split('```')[1].split('```')[0].trim();
        }

        final result = jsonDecode(content);
        if (mounted) {
          _showResult(result);
        }
      } else {
        throw Exception('Grok API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _showResult(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NutritionResultSheet(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Food Vision')),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover, height: double.infinity, width: double.infinity)
                : const Center(
                    child: Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 100),
                  ),
          ),
          if (_isScanning)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('AI is identifying your meal...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCaptureButton(Icons.photo_library_outlined, () => _pickImage(ImageSource.gallery)),
                _buildCaptureButton(Icons.camera_alt_rounded, () => _pickImage(ImageSource.camera), isLarge: true),
                _buildCaptureButton(Icons.flash_on_rounded, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton(IconData icon, VoidCallback onTap, {bool isLarge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 80 : 60,
        width: isLarge ? 80 : 60,
        decoration: BoxDecoration(
          color: isLarge ? Colors.white : Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: isLarge ? Colors.black : Colors.white, size: isLarge ? 32 : 24),
      ),
    );
  }
}

class NutritionResultSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  const NutritionResultSheet({super.key, required this.data});

  @override
  State<NutritionResultSheet> createState() => _NutritionResultSheetState();
}

class _NutritionResultSheetState extends State<NutritionResultSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLabel = widget.data['is_label'] ?? false;
    final items = widget.data['meal_content'] ?? [];
    final labelAnalysis = widget.data['label_analysis'] ?? {};
    final bool isHealthy = widget.data['is_healthy'] ?? true;
    final String summary = widget.data['summary'] ?? "Ready to analyze!";

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AI Health Insights', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                _buildStatusBadge(isHealthy),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Meal Content"),
              Tab(text: "Label Decoder"),
            ],
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMealTab(items),
                _buildLabelTab(labelAnalysis),
              ],
            ),
          ),
          _buildActionButtons(context, items),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool healthy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (healthy ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        healthy ? 'Safe to Eat' : 'High Awareness',
        style: TextStyle(color: healthy ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildMealTab(List<dynamic> items) {
    if (items.isEmpty) return const Center(child: Text("No individual meal items detected."));
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildFoodItemCard(items[index]),
    );
  }

  Widget _buildLabelTab(Map<String, dynamic> analysis) {
    if (analysis.isEmpty) return const Center(child: Text("Back label data not found. Upload a label image for deep analysis."));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerdictCard(analysis['verdict'] ?? "Analysis complete", analysis['verdict'] == "EAT"),
          const SizedBox(height: 24),
          _buildDetailRow("Carbohydrates", analysis['carbs_percent'] ?? "N/A"),
          _buildDetailRow("Fats & Lipids", analysis['fats_percent'] ?? "N/A"),
          const SizedBox(height: 24),
          const Text('Smart Advice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(analysis['advice'] ?? "No advice provided.", style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildVerdictCard(String text, bool isPositive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isPositive ? Colors.green : Colors.orange).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(isPositive ? Icons.check_circle_rounded : Icons.warning_amber_rounded, color: isPositive ? Colors.green : Colors.orange, size: 40),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: () {
          final healthService = HealthService();
          for (var item in items) {
            healthService.addFood(
              (item['calories'] as num).toDouble(),
              (item['protein'] as num).toDouble(),
              (item['carbs'] as num).toDouble(),
              (item['fats'] as num).toDouble(),
              (item['calcium'] as num).toDouble(),
            );
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vitals updated! 🥗')));
        },
        child: const Text('Confirm & Log Macros'),
      ),
    );
  }

  Widget _buildFoodItemCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroInfo('Cals', '${item['calories']}', Colors.orange),
              _buildMacroInfo('Pro', '${item['protein']}g', AppColors.primary),
              _buildMacroInfo('Carbs', '${item['carbs']}g', AppColors.accent),
              _buildMacroInfo('Fats', '${item['fats']}g', AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    );
  }
}
