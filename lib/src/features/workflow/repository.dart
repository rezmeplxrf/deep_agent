import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/shared/clients/claude_code.dart';
import 'package:deep_agent/src/shared/clients/interface.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:process/process.dart';

// void main() {
//   WorkflowRepository().createWorkflows(
//     [
//       WorkflowStep(
//         name: 'step1',
//         provider: Provider.claudeCode,
//         role: AIRole.Architect,
//       ),
//       WorkflowStep(
//         name: 'step2',
//         provider: Provider.claudeCode,
//         role: AIRole.Developer,
//       ),
//       WorkflowStep(
//         name: 'step3',
//         provider: Provider.claudeCode,
//         role: AIRole.LeadDeveloper,
//       ),
//     ],
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

  void createWorkflows(List<WorkflowStep> workflows, File workflowFile) {
    final lines = workflows.map((step) => jsonEncode(step.toJson())).toList();
    workflowFile.writeAsStringSync(lines.join('\n'));
  }

  String _getTemplate({
    required AIRole role,
    required String userPrompt,
  }) {
    late String prompt;

    switch (role) {
      case AIRole.Architect:
        prompt =
            '''
Your are a Technical Architect. You are responsible for designing the architecture of the system based on the user requirements.
You will write the architecture design document based on the user requirements.
If user's request is not clear, ask detailed questions with multiple choices until you get a clear understanding of the requirements.
Once you have a clear understanding, you will write the architecture design document in "./.deep_agent/specs/[feature_name].md" file for a feature or "./.deep_agent/specs/project.md" file for a project-level design by running shell command to create/modify the files.

You can ask the user using the following format (JSON):

${jsonEncode(AIResponse(
              askUser: UserPrompt(
                options: ['Choice 1', 'Choice 2', 'And so on...'],
                question: 'A question to ask the user to understand their intent better',
              ),
            ).toJson())}

Finally, after completing your task, you must write the detailed instruction to the developer to implement the design.
You must respond in the following format (JSON) to instruct the developer

${jsonEncode(AIResponse(
              output: 'Your instruction to the developer here',
            ).toJson())}

### USER REQUEST
$userPrompt
### USER REQUEST END
''';

      case AIRole.LeadDeveloper:
        prompt =
            '''
You are a Lead Developer. You are responsible for reviewing the given code for any bugs or potential issues and ensuring the code meets the architecture design.
You can find the architecture design document in "./.deep_agent/specs/[feature_name].md" file. 
And also find the project-level design in "./.deep_agent/specs/project.md" file.
Based on the given report/git diff, you will review the code and make any necessary changes yourself by running shell commands directly.
After making any changes, make sure to check linter and run tests to ensure the code is working as expected.

You must review the code using git diff and any code mentioned in theDeveloper's report.
After reviewing the code, you must fix/modify any issues you find by running shell commands directly in the current directory.

### DEVELOPER REPORT
$userPrompt
### DEVELOPER REPORT END

Finally, after completing your task, you must write the summary to the Product Owner to finalize the implementation.
You must respond in the following format (JSON) for the Product Owner:

${jsonEncode(AIResponse(
              output: 'Your summary here',
            ).toJson())}
''';

      case AIRole.Developer:
        prompt =
            '''
You are an Experienced Developer. You are responsible for implementing the architecture design in code.
You will write the code based on the architecture design document and instructions provided by the Architect.
You can find the architecture design document in "./.deep_agent/specs/[feature_name].md" file.
You can also find the project-level design in "./.deep_agent/specs/project.md" file
You can directly create/modify the files by running shell commands in the current directory.

### ARCHITECT INSTRUCTION
$userPrompt
### ARCHITECT INSTRUCTION END

Finally, after completing your task, you must write the report with the file path you've created/modified to the Lead Developer to reivew your code
You must respond in the following format (JSON) for the Lead Developer:

${jsonEncode(AIResponse(
              output: 'Your report here',
            ).toJson())}

''';
    }

    return prompt;
  }

  List<String> promptUser({
    required UserPrompt input,
    required Logger logger,
  }) {
    return logger.chooseAny(
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
    bool shouldContinue = true,
  }) async {
    final provider = _getProvider(workflow.provider, processManager, logger);
    if (!shouldContinue) {
      return provider.prompt(
        shouldContinue: false,
        _getTemplate(
          role: role,
          userPrompt: workflow.input!,
        ),
      );
    } else {
      return provider.prompt(workflow.input!);
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
