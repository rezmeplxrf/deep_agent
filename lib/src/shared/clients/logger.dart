import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum Role {
  user,
  assistant,
}

/// Logger for writing and reading logs to a file with singleton IOSink management.
class ChatLogger {
  /// Creates a [ChatLogger] with an optional [file].
  ChatLogger({File? file}) : _logFile = file ?? _defaultLogFile {
    _init();
  }

  static final _defaultLogFile = File('./.deep_agent/log.jsonl');
  static IOSink? _sharedSink;
  static final Map<String, StreamController<List<int>>> _streamControllers = {};
  static final Map<String, Stream<List<int>>> _streams = {};

  final File _logFile;
  final _ready = Completer<void>();

  /// Ensures the log file exists and initializes the shared sink if needed.
  Future<void> _init() async {
    if (!_logFile.existsSync()) {
      await _logFile.create(recursive: true);
    }
    _sharedSink ??= _logFile.openWrite(mode: FileMode.append);
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

  // ignore: avoid_void_async
  void log(String message, Role role, {String? agent}) async {
    await _ready.future;

    _sharedSink!.writeln(
      jsonEncode({
        'time': DateTime.now().toIso8601String(),
        'role': role.name,
        if (agent != null) 'agent': agent,
        'content': message,
      }),
    );
    await _sharedSink!.flush();
  }

  /// Closes the shared sink and cleans up resources.
  static Future<void> dispose() async {
    await _sharedSink?.close();
    _sharedSink = null;
    for (final controller in _streamControllers.values) {
      await controller.close();
    }
    _streamControllers.clear();
    _streams.clear();
  }
}
