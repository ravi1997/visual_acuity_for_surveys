import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter/services.dart';

import '../../Logger/logger.dart';
import '../../utils/helpers.dart';

class FingerTest extends StatefulWidget {
  String patientInfo;
  String visionType;
  final void Function(int correct, int wrong) onComplete;

  FingerTest({
    super.key,
    required this.patientInfo,
    required this.visionType,
    required this.onComplete,
  });

  @override
  State<FingerTest> createState() => _FingerTestState();
}

class _FingerTestState extends State<FingerTest> {
  int currentIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;

  final bool _lightWarningShown = false;
  final maxLuxValue = 15000;

  late List<int> answerKey;
  late List<int> userAnswers;
  late List<String> svgFiles;
  Timer? _ambientLightTimer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    setBrightnessTo90();
    svgFiles = [
      'assets/images/tests/FC_1.svg',
      'assets/images/tests/FC_2.svg',
      'assets/images/tests/FC_3.svg',
      'assets/images/tests/FC_4.svg',
    ];
    userAnswers = [];
    answerKey = List.generate(5, (_) => Random().nextInt(4) + 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, '/distance', arguments: {'distance': 0.3});
    });
    // Start checking every 3 seconds
    _ambientLightTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
      await checkAmbientLight(maxLuxValue, _lightWarningShown, context);
    });
  }

  void _onUserAnswer(int selected) {
    logger.d("🔢 User selected: $selected");
    logger.d("✅ Correct answer was: ${answerKey[currentIndex]}");

    userAnswers.add(selected);

    if (selected == answerKey[currentIndex]) {
      correctCount++;
      logger.d("🟢 Answer is correct. Total correct: $correctCount");
    } else {
      wrongCount++;
      logger.d("🔴 Answer is wrong. Total wrong: $wrongCount");
    }

    if (wrongCount >= 2) {
      logger.d("❌ User reached 2 wrong answers. Ending test.");
      widget.onComplete(correctCount, wrongCount);
      return;
    }

    if (correctCount >= 4) {
      logger.d("🎉 User reached 4 correct answers. Ending test.");
      widget.onComplete(correctCount, wrongCount);
      return;
    }

    if (userAnswers.length >= 5) {
      logger.d(
        "📊 All answers received. Final score - Correct: $correctCount, Wrong: $wrongCount",
      );
      widget.onComplete(correctCount, wrongCount);
      return;
    }

    setState(() {
      currentIndex++;
      logger.d("➡️ Moving to question #$currentIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<Size>(
              future: getCalibratedSvgSize(context, 9.4, 9.4),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final size = snapshot.data!;
                return SvgPicture.asset(
                  svgFiles[answerKey[currentIndex] - 1],
                  width: size.width,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('How many black lines?'),
            Wrap(
              spacing: 10,
              children: [1, 2, 3, 4, 5]
                  .map(
                    (numVal) => ElevatedButton(
                      onPressed: () => _onUserAnswer(numVal),
                      child: Text((numVal == 5) ? "Can't see" : '$numVal'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ambientLightTimer?.cancel();
    ScreenBrightness().resetApplicationScreenBrightness();

    // Restore preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }
}
