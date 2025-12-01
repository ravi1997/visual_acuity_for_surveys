import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class DebugFileOutput extends LogOutput {
  late final Future<File> _logFile;

  DebugFileOutput() {
    _logFile = _getLogFile();
  }

  Future<File> _getLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/debug.log';
    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  @override
  void output(OutputEvent event) async {
    if (!kDebugMode) return; // only log in debug mode

    final file = await _logFile;
    for (final line in event.lines) {
      await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    }
  }
}

