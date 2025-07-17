import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';

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

# You can perform any shell command within the current directory without asking for permission, except that requires 'sudo'.

# Respond in the following format ("action", "userAction", "output" fields are all optional but at least one of them must be present):
${jsonEncode(AIResponse(
      userAction: UserAction(
        options: ['Yes', 'No', 'Other'],
        question: 'A question to ask the user to understand their intent better',
      ),
      output: '```typescript \n some code here',
    ).toJson())}
''';
  }
}
