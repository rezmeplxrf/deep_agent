import 'package:args/command_runner.dart';
import 'package:deep_agent/src/features/setup/repository.dart';
import 'package:mason_logger/mason_logger.dart';

class SetupCommand extends Command<int> {
  SetupCommand({required Logger logger}) : _logger = logger {
    argParser.addCommand(
      'init',
    );
  }

  @override
  String get description => 'A command to initialize the setup process';

  @override
  String get name => 'prompt';

  final Logger _logger;

  @override
  Future<int> run() async {
    _logger.info('Initializing setup...');
    await SetupRepository().setup();
    _logger.success('Setup completed successfully.');
    return ExitCode.success.code;
  }
}
