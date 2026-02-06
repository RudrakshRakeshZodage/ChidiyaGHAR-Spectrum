import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme.dart';

class DemoCallScreen extends StatefulWidget {
  const DemoCallScreen({super.key});

  @override
  State<DemoCallScreen> createState() => _DemoCallScreenState();
}

class _DemoCallScreenState extends State<DemoCallScreen> {
  int _secondsRemaining = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _endCall();
      }
    });
  }

  void _endCall() {
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo call ended automatically after 2 minutes.')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mock Video Background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Connected with Dr. Sarah',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  _formatTime(_secondsRemaining),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallAction(Icons.mic_off_rounded, Colors.white24, () {}),
                _buildCallAction(Icons.call_end_rounded, Colors.redAccent, _endCall),
                _buildCallAction(Icons.videocam_off_rounded, Colors.white24, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
