import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../managers/test_history.dart'; // If using SVG eye icon

class SummaryScreenWrapper extends StatelessWidget {
  const SummaryScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return SummaryScreen(
      finalResult: args['finalResult'],
      patientInfo: args['patientInfo'],
      visionType: args['visionType'],
    );
  }
}

class SummaryScreen extends StatefulWidget {
  final String finalResult;
  final String patientInfo;
  final String visionType;

  const SummaryScreen({
    super.key,
    required this.finalResult,
    required this.patientInfo,
    required this.visionType,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveTestOnce();
  }

  Future<void> _saveTestOnce() async {
    if (_saved) return;
    _saved = true;

    await TestHistoryManager.saveTest(
      dateTime: DateTime.now().toIso8601String(),
      patientInfo: widget.patientInfo,
      visionType: widget.visionType,
      result: widget.finalResult,
    );
  }

  String _getExplanation(String result) {
    switch (result) {
      case '6/9':
        return "You have great distance vision...";
      case '6/12':
        return "You have good distance vision...";
      case '6/18':
        return "You can recognize large letters...";
      case '6/60':
      case '3/60':
        return "Your distance vision is reduced...";
      case 'PL+':
        return "You are able to perceive light...";
      case 'PL-':
        return "No light perception detected...";
      case 'N6':
        return "You have excellent near vision...";
      case 'N6-failed':
        return "Your near vision is below normal levels...";
      default:
        return "This is a general vision result...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF5),
      appBar: AppBar(
        title: const Text('Test Summary'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Lottie.asset(
              'assets/animations/glow_eye.json',
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECF3),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    'Final Acuity Result',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.finalResult,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What does "${widget.finalResult}" mean?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getExplanation(widget.finalResult),
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.popAndPushNamed(
                  context,
                  '/testHome',
                  arguments: {'patientInfo': widget.patientInfo},
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Restart Test"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white, //
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.popAndPushNamed(context, '/history'),
                icon: const Icon(Icons.table_chart),
                label: const Text("View Results"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white, //
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
