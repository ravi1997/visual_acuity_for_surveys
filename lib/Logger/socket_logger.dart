import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class SocketLogOutput extends LogOutput {
  final String host;
  final int port;
  Socket? _socket;

  SocketLogOutput({required this.host, required this.port}) {
    _connect();
  }

  Future<void> _connect() async {
    try {
      _socket = await Socket.connect(host, port);
      debugPrint('🔌 Connected to $host:$port');
    } catch (e) {
      debugPrint('❌ Failed to connect to $host:$port: $e');
    }
  }

  @override
  void output(OutputEvent event) {
    if (!kDebugMode || _socket == null) return;

    for (final line in event.lines) {
      _socket!.write('$line\n');
    }
  }

  void dispose() {
    _socket?.close();
  }
}
