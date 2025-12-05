import 'package:flutter/material.dart';
import 'package:v_a_rpc/managers/test_history.dart';

import '../../Logger/logger.dart';

class PatientInputScreenWrapper extends StatelessWidget {
  const PatientInputScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    try {
      logger.d("patientInfo from start : ${args?['patientInfo']}");
      return PatientInputScreen(patientInfo: args?['patientInfo']);
    } catch (e) {
      logger.d("Gone something wrong : $e");
      return const PatientInputScreen();
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
    'Right eye uncorrected vision / without glasses (UVA)',
    'Right eye corrected vision / with glasses (CVA)',
    'Right eye pinhole vision (PinVA)',
    'Left eye uncorrected vision / without glasses (UVA)',
    'Left eye corrected vision / with glasses (CVA)',
    'Left eye pinhole vision (PinVA)',
    'Near Vision',
  ];

  List<bool> _operationDone = [];

  void clearFields() {
    _infoController.clear();
    setState(() {
      _selectedVisionType = null;
      _operationDone = List<bool>.filled(_visionOptions.length, false);
    });
  }

  @override
  void initState() {
    super.initState();
    _initAsync(); // fire-and-forget async setup
  }

  Future<void> _initAsync() async {
    // 1. If patientInfo passed via arguments, use it.
    if (widget.patientInfo != null && widget.patientInfo!.trim().isNotEmpty) {
      final info = widget.patientInfo!.trim();
      logger.d("patientInfo from args: $info");
      _infoController.text = info;

      await fetchOperationDone(info);
      return;
    }

    // 2. Otherwise, try to load last patient ID from history
    final lastPatientID = await fetchLastPatientID();

    logger.d(
      "patientInfo after fetchLastPatientID: '${_infoController.text.trim()}'",
    );

    if (lastPatientID.isNotEmpty) {
      await fetchOperationDone(lastPatientID);
    } else {
      // No last patient: mark all operations as false
      if (!mounted) return;
      setState(() {
        _operationDone = List<bool>.filled(_visionOptions.length, false);
      });
    }
  }

  /// Loads latest patient ID from history and sets the text controller.
  /// Returns the patient ID string (or empty if none).
  Future<String> fetchLastPatientID() async {
    final latestRow = await TestHistoryManager.readLatestHistoryRow();
    final lastPatientID = latestRow.isNotEmpty && latestRow.length > 1
        ? latestRow[1]
        : '';

    logger.d("lastPatientID from history: '$lastPatientID'");

    if (lastPatientID.isEmpty) {
      logger.d("No last patient, keeping text empty");
      return '';
    }

    if (!mounted) return '';
    setState(() {
      _infoController.text = lastPatientID;
    });

    return lastPatientID;
  }

  /// Fills _operationDone: for each vision option, true if any row for this patient has that vision.
  Future<void> fetchOperationDone(String patientId) async {
    if (patientId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _operationDone = List<bool>.filled(_visionOptions.length, false);
      });
      logger.d("Empty patientId in fetchOperationDone, setting all false");
      return;
    }

    final rowData = await TestHistoryManager.readHistoryByPatient(patientId);

    // Prepare local list: one bool per vision option
    final List<bool> operationDone = List<bool>.filled(
      _visionOptions.length,
      false,
    );

    const int VISION_COL_INDEX = 2; // <-- adjust to your actual column index

    for (int i = 0; i < _visionOptions.length; i++) {
      final option = _visionOptions[i];

      // Check if ANY row has this vision option
      final exists = rowData.any((row) {
        logger.d("Checking row for option '$option': $row");
        if (row.length <= VISION_COL_INDEX) return false;
        final visionValue = row[VISION_COL_INDEX];
        return visionValue.toLowerCase() == option.toLowerCase();
      });

      operationDone[i] = exists;
    }

    if (!mounted) return;
    setState(() {
      _operationDone = operationDone;
    });

    logger.d("fetched _operationDone : $_operationDone");
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enter Id:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _initAsync,
                    child: const Text('Load Last'),
                  ),
                  ElevatedButton(
                    onPressed: clearFields,
                    child: const Text('Clear'),
                  ),
                ],
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
              ..._visionOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedVisionType,
                    onChanged: (val) {
                      setState(() {
                        _selectedVisionType = val;
                      });
                    },
                    // shape is not a property of RadioListTile; Card already has shape
                    tileColor: Colors.white,
                    secondary:
                        _operationDone.length > index && _operationDone[index]
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
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
