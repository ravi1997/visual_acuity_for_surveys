import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visual_acuity_for_surveys/utils/helpers.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  // Display adjustment values in CM (user adjusts cm values)
  double widthCm = 5.0;
  double heightCm = 5.0;

  // Final saved calibration factor
  double? pxPerCm;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCalibration();
  }

  Future<void> _loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    pxPerCm = prefs.getDouble('pxPerCm');
    setState(() => loading = false);
  }

  Future<void> _saveCalibration(double boxWidthPx) async {
    final prefs = await SharedPreferences.getInstance();

    /// 🔥 Core formula
    /// px per cm = displayed pixels / actual physical cm
    final factor = boxWidthPx / widthCm;

    await prefs.setDouble('pxPerCm', factor);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Calibration saved!")));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Screen Calibration")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Use a real ruler.\nMake the BLUE box exactly 5 cm × 5 cm.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // ---------------------- BLUE BOX ----------------------
              FutureBuilder<double>(
                future: cmToPx(context, widthCm),
                builder: (context, snapshotW) {
                  return FutureBuilder<double>(
                    future: cmToPx(context, heightCm),
                    builder: (context, snapshotH) {
                      if (!snapshotW.hasData || !snapshotH.hasData) {
                        return const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final boxWidthPx = snapshotW.data!;
                      final boxHeightPx = snapshotH.data!;

                      return Column(
                        children: [
                          Container(
                            width: boxWidthPx,
                            height: boxHeightPx,
                            color: Colors.blue.withOpacity(0.4),
                          ),

                          const SizedBox(height: 20),

                          // ---------------- WIDTH CONTROL ----------------
                          Text("Width: ${widthCm.toStringAsFixed(2)} cm"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                iconSize: 36,
                                onPressed: () => setState(() {
                                  widthCm = (widthCm - 0.1).clamp(1.0, 20.0);
                                }),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                iconSize: 36,
                                onPressed: () => setState(() {
                                  widthCm = (widthCm + 0.1).clamp(1.0, 20.0);
                                }),
                              ),
                            ],
                          ),

                          // ---------------- HEIGHT CONTROL ----------------
                          Text("Height: ${heightCm.toStringAsFixed(2)} cm"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                iconSize: 36,
                                onPressed: () => setState(() {
                                  heightCm = (heightCm - 0.1).clamp(1.0, 20.0);
                                }),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                iconSize: 36,
                                onPressed: () => setState(() {
                                  heightCm = (heightCm + 0.1).clamp(1.0, 20.0);
                                }),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          ElevatedButton(
                            onPressed: () => _saveCalibration(boxWidthPx),
                            child: const Text("SAVE CALIBRATION"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 40),

              if (pxPerCm != null)
                Text(
                  "Current Calibration:\n1 cm ≈ ${pxPerCm!.toStringAsFixed(1)} px",
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
