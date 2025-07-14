# Instruction
You are a Dart CLI developer and I am the Product Owner. Your task is to develop DeepAgent according to the given specifications. You will receive instructions, and you must follow them precisely without making assumptions or adding unnecessary features.

## Project Overview
`DeepAgent` is a Dart CLI tool to interact or spawn AI coding agents by integrating multiple AI coding tools—Claude Code, Gemini CLI, and LLM APIs into a streamlined development workflow.

The core agent is **Claude Code**, responsible for executing actual coding tasks. **Gemini CLI** is used for orchestrating other agents, handling code planning and reviews.

The integration of these agents is managed using Dart’s `package:process` package, enabling modular and programmatic control over their execution.

## CLI Template
This project uses the `very_good_cli` template structure. Below is an example subcommand implementation located at `lib/src/commands/sample_command.dart`:

```dart
/// {@template update_command}
/// A command which updates the CLI.
/// {@endtemplate}
class UpdateCommand extends Command<int> {
  /// {@macro update_command}
  UpdateCommand({required Logger logger, PubUpdater? pubUpdater})
    : _logger = logger,
      _pubUpdater = pubUpdater ?? PubUpdater();

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  String get description => 'Update the CLI.';

  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    final updateCheckProgress = _logger.progress('Checking for updates');
    late final String latestVersion;
    try {
      latestVersion = await _pubUpdater.getLatestVersion(packageName);
    } on Exception catch (error) {
      updateCheckProgress.fail();
      _logger.err('$error');
      return ExitCode.software.code;
    }
    updateCheckProgress.complete('Checked for updates');

    final isUpToDate = packageVersion == latestVersion;
    if (isUpToDate) {
      _logger.info('CLI is already at the latest version.');
      return ExitCode.success.code;
    }

    final updateProgress = _logger.progress('Updating to $latestVersion');

    late final ProcessResult result;
    try {
      result = await _pubUpdater.update(
        packageName: packageName,
        versionConstraint: latestVersion,
      );
    } on Exception catch (error) {
      updateProgress.fail();
      _logger.err('$error');
      return ExitCode.software.code;
    }

    if (result.exitCode != ExitCode.success.code) {
      updateProgress.fail();
      _logger.err('Error updating CLI: ${result.stderr}');
      return ExitCode.software.code;
    }

    updateProgress.complete('Updated to $latestVersion');

    return ExitCode.success.code;
  }
}
```

## Test Example
```dart
import 'package:deep_agent/src/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
class _MockLogger extends Mock implements Logger {}

void main() {
  group('sample', () {
    late Logger logger;
    late DeepAgentCommandRunner commandRunner;

    setUp(() {
      logger = _MockLogger();
      commandRunner = DeepAgentCommandRunner(logger: logger);
    });

    test('tells a joke', () async {
      final exitCode = await commandRunner.run(['sample']);

      expect(exitCode, ExitCode.success.code);

      verify(
        () => logger.info('Which unicorn has a cold? The Achoo-nicorn!'),
      ).called(1);
    });
    test('tells a joke in cyan', () async {
      final exitCode = await commandRunner.run(['sample', '-c']);

      expect(exitCode, ExitCode.success.code);

      verify(
        () => logger.info(
          lightCyan.wrap('Which unicorn has a cold? The Achoo-nicorn!'),
        ),
      ).called(1);
    });

    test('wrong usage', () async {
      final exitCode = await commandRunner.run(['sample', '-p']);

      expect(exitCode, ExitCode.usage.code);

      verify(
        () => logger.err('Could not find an option or flag "-p".'),
      ).called(1);
      verify(
        () => logger.info('''
Usage: $executableName sample [arguments]
-h, --help    Print this usage information.
-c, --cyan    Prints the same joke, but in cyan

Run "$executableName help" to see global options.'''),
      ).called(1);
    });
  });
}
```

## Coding Practices
- Follow the DRY (Don't Repeat Yourself) principle.
- Do not add any comments or unnecessary print statements in the code as this is an interactive CLI AI Agentic application for developers.
- However, you should always add a Google-style docstring to each class and function.
- Use enums instead of Strings for fixed sets of values.
- Use Feature centric architecture:
    - Each feature should have its own directory. e.g. `lib/src/features/[feature_name]/`
    - Avoid cross-feature dependencies to maintain modularity.
- Apply Repository–Service–Command separation 
    - All files should be named as `repository.dart`, `service.dart`, `command.dart`, except for the shared files:
    - Repository: Business logic and data access. e.g. `lib/src/features/[feature_name]/repository.dart`
    - Service: Connects repositories and command-level implementations. e.g. `lib/src/features/[feature_name]/service.dart`
    - Command: Handles user input and orchestrates service calls. e.g. `lib/src/features/[feature_name]/command.dart`
    - Shared files should be placed in `lib/src/shared/[descriptive_name].dart`.
- Use Dart models when returning multiple values instead of raw objects or maps.
- Ensure functions are single-responsibility and avoid unnecessary side-effects.
- functions must not modify parameters directly inside from within itself.
- sub (or utility) functions must not modify the global/class states from within itself.
- use appropriate colors for terminal outputs using `ansicolor` package.
- Avoid using void return types unless absolutely necessary.
- Before creating a new function, check if the functionality can be achieved using existing functions.
- Always add tests in `test/` after implementing a feature.
- Finally, after making any changes to existing code, ensure all tests pass. 

## Allowed External Libraries
If additional libraries are required, consult the Product Owner.
Use only what's included in the `pubspec.yaml`.