import 'dart:math';

import 'package:ambient_light/ambient_light.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Logger/logger.dart';

Future<bool> checkAmbientLight(
  maxluxvalue,
  lightWarningShown,
  dynamic context,
) async {
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
          content: Text(
            "Ambient light is too high (${lux.toStringAsFixed(0)} lux).\nPlease go indoors.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
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

/// Convert centimeters to logical pixels based on calibration if available.
/// Requires calibration to be saved first via CalibrationScreen.
/// If not calibrated, uses baseline estimate (160 logical DPI).
Future<double> cmToPx(BuildContext context, double cm) async {
  final prefs = await SharedPreferences.getInstance();

  // 1️⃣ Use saved calibration if exists
  final pxPerCm = prefs.getDouble('pxPerCm');
  if (pxPerCm != null) {
    logger.i(
      'cmToPx: $cm cm × $pxPerCm px/cm = ${(cm * pxPerCm).toStringAsFixed(2)} px',
    );
    return cm * pxPerCm;
  }

  // 2️⃣ Fallback: estimate using baseline logical DPI
  // Flutter's standard logical DPI is 160 (device-independent)
  const baselineLogicalDpi = 160.0;
  final logicalPxPerCm = (baselineLogicalDpi / 2.54);

  logger.w(
    'cmToPx: No calibration found. Using baseline estimate: '
    '$cm cm × $logicalPxPerCm px/cm = ${(cm * logicalPxPerCm).toStringAsFixed(2)} px. '
    'Please run calibration for accuracy.',
  );

  return cm * logicalPxPerCm;
}

Future<Size> getCalibratedSvgSize(
  BuildContext context,
  double widthCm,
  double heightCm,
) async {
  final prefs = await SharedPreferences.getInstance();
  final pxPerCm = prefs.getDouble('pxPerCm');

  // Get device DPI for diagnostic logging
  final mq = MediaQuery.of(context);
  final dpr = mq.devicePixelRatio;

  if (pxPerCm == null) {
    logger.w(
      'getCalibratedSvgSize: No calibration found. '
      'Using baseline estimate. Please run calibration.',
    );
    // Fallback to baseline estimate
    const baselineLogicalDpi = 160.0;
    final logicalPxPerCm = (baselineLogicalDpi / 2.54);
    final width = widthCm * logicalPxPerCm;
    final height = heightCm * logicalPxPerCm;

    logger.i(
      'Calibrated SVG Size (fallback): '
      '${width.toStringAsFixed(2)} x ${height.toStringAsFixed(2)} px | DPR=$dpr',
    );

    return Size(width, height);
  }

  final width = widthCm * pxPerCm;
  final height = heightCm * pxPerCm;

  logger.i(
    'Calibrated SVG Size (using $pxPerCm px/cm): '
    '${width.toStringAsFixed(2)} x ${height.toStringAsFixed(2)} px | '
    'Input: ${widthCm}cm x ${heightCm}cm | DPR=$dpr',
  );

  return Size(width, height);
}

String detectSwipeDirection(Offset swipeDelta) {
  double angleDeg = atan2(swipeDelta.dy, swipeDelta.dx) * (180 / pi);

  if (angleDeg >= -45 && angleDeg < 45) return 'right';
  if (angleDeg >= 45 && angleDeg < 135) return 'up';
  if (angleDeg >= -135 && angleDeg < -45) return 'down';
  return 'left';
}
