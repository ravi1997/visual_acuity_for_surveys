
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

import '../../Logger/logger.dart';

class PlTest extends StatefulWidget {
  String patientInfo;
  String visionType;
  final void Function(bool canSeeLight) onComplete;

  PlTest({super.key, required this.patientInfo,
    required this.visionType,required this.onComplete});

  @override
  State<PlTest> createState() => _PlTestState();
}

class _PlTestState extends State<PlTest> {
  @override
  void initState() {
    super.initState();
    _enableTorch();
  }

  Future<void> _enableTorch() async {
    try {
      await TorchLight.enableTorch();
    } catch (e) {
      logger.d("Torch error: $e");
    }
  }

  Future<void> _disableTorch() async {
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      logger.d("Torch error: $e");
    }
  }

  void _handleAnswer(bool canSeeLight) async {
    await _disableTorch();
    widget.onComplete(canSeeLight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Can you see the light?"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleAnswer(true),
              child: const Text("Yes"),
            ),
            ElevatedButton(
              onPressed: () => _handleAnswer(false),
              child: const Text("No"),
            ),
          ],
        ),
      ),
    );
  }
}
