import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/shared/clients/interface.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:deep_agent/src/shared/utils.dart';

class ClaudeCode extends LLMProvider {
  /// A Claude Code LLM provider implementation.
  ClaudeCode({
    required super.processManager,
    required super.logger,
  });

  @override
  String get name => 'ClaudeCode';

  @override
  Future<AIResponse> prompt(
    String prompt, {
    File? pipedContent,
    bool contiune = true,
  }) async {
    late final List<String> command;
    final escapedPrompt = Utils.escapeShellCommand(prompt);

    if (pipedContent != null) {
      if (!pipedContent.existsSync()) {
        throw Exception(
          'Piped content file does not exist: ${pipedContent.path}',
        );
      }
      command = [
        'bash',
        '-c',
        "cat '${pipedContent.path}' | claude ${contiune ? '-c' : ''} -p '$escapedPrompt --dangerously-skip-permissions'",
      ];
      logger.log('${pipedContent.path} | $escapedPrompt', Role.user);
    } else {
      command = [
        'claude',
        if (contiune) '-c',
        '-p',
        escapedPrompt,
        '--dangerously-skip-permissions',
      ];
      logger.log(escapedPrompt, Role.user);
    }
    final result = await processManager.run(command);
    if (result.stderr != null && result.stderr.toString().isNotEmpty) {
      logger.log(
        'Error | ${result.stderr}',
        Role.assistant,
      );
      return AIResponse(
        error: result.stderr.toString().trim(),
      );
    }
    final response = result.stdout?.toString().trim();
    logger.log(
      response ?? '',
      agent: name,
      Role.assistant,
    );
    if (response == null || response.isEmpty) {
      return AIResponse(
        error: 'No response from Claude Code',
      );
    }
    return AIResponse.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }
}

// void main() async {
//   const processManager = LocalProcessManager();
//   final claudeCode = ClaudeCode(
//     processManager: processManager,
//     logger: ChatLogger(),
//   );

//   final response = await claudeCode.prompt(
//     'return the exact conversation so far in markdown format',
//     // pipedContent: File('./.deep_agent/log.md'),
//   );
//   print('Response: $response');
// }
