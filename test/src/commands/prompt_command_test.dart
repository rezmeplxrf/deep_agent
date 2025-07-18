import 'package:deep_agent/src/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group('prompt', () {
    late Logger logger;
    late DeepAgentCommandRunner commandRunner;

    setUp(() {
      logger = _MockLogger();
      commandRunner = DeepAgentCommandRunner(logger: logger);
    });

    test('shows error when no prompt provided', () async {
      final exitCode = await commandRunner.run(['prompt']);

      expect(exitCode, ExitCode.usage.code);

      verify(
        () => logger.err('Please provide a prompt using --prompt or -p flag.'),
      ).called(1);
    });

    test('accepts prompt with -p flag', () async {
      final exitCode = await commandRunner.run([ '-p', 'hello']);

      expect(exitCode, ExitCode.success.code);
    });

    test('accepts prompt with --prompt flag', () async {
      final exitCode = await commandRunner.run([ '--prompt', 'hello']);

      expect(exitCode, ExitCode.success.code);
    });
  });
}
