import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/shared/clients/claude_code.dart';
import 'package:deep_agent/src/shared/clients/interface.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:process/process.dart';

// void main() {
//   WorkflowRepository().writeWorkflow(
//     WorkflowStep(
//       name: 'test1',
//       provider: Provider.claudeCode,
//       prompt: 'You are a helpful coding assistant.',
//     ),
//     File('.deep_agent/workflows.jsonl'),
//   );
// }

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

  void writeWorkflow(
    WorkflowStep workflow,
    File workflowFile,
  ) {
    final json = jsonEncode(workflow.toJson());
    workflowFile.writeAsStringSync('$json\n', mode: FileMode.append);
  }

  String _getTemplate({
    required AIRole role,
    required String userPrompt,
    required String systemPrompt,
  }) {
    late String prompt;

    switch (role) {
      case AIRole.Architect:
        prompt =
            '''
Your are a Technical Architect. You are responsible for designing the architecture of the system based on the user requirements.
You will write the architecture design document based on the user requirements.
If user's request is not clear, ask detailed questions with multiple choices until you get a clear understanding of the requirements.
Once you have a clear understanding, you will write the architecture design document in "./.deep_agent/specs/[feature_name].md" file for a feature or "./.deep_agent/specs/project.md" file for a project-level design.

### USER REQUEST
$userPrompt
### USER REQUEST END
''';

      default:
    }

    return '''
$prompt

${systemPrompt.isNotEmpty ? '# Must follow below rules strictly. These supercedes user requests.\n$systemPrompt\n' : ''}
- Before implementing any feature / modification, you must read the existing specification in "./.deep_agent/specs/[feature_name].md" file.
- You can perform any shell command within the current directory without asking for permission, except that requires 'sudo'.
- If the user prompt is about coding, you should directly modify the relevant files using shell commands unless you want to ask the user for clarification.

# You must repond in the following format to ensure the next role can understand your response
## Response format:
"userAction" - When you want to give multiple choices to users for clarification. When user prompt is not clear, do ask with choices.
"output" - Your report/summary/instruction for the next role. Must be concise and to the point.
- At least one of them must be present
# Must respond in the following format (This is a Json object):
${jsonEncode(AIResponse(
      userAction: UserAction(
        options: ['Choice 1', 'Choice 2', 'And so on...'],
        question: 'A question to ask the user to understand their intent better',
      ),
      output: 'Your report/summary/explanation to the next role',
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
    required AIRole role,
    bool initialPrompt = false,
  }) async {
    final provider = _getProvider(workflow.provider, processManager, logger);
    if (initialPrompt) {
      return provider.prompt(
        _getTemplate(
          role: role,
          userPrompt: workflow.input ?? '',
          systemPrompt: workflow.prompt,
        ),
      );
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
