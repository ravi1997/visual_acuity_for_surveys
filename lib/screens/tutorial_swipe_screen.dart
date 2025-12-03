import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class TutorialSwipeScreen extends StatelessWidget {
  const TutorialSwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final step = _TutorialStep(
      title: 'Swipe Instruction',
      description:
          'You will see an "E" symbol pointing in one of four directions (up, down, left, right). Swipe on the screen in the direction the "E" is pointing.',
      imagePath: 'assets/images/tutorial/swipe.jpg',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Swipe Screen'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Skip'),
          ),
        ],
      ),
      body: Padding(
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
            Image.asset(step.imagePath, height: 250),
          ],
        ),
      ),
    );
  }
}
