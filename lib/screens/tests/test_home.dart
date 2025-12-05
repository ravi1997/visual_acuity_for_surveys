import 'package:flutter/material.dart';

import '../../Logger/logger.dart';

class PatientInputScreenWrapper extends StatelessWidget {
  const PatientInputScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    try {
      logger.d("patientInfo from start : ${args['patientInfo']}");
      return PatientInputScreen(patientInfo: args['patientInfo']);
    } catch (e) {
      logger.d("Gone something wrong : $e");
      return PatientInputScreen();
    }
  }
}

class PatientInputScreen extends StatefulWidget {
  final String? patientInfo;
  const PatientInputScreen({super.key, this.patientInfo});

  @override
  State<PatientInputScreen> createState() => _PatientInputScreenState();
}

class _PatientInputScreenState extends State<PatientInputScreen> {
  final TextEditingController _infoController = TextEditingController();
  String? _selectedVisionType;

  final List<String> _visionOptions = [
    'Right eye uncorrected vision / without glasses',
    'Right eye corrected vision / with glasses',
    'Right eye pinhole vision',
    'Left eye uncorrected vision / without glasses',
    'Left eye corrected vision / with glasses',
    'Left eye pinhole vision',
    'Near Vision',
  ];

  @override
  void initState() {
    _infoController.text = widget.patientInfo ?? "";
    logger.d("patientInfo : ${widget.patientInfo}");
    super.initState();
  }

  void _startTest() {
    final info = _infoController.text.trim();
    final selected = _selectedVisionType;

    if (info.isEmpty || selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter info and select vision type'),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/test',
      arguments: {'patientInfo': info, 'visionType': selected},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Patient Information'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/tutorialSwipe');
            },
            child: const Text('Tutorial'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Patient Information:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _infoController,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Enter name, age, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Vision Type:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._visionOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedVisionType,
                  onChanged: (val) {
                    setState(() {
                      _selectedVisionType = val;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                );
              }).toList(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startTest,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Test"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
