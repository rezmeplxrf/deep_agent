import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/shared/utils.dart';
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

  Future<ShellCommandResult> executeAction(
    String command,
    ProcessManager processManager,
  ) async {
    final escapedCommand = Utils.escapeShellCommand(command);
    final result = await processManager.run(
      ['bash', '-c', escapedCommand],
    );
    return ShellCommandResult(
      result.pid,
      result.exitCode,
      result.stdout.toString(),
      result.stderr?.toString(),
    );
  }

  String getTemplate(String userPrompt, {File? systemPromptFile}) {
    final systemPrompt =
        (systemPromptFile ?? File('./.deep_agent/system_prompt.md'))
            .readAsStringSync()
            .trim();
    return '''
# Instruction
$userPrompt

# Must follow below rules strictly. This supercedes any other instructions.
$systemPrompt

# Respond in the following format:
${jsonEncode(AIResponse(
      action: 'Shell command to execute (e.g. )',
      userAction: UserAction(
        options: ['Yes', 'No', 'Other'],
        question: 'Some question to ask the user',
      ),
      output: '```typescript \n some code here',
    ).toJson())}
''';
  }
}
