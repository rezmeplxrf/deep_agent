import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/shared/clients/claude_code.dart';
import 'package:deep_agent/src/shared/clients/interface.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:process/process.dart';

class WorkflowRepository {
  Future<List<WorkflowStep>> loadWorkflows(File workflowFile) async {
    if (!workflowFile.existsSync()) {
      throw Exception('Workflow file does not exist: ${workflowFile.path}');
    }
    final content = await workflowFile.readAsLines();
    if (content.isEmpty) return [];
    return content.map((line) {
      return WorkflowStep.fromJson(jsonDecode(line) as Map<String, dynamic>);
    }).toList();
  }

  String _getTemplate(String userPrompt) {
    final systemPromptFIle = File(
      './.deep_agent/system_prompt.md',
    );
    if (!systemPromptFIle.existsSync()) {
      systemPromptFIle.createSync(recursive: true);
    }

    final systemPrompt = systemPromptFIle.readAsStringSync().trim();
    return '''
# Instruction
$userPrompt

${systemPrompt.isNotEmpty ? '# Must follow below rules strictly. These supercedes any other instructions.\n$systemPrompt\n' : ''}
# You can perform any shell command within the current directory without asking for permission, except that requires 'sudo'.

Response format:
"userAction" - When you want to give multiple choices to users for clarification. When user prompt is not clear, do ask with choices.
"output" - your textual response
- At least one of them must be present
# Must respond in the following format (This is a Json object):
${jsonEncode(AIResponse(
      userAction: UserAction(
        options: ['Choice 1', 'Choice 2', 'And so on...'],
        question: 'A question to ask the user to understand their intent better',
      ),
      output: 'Your final response here (e.g. summary)',
    ).toJson())}
''';
  }

  List<String> promptUser({
    required UserAction input,
    required ChatLogger chatLogger,
  }) {
    return chatLogger.logger.chooseAny(
      input.question,
      choices: input.options,
      defaultValues: [
        "I don't know. Please choose what you think is the best",
      ],
    );
  }

  Future<AIResponse> promptAI({
    required WorkflowStep workflow,
    required ProcessManager processManager,
    required ChatLogger logger,
    bool initialPrompt = false,
  }) async {
    final provider = _getProvider(workflow.provider, processManager, logger);
    if (initialPrompt) {
      return provider.prompt(_getTemplate(workflow.prompt));
    } else {
      return provider.prompt(workflow.prompt);
    }
  }

  LLMProvider _getProvider(
    Provider provider,
    ProcessManager processManager,
    ChatLogger logger,
  ) {
    late final LLMProvider llmProvider;
    switch (provider) {
      case Provider.claudeCode:
        llmProvider = ClaudeCode(
          processManager: processManager,
          logger: logger,
        );

      default:
        throw ArgumentError('Unknown provider: $provider');
    }
    return llmProvider;
  }

  Future<AIResponse> pipeUserInput({
    required String prompt,
    required Provider provider,
    required ProcessManager processManager,
    required ChatLogger logger,
  }) async {
    final llmProvider = _getProvider(provider, processManager, logger);
    return llmProvider.prompt(prompt);
  }
}
