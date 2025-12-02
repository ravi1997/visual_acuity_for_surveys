import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visual_acuity_for_surveys/Logger/logger.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  static const double _targetCm = 5.0;

  // Logical px of the blue square the user adjusts with a ruler.
  double _boxPx = 320.0;

  // Final saved calibration factor (logical px per cm).
  double? pxPerCm;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCalibration();
  }

  Future<void> _loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('pxPerCm');

    setState(() {
      pxPerCm = saved;
      // If we already calibrated, pre-fill the box to that physical size.
      if (saved != null) {
        _boxPx = saved * _targetCm;
      }
      loading = false;
    });
  }

  Future<void> _saveCalibration() async {
    final prefs = await SharedPreferences.getInstance();

    // Clean up any legacy calibration keys that might interfere.
    const deprecatedKeys = <String>[
      'calibrationWidthCm',
      'calibrationHeightCm',
      'calibrationWidthPx',
      'calibrationHeightPx',
    ];
    for (final key in deprecatedKeys) {
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }

    /// Core formula:
    /// pxPerCm = logical pixels on screen / physical cm measured with a ruler.
    /// The user makes the square exactly _targetCm wide on their device.
    final pxPerCm = _boxPx / _targetCm;

    await prefs.setDouble('pxPerCm', pxPerCm);

    setState(() {
      this.pxPerCm = pxPerCm;
    });

    logger.i(
      '✅ Calibration SAVED: $_boxPx px (measured) / $_targetCm cm (target) = $pxPerCm px/cm',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Calibration saved!\n'
          '1 cm ≈ ${pxPerCm.toStringAsFixed(2)} px\n'
          '(Box: ${_boxPx.toStringAsFixed(1)} px for $_targetCm cm)',
        ),
      ),
    );
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
              Text(
                "Use a real ruler.\nAdjust the BLUE box until it measures exactly $_targetCm cm × $_targetCm cm on your screen.",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // ---------------------- BLUE BOX ----------------------
              Column(
                children: [
                  Container(
                    width: _boxPx,
                    height: _boxPx,
                    color: Colors.blue.withOpacity(0.4),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Box size: ${_boxPx.toStringAsFixed(1)} px (logical)',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    min: 50,
                    max: 900,
                    divisions: 850,
                    value: _boxPx.clamp(50, 900),
                    label: '${_boxPx.toStringAsFixed(0)} px',
                    onChanged: (value) {
                      setState(() {
                        _boxPx = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _boxPx = (_boxPx - 2).clamp(50, 900);
                          });
                        },
                        icon: const Icon(Icons.remove_circle),
                        iconSize: 32,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _boxPx = (_boxPx + 2).clamp(50, 900);
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                        iconSize: 32,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Tip: align any one side to $_targetCm cm using a physical ruler. '
                    'Do not change the on-screen cm target; instead adjust the px slider.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _saveCalibration,
                    child: const Text("SAVE CALIBRATION"),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              if (pxPerCm != null)
                Text(
                  "Current Calibration:\n1 cm ≈ ${pxPerCm!.toStringAsFixed(2)} px",
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
