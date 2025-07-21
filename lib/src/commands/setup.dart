import 'package:args/command_runner.dart';
import 'package:deep_agent/src/features/setup/repository.dart';
import 'package:mason_logger/mason_logger.dart';

class SetupCommand extends Command<int> {
  SetupCommand({required Logger logger}) : _logger = logger;

  @override
  String get description => 'A command to initialize the setup process';

  @override
  String get name => 'init';

  final Logger _logger;

  @override
  Future<int> run() async {
    final appName = _logger.prompt(
      'Enter the application name',
      defaultValue: 'MyApp',
    );
    final frameworkStr = _logger.chooseOne(
      'Select framework',
      choices: [
        'Flutter',
        'Dart',
        'BHRV Web',
      ],
    );
    late final Framework framework;
    switch (frameworkStr.toLowerCase()) {
      case 'flutter':
        framework = Framework.flutter;
      case 'dart':
        framework = Framework.dart;
      case 'bhrv web':
        framework = Framework.web;
      default:
        _logger.err('Invalid framework selected.');
        return ExitCode.usage.code;
    }
    _logger.info('Selected framework: $framework');

    await SetupRepository().setup(appName, framework);
    _logger.success('Setup completed successfully.');
    return ExitCode.success.code;
  }
}

enum Framework {
  flutter,
  dart,
  web,
}
