import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/features/workflow/repository.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:process/process.dart';

// void main() async {
//   final service = WorkflowService();
//   final results = await service.run(
//     'Write a medium level leet code question in `./test/[question_name].dart` directory with the efficient solution. - except to the two-sum question',
//   );
//   print(results);
// }

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
    required Logger logger,
    File? workflowFile,
  }) async {
    final workFlows = await _repository.loadWorkflows(
      workflowFile ?? File(_defaultWorkflowPath),
    );
    if (workFlows.isEmpty) {
      logger.err(
        'No workflows found in ${workflowFile?.path ?? _defaultWorkflowPath}',
      );
      return [];
    }
    final results = <WorkflowResult>[];

    AIResponse? previousResponse;
    for (var i = 0; i < workFlows.length; i++) {
      /// if initial workflow step, use the user prompt
      final workflow = workFlows[i].copyWith(
        input: (i == 0) ? userPrompt : previousResponse?.output,
      );

      logger.info('Running workflow step: ${workflow.name}');
      final intialResponse = await _repository.promptAI(
        workflow: workflow,
        processManager: _processManager,
        logger: _chatLogger,
        shouldContinue: false,
        role: workflow.role,
      );
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

      while (workflow.role == AIRole.Architect && response.askUser != null) {
        final userResponse = _repository.promptUser(
          input: response.askUser!,
          logger: logger,
        );
        response = await _repository.pipeUserInput(
          prompt: userResponse.join(', '),
          provider: workflow.provider,
          processManager: _processManager,
          logger: _chatLogger,
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
}
