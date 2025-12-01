import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  double widthCm = 5.0;
  double heightCm = 5.0;
  double maxLuxAllowed = 15000;
  final _luxController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadCalibration();
    _loadLux();
  }
  Future<void> _loadCalibration() async{
    final prefs = await SharedPreferences.getInstance();
    double? temp = prefs.getDouble('calibrationWidthCm');
    final wCm =  temp!=null? temp*5/100:5.0;
    temp = prefs.getDouble('calibrationHeightCm');

    final hCm = temp!=null? temp*5/100:5.0;
    setState(() {
      widthCm = wCm;
      heightCm = hCm;
    });
  }

  Future<void> _loadLux() async {
    final prefs = await SharedPreferences.getInstance();
    final lux = prefs.getDouble('maxLuxAllowed') ?? 15000;
    setState(() {
      maxLuxAllowed = lux;
      _luxController.text = lux.toStringAsFixed(0);
    });
  }

  Future<void> _saveCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calibrationWidthCm', widthCm / 5 * 100);
    await prefs.setDouble('calibrationHeightCm', heightCm / 5 * 100);

    final parsedLux = double.tryParse(_luxController.text);
    if (parsedLux != null) {
      maxLuxAllowed = parsedLux;
      await prefs.setDouble('maxLuxAllowed', maxLuxAllowed);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calibration saved!')),
    );
  }

  double _cmToLogicalPixels(BuildContext context, double cm) {
    final ppi = MediaQuery.of(context).devicePixelRatio * 160;
    final inches = cm / 2.54;
    final physicalPixels = inches * ppi;
    return physicalPixels / MediaQuery.of(context).devicePixelRatio;
  }

  @override
  Widget build(BuildContext context) {
    double boxWidth = _cmToLogicalPixels(context, widthCm);
    double boxHeight = _cmToLogicalPixels(context, heightCm);

    return Scaffold(
      appBar: AppBar(title: Text("Screen Calibration")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Match the box below to 5cm x 5cm using a real ruler.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                width: boxWidth,
                height: boxHeight,
                color: Colors.blueAccent.withAlpha((0.5 * 255).round())
                ,
              ),
              SizedBox(height: 20),
              Text("Width: ${widthCm.toStringAsFixed(2)} cm"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle),
                    iconSize: 36,
                    onPressed: () => setState(() => widthCm = (widthCm - 0.1).clamp(1.0, 10.0)),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    iconSize: 36,
                    onPressed: () => setState(() => widthCm = (widthCm + 0.1).clamp(1.0, 10.0)),
                  ),
                ],
              ),
              Text("Height: ${heightCm.toStringAsFixed(2)} cm"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle),
                    iconSize: 36,
                    onPressed: () => setState(() => heightCm = (heightCm - 0.1).clamp(1.0, 10.0)),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    iconSize: 36,
                    onPressed: () => setState(() => heightCm = (heightCm + 0.1).clamp(1.0, 10.0)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Set Maximum Ambient Light (lux):"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _luxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Max Lux (e.g., 15000)',
                ),
              ),
              const SizedBox(height: 12),
              Text("Current Max Lux: ${maxLuxAllowed.toStringAsFixed(0)}"),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveCalibration,
                child: Text("Save Calibration"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
