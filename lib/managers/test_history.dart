import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

import '../Logger/logger.dart';

class TestHistoryManager {
  static Future<void> clearHistory() async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }
  }


  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/test_history.xlsx';
    logger.d('Written to: $path');
    return path;
  }

  static Future<void> saveTest({
    required String dateTime,
    required String patientInfo,
    required String visionType,
    required String result,
  }) async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    Excel excel;
    Sheet sheetObject;

    if (await file.exists()) {
      final bytes = file.readAsBytesSync();
      excel = Excel.decodeBytes(bytes);
      sheetObject = excel['Sheet1'];
    } else {
      excel = Excel.createExcel();
      sheetObject = excel['Sheet1'];
      sheetObject.appendRow([TextCellValue('DateTime'),TextCellValue('patientInfo'), TextCellValue('visionType'),TextCellValue('Result')]);
    }

    sheetObject.appendRow([TextCellValue(dateTime),TextCellValue(patientInfo), TextCellValue(visionType), TextCellValue(result)]);

    final encodedBytes = excel.encode();
    if (encodedBytes != null) {
      await file.writeAsBytes(encodedBytes);
    }
  }

  static Future<List<List<String>>> readHistory() async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    if (!await file.exists()) return [];

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel['Sheet1'];

    return sheet.rows
        .map((row) => row
        .map((cell) => cell?.value.toString() ?? '')
        .toList())
        .toList();
  }
}
