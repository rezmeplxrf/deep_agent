import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/features/workflow/repository.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:process/process.dart';

class WorkflowService {
  final ProcessManager _processManager = const LocalProcessManager();
  final _chatLogger = ChatLogger();
  final _repository = WorkflowRepository();
  final _defaultWorkflowPath = './.deep_agent/workflows.jsonl';

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

      _chatLogger.logger.info('Running workflow step: ${workflow.name}');
      final intialResponse = await _repository.promptAI(
        workflow: workflow,
        processManager: _processManager,
        logger: _chatLogger,
        initialPrompt: true,
      );
      if (intialResponse.output != null) {
        _chatLogger.logger.info(intialResponse.output);
      }
      if (intialResponse.error != null) {
        _chatLogger.logger.err(intialResponse.error);
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
        final userResponse = _repository.promptUser(
          input: response.userAction!,
          chatLogger: _chatLogger,
        );
        response = await _repository.pipeUserInput(
          prompt: userResponse.join(', '),
          provider: workflow.provider,
          processManager: _processManager,
          logger: _chatLogger,
        );
        if (response.error != null) {
          _chatLogger.logger.err(response.error);
          break;
        }
      }
      if (response.output != null) {
        _chatLogger.logger.success('${response.output}');
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
}
