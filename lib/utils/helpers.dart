import 'dart:math';

import 'package:ambient_light/ambient_light.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Logger/logger.dart';
Future<bool> checkAmbientLight(maxluxvalue,lightWarningShown, dynamic context) async {
  try {
    final AmbientLight ambientLight = AmbientLight(frontCamera: true);
    double? lux = await ambientLight.currentAmbientLight();
    // logger.d("lux : $lux");
    if (lux != null && lux > maxluxvalue && !lightWarningShown) {
      lightWarningShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("Too Bright!"),
          content: Text("Ambient light is too high (${lux.toStringAsFixed(0)} lux).\nPlease go indoors."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            )
          ],
        ),
      );
      return true;
    }
  } catch (e) {
    logger.d('Failed to get ambient light: $e');
  }
  return false;
}

Future<void> setBrightnessTo90() async {
  try {
    await ScreenBrightness().setApplicationScreenBrightness(0.9); // 90%
  } catch (e) {
    logger.d('Failed to set brightness: $e');
  }
}

double cmToLogicalPixels(BuildContext context, double cm) {
  final ppi = MediaQuery.of(context).devicePixelRatio * 160;
  final inches = cm / 2.54;
  final physicalPixels = inches * ppi;
  return physicalPixels / MediaQuery.of(context).devicePixelRatio;
}

Future<Size> getCalibratedSvgSize(
    BuildContext context, double widthCm, double heightCm) async {
  final prefs = await SharedPreferences.getInstance();
  final widthPct = prefs.getDouble('calibrationWidthCm') ?? 5.0;
  final heightPct = prefs.getDouble('calibrationHeightCm') ?? 5.0;

  return Size(
    cmToLogicalPixels(context, widthCm) * widthPct / 100,
    cmToLogicalPixels(context, heightCm) * heightPct / 100,
  );
}


String detectSwipeDirection(Offset swipeDelta) {
  double angleDeg = atan2(swipeDelta.dy, swipeDelta.dx) * (180 / pi);

  if (angleDeg >= -45 && angleDeg < 45) return 'right';
  if (angleDeg >= 45 && angleDeg < 135) return 'up';
  if (angleDeg >= -135 && angleDeg < -45) return 'down';
  return 'left';
}
