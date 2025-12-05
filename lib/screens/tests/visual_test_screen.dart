import 'package:flutter/material.dart';
import 'package:v_a_rpc/screens/tests/pl_test.dart';

import 'finger_test.dart';

class VisualTestScreen extends StatefulWidget {
  String patientInfo;
  String visionType;
  VisualTestScreen({
    super.key,
    required this.patientInfo,
    required this.visionType,
  });

  @override
  State<VisualTestScreen> createState() => _VisualTestScreenState();
}

class _VisualTestScreenState extends State<VisualTestScreen> {
  bool test1Completed = false;
  bool test2Started = false;
  int correctCount = 0;
  int wrongCount = 0;

  void _onTest1Complete(int correct, int wrong) {
    correctCount = correct;
    wrongCount = wrong;
    if (correct >= 4) {
      _showResult('Finger Counting');
    } else {
      setState(() {
        test1Completed = true;
        test2Started = true;
      });
    }
  }

  void _onTest2Complete(bool canSeeLight) {
    _showResult(canSeeLight ? "PL+" : "PL-");
  }

  void _showResult(String result) {
    Navigator.pushReplacementNamed(
      context,
      '/summary',
      arguments: {
        'finalResult': result,
        'totalCorrect': correctCount,
        'totalWrong': wrongCount,
        'ignoredGestures': 0,
        'patientInfo': widget.patientInfo,
        'visionType': widget.visionType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!test1Completed) {
      return FingerTest(
        patientInfo: widget.patientInfo,
        visionType: widget.visionType,
        onComplete: _onTest1Complete,
      );
    } else if (test2Started) {
      return PlTest(
        patientInfo: widget.patientInfo,
        visionType: widget.visionType,
        onComplete: _onTest2Complete,
      );
    } else {
      return const SizedBox();
    }
  }
}
