import 'dart:io';

import 'package:deep_agent/src/features/workflow/domain.dart';
import 'package:deep_agent/src/shared/logger.dart';
import 'package:process/process.dart';

abstract class LLMProvider {
  LLMProvider({
    required this.processManager,
    required this.logger,
  });

  /// The name of the LLM provider.
  String get name;

  /// The process manager used to start processes.
  final ProcessManager processManager;

  /// The logger used for logging interactions with the LLM provider.
  final ChatLogger logger;

  /// Prompts the LLM with a given prompt and returns the response.
  Future<AIResponse> prompt(
    String prompt, {
    File? pipedContent,
    bool contiune = true,
  });
}
