import 'dart:io';

import 'package:deep_agent/src/features/setup/roles/ochestrator.dart';

class SetupRepository {
  Future<void> setup() async {
    _createClaudeFiles();
    _writeBaseInstruction();
    _writeBaseRules();
  }

  void _createClaudeFiles() {
    final commandDir = Directory('./.claude/commands');
    final specDir = Directory('./.claude/specs');
    final templateDir = Directory('./.claude/templates');

    if (!commandDir.existsSync()) {
      commandDir.createSync(recursive: true);
    }
    if (!specDir.existsSync()) {
      specDir.createSync(recursive: true);
    }
    if (!templateDir.existsSync()) {
      templateDir.createSync(recursive: true);
    }
  }

  void _writeBaseInstruction() {
    final baseFile = File('./CLAUDE.md');
    if (!baseFile.existsSync()) {
      baseFile
        ..createSync(recursive: true)
        ..writeAsStringSync(baseInstruction);
    }
  }

  void _writeBaseRules() {
    final commandFile = File('./.claude/commands/spec-commands.md');
    if (!commandFile.existsSync()) {
      commandFile
        ..createSync(recursive: true)
        ..writeAsStringSync(baseInstruction);
    }
  }
}
