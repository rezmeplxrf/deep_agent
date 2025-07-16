// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:deep_agent/src/features/workflow/domain.dart';
// import 'package:deep_agent/src/shared/utils.dart';
// import 'package:process/process.dart';

// class WorkflowRepository {
//   WorkflowRepository({required this.processManager, String? filePath})
//     : _workflowFile = (filePath != null)
//           ? File(filePath)
//           : File(_defaultLogFile) {
//     _init();
//   }
//   final ProcessManager processManager;
//   static const _defaultLogFile = './.deep_agent/workflows.jsonl';
//   final _ready = Completer<void>();
//   final File _workflowFile;
//   Future<void> _init() async {
//     if (!_workflowFile.existsSync()) {
//       await _workflowFile.create(recursive: true);
//     }
//     _ready.complete();
//   }

//   Future<List<WorkflowStep>> loadWorkflows() async {
//     await _ready.future;
//     final content = await _workflowFile.readAsLines();
//     if (content.isEmpty) return [];
//     return content.map((line) {
//       return WorkflowStep.fromJson(jsonDecode(line) as Map<String, dynamic>);
//     }).toList();
//   }

//   Future<void> saveWorkflow(WorkflowStep step) async {
//     await _ready.future;
//     await _workflowFile.writeAsString(
//       '${jsonEncode(step.toJson())}\n',
//       mode: FileMode.append,
//     );
//   }

//   Future<ShellCommandResult> executeAction(
//     String command,
//   ) async {
//     final escapedCommand = Utils.escapeShellCommand(command);
//     final result = await processManager.run(
//       ['bash', '-c', escapedCommand],
//     );

//     return ShellCommandResult(
//       result.pid,
//       result.exitCode,
//       result.stdout.toString(),
//       result.stderr?.toString(),
//     );
//   }

//   Future<AIResponse> runWorkflow(WorkflowStep workflow) async {

//     return AIResponse(
//       workflowName: workflow.name,
//       action: action,
//       userAction: userAction,
//       output: output.stdout,
//     );
//   }
// }
