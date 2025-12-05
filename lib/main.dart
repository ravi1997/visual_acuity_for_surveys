import 'package:flutter/material.dart';
import 'package:splash_view/source/presentation/pages/splash_view.dart';
import 'package:splash_view/source/presentation/widgets/done.dart';
import 'package:v_a_rpc/screens/about_screen.dart';
import 'package:v_a_rpc/screens/calibraion_screen.dart';
import 'package:v_a_rpc/screens/history_screen.dart';
import 'package:v_a_rpc/screens/instructions/distance_screen.dart';
import 'package:v_a_rpc/screens/result.dart';
import 'package:v_a_rpc/screens/splash_screen.dart';
import 'package:v_a_rpc/screens/tests/e_optotest.dart';
import 'package:v_a_rpc/screens/tests/test_home.dart';
import 'package:v_a_rpc/screens/tutorial_swipe_screen.dart';
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
      title: 'VA RPC',
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
        '/tutorialSwipe': (context) => const TutorialSwipeScreen(),
        '/history': (context) => const HistoryScreen(),
        '/home': (context) => HomeScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
