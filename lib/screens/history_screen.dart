import 'package:flutter/material.dart';

import '../Logger/logger.dart';
import '../managers/test_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<List<dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final row = await TestHistoryManager.readHistory();
      logger.d(row);
      setState(() => _rows = row);
    } catch (e) {
      setState(() => _rows = [
        ['DateTime', 'Result'],
        ['Error reading history', '',]
      ]);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_rows.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final headers = _rows.first;
    final data = _rows.skip(1).map<List<String>>(
          (row) => row.map((cell) => cell.toString()).toList(),
    ).toList().reversed.toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear History',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Clear History?"),
                  content: const Text("Are you sure you want to delete all test history?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Clear")),
                  ],
                ),
              );

              if (confirmed == true) {
                await TestHistoryManager.clearHistory(); // You must define this
                setState(() {
                  _rows = [
                    ['DateTime', 'Result'],
                    ['History cleared', ''],
                  ];
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: PaginatedDataTable(
          header: const Text('Test History Records'),
          columns: headers
              .map((h) => DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.bold))))
              .toList(),
          source: _TestDataSource(data),
          rowsPerPage: 5,
          columnSpacing: 20,
        ),
      ),
    );
  }

}
class _TestDataSource extends DataTableSource {
  final List<List<String>> _data;

  _TestDataSource(this._data);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final row = _data[index];
    return DataRow(
      cells: row.map((cell) => DataCell(Text(cell))).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
