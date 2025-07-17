import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

enum Role {
  user,
  assistant,
}

/// Logger for writing and reading logs to a file with singleton IOSink management.
class ChatLogger {
  /// Creates a [ChatLogger] with an optional [filePath].
  ChatLogger({String? filePath})
    : _logFile = (filePath != null) ? File(filePath) : File(_defaultLogFile) {
    _init();
  }
  final logger = Logger(
    level: Level.verbose,
  );

  static const _defaultLogFile = './.deep_agent/log.jsonl';
  static final Map<String, IOSink> _sinks = {};
  static final Map<String, StreamController<List<int>>> _streamControllers = {};
  static final Map<String, Stream<List<int>>> _streams = {};
  static final Map<String, Queue<String>> _writeQueues = {};
  static final Map<String, bool> _isWriting = {};

  final File _logFile;
  final _ready = Completer<void>();

  /// Ensures the log file exists and initializes the sink if needed.
  Future<void> _init() async {
    if (!_logFile.existsSync()) {
      await _logFile.create(recursive: true);
    }
    final path = _logFile.path;
    _sinks[path] ??= _logFile.openWrite(mode: FileMode.append);
    _writeQueues[path] ??= Queue<String>();
    _isWriting[path] ??= false;
    _ready.complete();
  }

  /// Returns a [Stream] for reading logs.
  Stream<List<int>> readAsStream() {
    final path = _logFile.path;
    return _streams[path] ??= _logFile.openRead();
  }

  /// Returns last line of the log file.
  Future<String> lastLog() async {
    final lines = await _logFile.readAsLines();
    return lines.isNotEmpty ? lines.last : '';
  }

  /// Writes a message to the log file using the shared sink.
  void log(String message, Role role, {String? agent}) {
    final path = _logFile.path;

    // Ensure queue is initialized
    _writeQueues[path] ??= Queue<String>();
    _isWriting[path] ??= false;

    final logEntry = jsonEncode({
      'time': DateTime.now().toIso8601String(),
      'role': role.name,
      if (agent != null) 'agent': agent,
      'content': message,
    });

    _writeQueues[path]!.add(logEntry);
    _processQueue(path);
  }

  /// Processes the write queue to ensure sequential writes.
  Future<void> _processQueue(String path) async {
    final isWriting = _isWriting[path] ?? false;
    if (isWriting) {
      return;
    }

    _isWriting[path] = true;

    await _ready.future;

    // Ensure sink is initialized
    _sinks[path] ??= _logFile.openWrite(mode: FileMode.append);
    final sink = _sinks[path]!;

    while (_writeQueues[path]!.isNotEmpty) {
      final logEntry = _writeQueues[path]!.removeFirst();
      sink.writeln(logEntry);
    }

    await sink.flush();
    _isWriting[path] = false;
  }

  /// Closes all sinks and cleans up resources.
  static Future<void> dispose() async {
    for (final sink in _sinks.values) {
      await sink.close();
    }
    _sinks.clear();
    for (final controller in _streamControllers.values) {
      await controller.close();
    }
    _streamControllers.clear();
    _streams.clear();
    _writeQueues.clear();
    _isWriting.clear();
  }
}
