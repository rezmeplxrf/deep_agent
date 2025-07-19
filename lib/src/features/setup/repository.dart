import 'dart:io';

import 'package:deep_agent/src/features/setup/best-pratices/dart.dart';
import 'package:deep_agent/src/features/setup/best-pratices/flutter.dart';
import 'package:deep_agent/src/features/setup/best-pratices/nextjs.dart';
import 'package:deep_agent/src/features/setup/commands/project.dart';
import 'package:deep_agent/src/features/setup/roles/developer.dart';
import 'package:deep_agent/src/features/setup/roles/ochestrator.dart';
import 'package:deep_agent/src/features/setup/roles/reviwer.dart';
import 'package:deep_agent/src/features/setup/templates/design.dart';
import 'package:deep_agent/src/features/setup/templates/requirements.dart';
import 'package:deep_agent/src/features/setup/templates/task.dart';

class SetupRepository {
  Future<void> setup() async {
    _createClaudeFiles();
    _createTemplates();
    _createBestPractices();
    _createRoles();
    _createCommands();
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
    final taskTemplate = File('./.claude/templates/task-template.md');
    if (!taskTemplate.existsSync()) {
      taskTemplate
        ..createSync(recursive: true)
        ..writeAsStringSync(taskTemplateContent);
    }
  }

  void _createBestPractices() {
    final bestPracticesDir = Directory('./.claude/best-practices');
    if (!bestPracticesDir.existsSync()) {
      bestPracticesDir.createSync(recursive: true);
      File(
        './.claude/best-practices/dart.md',
      ).writeAsStringSync(dartInstruction);
      File(
        './.claude/best-practices/flutter.md',
      ).writeAsStringSync(flutterInstruction);
      File(
        './.claude/best-practices/nextjs.md',
      ).writeAsStringSync(nextjsInstruction);
    }
  }

  void _createRoles() {
    final baseFile = File('./CLAUDE.md');
    if (!baseFile.existsSync()) {
      baseFile
        ..createSync(recursive: true)
        ..writeAsStringSync(baseInstruction);
    }
    final developerFile = File('./.claude/commands/develop.md');
    if (!developerFile.existsSync()) {
      developerFile
        ..createSync(recursive: true)
        ..writeAsStringSync(developerCommandContent);
    }
    final reviewerFile = File('./.claude/commands/review.md');
    if (!reviewerFile.existsSync()) {
      reviewerFile
        ..createSync(recursive: true)
        ..writeAsStringSync(reviewerCommandContent);
    }
  }

  void _createCommands() {
    final overview = File('./.claude/commands/project-overview.md');
    if (!overview.existsSync()) {
      overview
        ..createSync(recursive: true)
        ..writeAsStringSync(projectDesignContent);
    }
  }
}
