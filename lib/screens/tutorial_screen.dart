import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  final List<_TutorialStep> _steps = const [
    _TutorialStep(
      title: 'Step 1: Calibrate Your Screen',
      description:
      'Before beginning the test, tap on "Calibrate Screen" to ensure the size of the optotype is accurate for your screen. Follow the instructions on the calibration page.',
      imagePath: 'assets/images/tutorial/calibrate.png',
    ),
    _TutorialStep(
      title: 'Step 2: Maintain Distance',
      description:
      'Sit or stand at the specified distance (e.g., 3 meters or 1 meter) from the screen. You will be instructed to adjust your position if needed.',
      imagePath: 'assets/images/tutorial/distance.png',
    ),
    _TutorialStep(
      title: 'Step 3: Swipe Direction',
      description:
      'You will see an "E" symbol pointing in one of four directions (up, down, left, right). Swipe on the screen in the direction the "E" is pointing.',
      imagePath: 'assets/images/tutorial/swipe.png',
    ),
    _TutorialStep(
      title: 'Step 4: Monitor Brightness',
      description:
      'The app will monitor ambient brightness. If it is too bright, a warning will appear and testing will pause.',
      imagePath: 'assets/images/tutorial/brightness.png',
    ),
    _TutorialStep(
      title: 'Step 5: Get Results',
      description:
      'After completing the visual test, your final acuity score (like 6/12, 6/60, etc.) will be shown on the summary screen.',
      imagePath: 'assets/images/tutorial/result.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: PageView.builder(
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final step = _steps[index];
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  step.description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
                Image.asset(
                  step.imagePath,
                  height: 250,
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}

class _TutorialStep {
  final String title;
  final String description;
  final String imagePath;

  const _TutorialStep({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
