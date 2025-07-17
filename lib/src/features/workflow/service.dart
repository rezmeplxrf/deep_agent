import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/features/workflow/repository.dart';
import 'package:deep_agent/src/shared/clients/claude_code.dart';
import 'package:deep_agent/src/shared/clients/interface.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:process/process.dart';

class WorkflowService {
  final ProcessManager processManager = const LocalProcessManager();
  final _logger = ChatLogger();
  final _repository = WorkflowRepository();
  final _defaultWorkflowPath = './.deep_agent/workflows.jsonl';
  final logger = Logger(
    level: Level.verbose,
  );

  // 1. Prompt AI with userPrompt, if userAction is not null, ask the user for input
  // 2. If userAction is null and AIResponse is not null, pass the AIResponse to the next workflow
  // 3. If error occurs, log the error and stop the workflows
  Future<List<WorkflowResult>> run(
    String userPrompt, {
    File? workflowFile,
  }) async {
    final workFlows = await _repository.loadWorkflows(
      workflowFile ?? File(_defaultWorkflowPath),
    );
    final results = <WorkflowResult>[];

    AIResponse? previousResponse;
    for (var i = 0; i < workFlows.length; i++) {
      /// if initial workflow step, use the user prompt
      final workflow = workFlows[i].copyWith(
        input: (i == 0) ? userPrompt : previousResponse?.output,
      );

      logger.info('Running workflow step: ${workflow.name}');
      final intialResponse = await promptAI(workflow);
      if (intialResponse.output != null) {
        logger.info(intialResponse.output);
      }
      if (intialResponse.error != null) {
        logger.err(intialResponse.error);
        results.add(
          WorkflowResult(
            success: false,
            error: intialResponse.error,
            response: intialResponse,
            workflowName: workflow.name,
          ),
        );
        break;
      }
      var response = intialResponse;

      while (response.userAction != null) {
        final userResponse = promptUser(response.userAction!);
        response = await pipeUserInput(
          userResponse.join(', '),
          workflow.provider,
        );
        if (response.error != null) {
          logger.err(response.error);
          break;
        }
      }
      if (response.output != null) {
        logger.success('${response.output}');
        results.add(
          WorkflowResult(
            response: response,
            success: true,
            workflowName: workflow.name,
          ),
        );
        previousResponse = response;
      } else {
        results.add(
          WorkflowResult(
            success: false,
            error: response.error,
            response: response,
            workflowName: workflow.name,
          ),
        );
        break;
      }
    }
    return results;
  }

  List<String> promptUser(UserAction input) {
    return logger.chooseAny(
      input.question,
      choices: input.options,
      defaultValues: [
        "I don't know. Please choose what you think is the best",
      ],
    );
  }

  Future<AIResponse> promptAI(WorkflowStep workflow) async {
    final provider = _getProvider(workflow.provider);
    return provider.prompt(workflow.prompt);
  }

  LLMProvider _getProvider(Provider provider) {
    late final LLMProvider llmProvider;
    switch (provider) {
      case Provider.claudeCode:
        llmProvider = ClaudeCode(
          processManager: processManager,
          logger: _logger,
        );

      default:
        throw ArgumentError('Unknown provider: $provider');
    }
    return llmProvider;
  }

  Future<AIResponse> pipeUserInput(String prompt, Provider provider) async {
    final llmProvider = _getProvider(provider);
    return llmProvider.prompt(prompt);
  }
}
