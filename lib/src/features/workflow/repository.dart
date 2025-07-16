import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';

class WorkflowRepository {
  WorkflowRepository({String? filePath})
    : _workflowFile = (filePath != null)
          ? File(filePath)
          : File(_defaultLogFile) {
    _init();
  }
  static const _defaultLogFile = './.deep_agent/workflows.jsonl';
  final _ready = Completer<void>();
  final File _workflowFile;
  Future<void> _init() async {
    if (!_workflowFile.existsSync()) {
      await _workflowFile.create(recursive: true);
    }
    _ready.complete();
  }

  Future<List<WorkflowStep>> loadWorkflows() async {
    await _ready.future;
    final content = await _workflowFile.readAsLines();
    if (content.isEmpty) return [];
    return content.map((line) {
      return WorkflowStep.fromJson(jsonDecode(line) as Map<String, dynamic>);
    }).toList();
  }
}
