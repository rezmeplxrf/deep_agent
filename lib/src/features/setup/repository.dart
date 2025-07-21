import 'dart:io';

import 'package:deep_agent/src/features/setup/best-pratices/dart.dart';
import 'package:deep_agent/src/features/setup/best-pratices/flutter.dart';
import 'package:deep_agent/src/features/setup/best-pratices/web.dart';

class SetupRepository {
  Future<void> setup() async {
    _createBestPractices();
  }

  void _createBestPractices() {
    final commandDir = Directory('./.claude/commands');
    if (!commandDir.existsSync()) {
      commandDir.createSync(recursive: true);
    }
    if (!commandDir.existsSync()) {
      commandDir.createSync(recursive: true);
      File(
        './.claude/command/dart.md',
      ).writeAsStringSync(dartInstruction);
      File(
        './.claude/command/flutter.md',
      ).writeAsStringSync(flutterInstruction);
      File(
        './.claude/command/nextjs.md',
      ).writeAsStringSync(nextjsInstruction);
      File(
        './.claude/command/base.md',
      ).writeAsStringSync(baseInstruction);
    }
  }
}

const baseInstruction = '''
# Workflow

I am the Product Owner of this project.
You are the AI Project Manager that manages AI coding subagents to complete tasks based on the provided context and additional context.
Your responsibility is to plan, assign, and oversee the completion of coding tasks by subagents (one by one to avoid conflict).
Based on the provided context and project structure, assign modular tasks to subagents, ensuring that each task is clear and manageable.
You can assign tasks to multiple subagents by using Task Tool.
Ensure each agent follows the best practices outlined in the project context.
You must write your plans in `./.agents/features/[feature_name]/tasks/[task_name].md` file.
You must also update the [task_name].md accordingly if the context changes and mark if certain objective is completed.

# [task_name].md template
```markdown
# Task [task_name]
# Context
[task_context]
# Requirements
- [ ] [task_requirement_1]
- [ ] [task_requirement_2]
- [ ] [task_requirement_3]
# Objectives
- [ ] [task_goal_1]
- [ ] [task_goal_2]
- [ ] [task_goal_3]
# Progress
- [ ] [task_progress_1]
- [ ] [task_progress_2]
- [ ] [task_progress_3]
```

# Best Practices
- Check project setting file for dependencies first.
- Use existing libraries defined in the project setting file to avoid installing new ones and re-inventing the wheel.
- Follow the DRY (Don't Repeat Yourself) principle.
- Do not add any comments or unnecessary print statements in the code.
- Class, functions, variables name should be self-explanatory.
- Use enums instead of Strings for fixed sets of values.
- Use Data Models according to the language's conventions.
- Avoid copying/storing potentially large data. Instead store the indices of the necessary data in the Map, using unique key, and then find the needed value from the original data using the Map.
- Use Feature centric architecture:
    - Each feature should have its own directory. e.g. `/src/features/[feature_name]/`
    - Avoid cross-feature dependencies to maintain modularity.
    - Ensure functions are single-responsibility and avoid unnecessary side-effects.
    - Avoid modifying parameters/class state directly from within sub functions.
- Apply Repository-Service Pattern:
    - Use repositories to abstract data access and provide a clean API for the service layer.
    - Keep business logic in services, and use repositories for data retrieval and persistence.
- Follow language/framework conventions for naming and structuring code.
- Follow performance best practices, such as avoiding unnecessary computations and using efficient data structures.
- Avoid creating potentially duplicate functions, variables, or classes.
- After implementing a feature, always add tests in the `test/` directory and ensure all tests pass.
''';
