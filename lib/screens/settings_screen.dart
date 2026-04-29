import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tests/e_optotest.dart'; // To access the levels map

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<int> _disabledLevels = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final disabledList = prefs.getStringList('disabledLevels') ?? [];
    setState(() {
      _disabledLevels = disabledList.map((e) => int.parse(e)).toSet();
    });
  }

  Future<void> _toggleLevel(int levelNumber, bool value) async {
    setState(() {
      if (value) {
        _disabledLevels.remove(levelNumber);
      } else {
        _disabledLevels.add(levelNumber);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'disabledLevels',
      _disabledLevels.map((e) => e.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort levels by level number to display them in order
    final sortedLevels = levels.values.toList()
      ..sort((a, b) => a.levelNumber.compareTo(b.levelNumber));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: sortedLevels.map((level) {
          final isEnabled = !_disabledLevels.contains(level.levelNumber);
          return SwitchListTile(
            title: Text('Level ${level.levelNumber} - ${level.name}'),
            subtitle: Text('Distance: ${level.distance ?? "N/A"}m'),
            value: isEnabled,
            onChanged: (val) => _toggleLevel(level.levelNumber, val),
          );
        }).toList(),
      ),
    );
  }
}
