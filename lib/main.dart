import 'package:flutter/material.dart';
import 'package:splash_view/source/presentation/pages/splash_view.dart';
import 'package:splash_view/source/presentation/widgets/done.dart';
import 'package:visual_acuity_for_surveys/screens/calibraion_screen.dart';
import 'package:visual_acuity_for_surveys/screens/history_screen.dart';
import 'package:visual_acuity_for_surveys/screens/instructions/distance_screen.dart';
import 'package:visual_acuity_for_surveys/screens/result.dart';
import 'package:visual_acuity_for_surveys/screens/splash_screen.dart';
import 'package:visual_acuity_for_surveys/screens/tests/e_optotest.dart';
import 'package:visual_acuity_for_surveys/screens/tests/test_home.dart';
import 'Logger/logger.dart';
import 'screens/home_screen.dart';
import 'screens/instructions_screen.dart';
import 'screens/tutorial_screen.dart';

void main() {
  logger.i("initializing the app");
  runApp(VisualAcuityApp());
}

class VisualAcuityApp extends StatelessWidget {
  const VisualAcuityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Acuity Testing for surveys',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashView(
        backgroundColor: Colors.white,
        loadingIndicator: const CircularProgressIndicator(color: Colors.indigo),
        logo: SplashScreen(),
        done: Done(const HomeScreen()),
        duration: const Duration(seconds: 2),
      ),

      routes: {
        '/calibrate': (context) => CalibrationScreen(),
        '/test': (context) => TestScreenWrapper(),
        '/testHome': (context) => PatientInputScreenWrapper(),
        '/summary': (context) => const SummaryScreenWrapper(),
        '/distance': (context) => DistanceScreenWrapper(),
        '/instructions': (context) => const InstructionsScreen(),
        '/tutorial': (context) => TutorialScreen(),
        '/history': (context) => const HistoryScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
