import 'dart:io';

import 'package:deep_agent/src/features/setup/roles/ochestrator.dart';
import 'package:deep_agent/src/features/setup/templates/design.dart';
import 'package:deep_agent/src/features/setup/templates/requirements.dart';

class SetupRepository {
  Future<void> setup() async {
    _createClaudeFiles();
    _writeBaseInstruction();
    _createTemplates();
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

  void _createTemplates() {
    final designTemplate = File('./.claude/templates/design-template.md');
    if (!designTemplate.existsSync()) {
      designTemplate
        ..createSync(recursive: true)
        ..writeAsStringSync(designTemplateContent);
    }
    final requirementsTemplate = File(
      './.claude/templates/requirements-template.md',
    );
    if (!requirementsTemplate.existsSync()) {
      requirementsTemplate
        ..createSync(recursive: true)
        ..writeAsStringSync(requirementsTemplateContent);
    }
  }
}
