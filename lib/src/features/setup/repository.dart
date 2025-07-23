import 'dart:io';

import 'package:deep_agent/src/commands/commands.dart';
import 'package:deep_agent/src/features/setup/best-pratices/dart.dart';
import 'package:deep_agent/src/features/setup/best-pratices/flutter.dart';
import 'package:deep_agent/src/features/setup/best-pratices/web.dart';
import 'package:deep_agent/src/features/setup/prompts/prompt_generator.dart';

class SetupRepository {
  Future<void> setup(String appName, Framework framework) async {
    _createCommands(appName, framework);
  }

  void _createCommands(String appName, Framework framework) {
    final commandDir = Directory('./.claude/commands');
    if (!commandDir.existsSync()) {
      commandDir.createSync(recursive: true);
    }
    if (!commandDir.existsSync()) {
      commandDir.createSync(recursive: true);

      switch (framework) {
        case Framework.flutter:
          File(
            './.claude/command/flutter.md',
          ).writeAsStringSync(
            flutterInstruction.replaceAll('[Application]', '[$appName]'),
          );
        case Framework.dart:
          File(
            './.claude/command/dart.md',
          ).writeAsStringSync(
            dartInstruction.replaceAll('[Application]', '[$appName]'),
          );
        case Framework.web:
          File(
            './.claude/command/base.md',
          ).writeAsStringSync(
            webInstruction.replaceAll('[Application]', '[$appName]'),
          );
      }
    }
    final promptGeneration = File('./.claude/command/prompt_generator.md');
    if (!promptGeneration.existsSync()) {
      promptGeneration
        ..createSync(recursive: true)
        ..writeAsStringSync(
          promptGeneratorInstruction,
        );
    }
  }
}
