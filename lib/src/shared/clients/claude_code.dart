import 'dart:async';
import 'dart:io';

import 'package:deep_agent/src/shared/logger.dart';
import 'package:process/process.dart';

class ClaudeCode {
  ClaudeCode({
    required this.manager,
    required this.logger,
  });
  final ProcessManager manager;
  final ChatLogger logger;
  static const String _llmProvider = 'ClaudeCode';

  Future<String> prompt(
    String prompt, {
    File? pipedContent,
    bool contiune = true,
  }) async {
    late final List<String> command;
    final escapedPrompt = prompt.replaceAll("'", r"'\''");
    if (pipedContent != null) {
      if (!pipedContent.existsSync()) {
        throw Exception(
          'Piped content file does not exist: ${pipedContent.path}',
        );
      }

      command = [
        'bash',
        '-c',
        "cat '${pipedContent.path}' | claude ${contiune ? '-c' : ''} -p '$escapedPrompt'",
      ];
      logger.log('${pipedContent.path} | $escapedPrompt', Role.user);
    } else {
      command = [
        'claude',
        if (contiune) '-c',
        '-p',
        escapedPrompt,
      ];
      logger.log(escapedPrompt, Role.user);
    }
    final result = await manager.run(command);
    if (result.stderr != null && result.stderr.toString().isNotEmpty) {
      logger.log(
        'Error | ${result.stderr}',
        Role.assistant,
      );
      throw Exception('Error: ${result.stderr}');
    }
    final response = result.stdout?.toString().trim();
    logger.log(
      response ?? '',
      agent: _llmProvider,
      Role.assistant,
    );
    return response ?? '';
  }
}

void main() async {
  const processManager = LocalProcessManager();
  final claudeCode = ClaudeCode(manager: processManager, logger: ChatLogger());

  final response = await claudeCode.prompt(
    'return the exact conversation so far in markdown format',
    // pipedContent: File('./.deep_agent/log.md'),
  );
  print('Response: $response');
}
