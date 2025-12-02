import 'dart:math';

import 'package:ambient_light/ambient_light.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:device_info_sdk/device_info_sdk.dart';

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
/// If not calibrated, uses device DPI estimation.
Future<double> cmToPx(BuildContext context, double cm) async {
  final prefs = await SharedPreferences.getInstance();

  // 1️⃣ Use saved calibration if exists
  final pxPerCm = prefs.getDouble('pxPerCm');
  if (pxPerCm != null) {
    return cm * pxPerCm;
  }

  // 2️⃣ Fallback: estimate using device DPI
  final mq = MediaQuery.of(context);
  final dpr = mq.devicePixelRatio;

  // Approx baseline DPI = logical 160 dpi * physical scaling
  final dpi = dpr * 160.0;

  // Convert DPI -> px per cm  (1 inch = 2.54 cm)
  final pxPerCmEstimate = dpi / 2.54;

  // Logical px (Flutter units)
  final logicalPxPerCm = pxPerCmEstimate / dpr;

  return cm * logicalPxPerCm;
}

Future<Size> getCalibratedSvgSize(
  BuildContext context,
  double widthCm,
  double heightCm,
) async {
  final prefs = await SharedPreferences.getInstance();
  final pxPerCm = prefs.getDouble('pxPerCm')!;

  final width = widthCm * pxPerCm;
  final height = heightCm * pxPerCm;

  logger.i(
    "Calibrated SVG Size: ${width.toStringAsFixed(2)} x ${height.toStringAsFixed(2)} px",
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
