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
      sheetObject.appendRow([
        TextCellValue('DateTime'),
        TextCellValue('patientInfo'),
        TextCellValue('visionType'),
        TextCellValue('Result'),
      ]);
    }

    sheetObject.appendRow([
      TextCellValue(dateTime),
      TextCellValue(patientInfo),
      TextCellValue(visionType),
      TextCellValue(result),
    ]);

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
        .map((row) => row.map((cell) => cell?.value.toString() ?? '').toList())
        .toList();
  }

  static Future<List<String>> readLatestHistoryRow() async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    if (!await file.exists()) {
      logger.d("File does not exist: $filePath");
      return []; // no file, return empty
    }

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel['Sheet1'];

    // If no rows at all
    if (sheet.rows.isEmpty) {
      logger.d("No rows in the sheet");
      return [];
    }

    // Convert rows to list of string lists
    final rows = sheet.rows
        .map((row) => row.map((cell) => cell?.value.toString() ?? '').toList())
        .toList();

    // If only header exists
    if (rows.length <= 1) {
      logger.d("Only header row exists");
      return [];
    }

    // Latest row = last item in list (skip header at index 0)
    return rows.last;
  }

  static Future<List<List<String>>> readHistoryByPatient(
    String patientId,
  ) async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    if (!await file.exists()) return [];

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel['Sheet1'];

    if (sheet.rows.isEmpty) return [];

    // Convert Excel rows to list of string lists
    final rows = sheet.rows
        .map((row) => row.map((cell) => cell?.value.toString() ?? '').toList())
        .toList();

    // Remove header row (first row)
    if (rows.length <= 1) return [];

    final dataRows = rows.sublist(1);

    // Filter rows by matching patient ID (column index 2)
    final matchingRows = dataRows.where((row) {
      if (row.length <= 2) return false; // skip malformed rows
      return row[1] == patientId;
    }).toList();

    return matchingRows;
  }
}
