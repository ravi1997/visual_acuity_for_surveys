import 'package:flutter/material.dart';

class DistanceScreenWrapper extends StatelessWidget {
  const DistanceScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final double minDistance = args['distance']?.toDouble() ?? 3.0;

    return DistanceScreen(minimumDistanceMeters: minDistance);
  }
}

class DistanceScreen extends StatelessWidget {
  final double minimumDistanceMeters;

  const DistanceScreen({super.key, required this.minimumDistanceMeters});

  String _getImageForDistance(double distance) {
    if (distance <= 0.4) {
      return 'assets/images/instructions/distance_30cm.png';
    } else if (distance <= 1.5) {
      return 'assets/images/instructions/distance_1m.png';
    } else {
      return 'assets/images/instructions/distance_3m.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getImageForDistance(minimumDistanceMeters);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              '📏 Distance Instruction',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  const TextSpan(text: 'Please ensure you are at least '),
                  TextSpan(
                    text: '${minimumDistanceMeters.toStringAsFixed(1)} meters',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                    ' away from the screen.\n\nUse a measuring tape, mark on the floor, or step back until you reach the correct distance.',
                  ),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            Image.asset(imagePath, fit: BoxFit.contain),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Proceed'),
          ),
        ),
      ),
    );
  }
}
