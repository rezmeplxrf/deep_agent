// ignore_for_file: cascade_invocations

import 'dart:io';
import 'package:test/test.dart';

import 'package:deep_agent/src/shared/logger.dart';

void main() {
  group('ChatLogger Tests', () {
    late ChatLogger logger;
    late File tempFile;

    setUp(() async {
      tempFile = File('test_log.jsonl');
      logger = ChatLogger(filePath: tempFile.path);
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    });

    tearDown(() async {
      await ChatLogger.dispose();
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    });

    test('should handle concurrent logging without StreamSink error', () async {
      // Simulate concurrent logging calls
      final futures = List.generate(
        10,
        (i) => Future(() {
          logger.log('Test message $i', Role.user);
          logger.log('Test message $i assistant', Role.assistant);
        }),
      );

      // Wait for all logging operations to complete
      await Future.wait(futures);

      // Give some time for all writes to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify file was created and contains logs
      expect(tempFile.existsSync(), isTrue);
      final content = await tempFile.readAsString();
      expect(content.isNotEmpty, isTrue);

      // Count the number of lines (should be 20 for 10 pairs of messages)
      final lines = content.trim().split('\n');
      expect(lines.length, equals(20));
    });

    test('should maintain message order in queue', () async {
      // Log messages in specific order
      logger.log('First message', Role.user);
      logger.log('Second message', Role.assistant);
      logger.log('Third message', Role.user);

      // Wait for writes to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify file content
      expect(tempFile.existsSync(), isTrue);
      final content = await tempFile.readAsString();
      expect(content.contains('First message'), isTrue);
      expect(content.contains('Second message'), isTrue);
      expect(content.contains('Third message'), isTrue);
    });
  });
}
