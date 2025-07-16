import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/features/workflow/repository.dart';
import 'package:deep_agent/src/shared/clients/claude_code.dart';
import 'package:deep_agent/src/shared/clients/interface.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:process/process.dart';

class WorkflowService {
  final ProcessManager processManager = const LocalProcessManager();
  final _logger = ChatLogger();
  final _repository = WorkflowRepository();
  final _defaultWorkflowPath = './.deep_agent/workflows.jsonl';

  Future<WorkflowResult> run(
    String intiialUserPrompt, {
    File? workflowFile,
  }) async {
    final workFlows = await _repository.loadWorkflows(
      workflowFile ?? File(_defaultWorkflowPath),
    );
    for (final workflow in workFlows) {
      // TODO: 
      // 1. Prompt AI, and thne execeute any action unitl null
      // 2. If action is null and output is not null, pass the output to the next workflow
      // 3. if its the last workflow, return the result to the user via terminal
    }
  }

  Future<AIResponse> prompt(WorkflowStep workflow) async {
    late final LLMProvider provider;
    switch (workflow.provider) {
      case Provider.claudeCode:
        provider = ClaudeCode(
          processManager: processManager,
          logger: _logger,
        );

      default:
        throw ArgumentError('Unknown provider: ${workflow.provider}');
    }
    return provider.prompt(workflow.prompt);
  }
}
