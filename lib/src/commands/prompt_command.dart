import 'package:args/command_runner.dart';
import 'package:deep_agent/src/features/workflow/service.dart';
import 'package:mason_logger/mason_logger.dart';

class PromptCommand extends Command<int> {
  PromptCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'prompt',
      abbr: 'p',
      help: 'Prompts the AI with a given task',
    );
  }

  @override
  String get description => 'A command to prompt the AI with a given task';

  @override
  String get name => 'prompt';

  final Logger _logger;

  @override
  Future<int> run() async {
    final userPrompt = argResults?['prompt'] as String?;
    if (userPrompt == null || userPrompt.isEmpty) {
      _logger.err('Please provide a prompt using --prompt or -p flag.');
      return ExitCode.usage.code;
    }
    final service = WorkflowService();
    final results = await service.run(userPrompt, logger: _logger);
    if (results.isEmpty) {
      _logger.warn('No workflows were executed.');
      return ExitCode.noInput.code;
    }
    _logger.info('Workflow results:');

    for (final result in results) {
      _logger.info(
        ' - ${result.workflowName}: ${result.success ? 'Success' : 'Failed'}',
      );
      if (result.error != null) {
        _logger.err('   Error: ${result.error}');
      }
    }
    _logger.info(results.last.response?.output);

    return ExitCode.success.code;
  }
}
