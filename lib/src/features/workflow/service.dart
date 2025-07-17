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
      final response1 = await prompt(workflow);
      if (response1.output != null) {
        logger.info(response1.output);
      }
      if (response1.error != null) {
        logger.err(response1.error);
        results.add(
          WorkflowResult(
            success: false,
            error: response1.error,
            response: response1,
          ),
        );
        break;
      }
      var response = response1;

      while (response.userAction != null) {
        final userResponse = promptUser(response.userAction!);
        response = await pipeUserInput(
          userResponse.join(', '),
          workflow.provider,
        );
        if (response.error != null) {
          logger.err(response.error);
          results.add(
            WorkflowResult(
              success: false,
              error: response.error,
              response: response,
            ),
          );
          break;
        }
      }
      if (response.output != null) {
        logger.success('${response.output}');
        results.add(WorkflowResult(response: response, success: true));
        previousResponse = response;
      } else {
        logger.err('No output from workflow step: ${workflow.name}');
        results.add(
          WorkflowResult(
            success: false,
            error: 'No output from workflow step: ${workflow.name}',
            response: response,
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

  Future<AIResponse> prompt(WorkflowStep workflow) async {
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

  Future<AIResponse> pipeActionResult(
    ShellCommandResult result,
    WorkflowStep workflow,
  ) async {
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
    return provider.prompt(
      '''Terminal output: ${result.stderr != null ? result.stdout : result.stderr}''',
    );
  }
}
