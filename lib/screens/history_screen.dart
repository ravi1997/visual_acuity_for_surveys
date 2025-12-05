import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import '../Logger/logger.dart';
import '../managers/test_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  List<String> _headers = [];
  List<List<String>> _data = [];

  bool _loading = true;
  bool _error = false;

  // How many items we’re currently showing in the list
  int _itemsToShow = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final rows = await TestHistoryManager.readHistory();
      logger.d(rows);

      if (rows.isEmpty) {
        _headers = ['DateTime', 'Result'];
        _data = [
          ['No records found', ''],
        ];
      } else {
        _headers = rows.first.map((e) => e.toString()).toList();
        _data = rows
            .skip(1)
            .map<List<String>>(
              (row) => row.map((cell) => cell.toString()).toList(),
            )
            .toList()
            .reversed
            .toList(); // latest first
      }

      _itemsToShow = min(_pageSize, _data.length);
    } catch (e, st) {
      logger.e('Error reading history , $e, $st');
      _error = true;
      _headers = ['DateTime', 'Result'];
      _data = [
        ['Error reading history', ''],
      ];
      _itemsToShow = _data.length;
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _itemsToShow < _data.length) {
      // Auto-load more when nearing the bottom
      setState(() {
        _itemsToShow = min(_itemsToShow + _pageSize, _data.length);
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History?"),
        content: const Text(
          "Are you sure you want to delete all test history?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TestHistoryManager.clearHistory();
      setState(() {
        _headers = ['DateTime', 'Result'];
        _data = [
          ['History cleared', ''],
        ];
        _itemsToShow = _data.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear History',
            onPressed: _data.isEmpty ? null : _clearHistory,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _data.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        _error ? 'Failed to load history' : 'No history found',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount:
                    _itemsToShow + 1, // extra one for the footer (Load more)
                itemBuilder: (context, index) {
                  if (index < _itemsToShow) {
                    final row = _data[index];
                    return _HistoryCard(headers: _headers, row: row);
                  }

                  // Footer
                  final hasMore = _itemsToShow < _data.length;
                  if (!hasMore) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _itemsToShow = min(
                              _itemsToShow + _pageSize,
                              _data.length,
                            );
                          });
                        },
                        icon: const Icon(Icons.expand_more),
                        label: const Text('Load more'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final List<String> headers;
  final List<String> row;

  const _HistoryCard({super.key, required this.headers, required this.row});

  DateTime? parseSafeDate(String raw) {
    try {
      raw = raw.trim();
      // Optional: clean up common malformed ISO formats like 2025-12-033...
      final cleaned = raw.replaceAll(
        RegExp(r'(\d{4}-\d{2}-)(\d{1,2})\d'),
        r'$1$2',
      );
      return DateTime.parse(cleaned);
    } catch (_) {
      return null; // Not a date
    }
  }

  String humanTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inHours < 1) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";

    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Assume first column is DateTime, second is Result if available
    final String primaryText = row.isNotEmpty ? row[0] : '';
    final String secondaryText = row.length > 1 ? row[1] : '';

    final DateTime? parsedDate = DateTime.parse(primaryText);

    // logger.d("Parsed date: $parsedDate from $primaryText");

    final String? relativeTime = parsedDate != null
        ? humanTime(parsedDate)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Optional: show full details in a bottom sheet
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) =>
                _HistoryDetailsSheet(headers: headers, row: row),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + primary + chip result
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (secondaryText.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.colorScheme.primary.withOpacity(0.08),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        secondaryText,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      relativeTime ?? primaryText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Additional fields, if any
              if (row.length > 2) ...[
                const Divider(),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(row.length - 2, (i) {
                    final idx = i + 2;
                    final header = idx < headers.length
                        ? headers[idx]
                        : 'Field ${idx + 1}';
                    final value = row[idx];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$header: $value',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryDetailsSheet extends StatelessWidget {
  final List<String> headers;
  final List<String> row;

  const _HistoryDetailsSheet({
    super.key,
    required this.headers,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Test Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(row.length, (i) {
            final header = i < headers.length ? headers[i] : 'Field ${i + 1}';
            final value = row[i];
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                header,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              subtitle: Text(value, style: theme.textTheme.bodyMedium),
            );
          }),
        ],
      ),
    );
  }
}
