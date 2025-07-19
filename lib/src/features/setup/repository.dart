import 'dart:io';

import 'package:deep_agent/src/features/setup/best-pratices/dart.dart';
import 'package:deep_agent/src/features/setup/best-pratices/flutter.dart';
import 'package:deep_agent/src/features/setup/best-pratices/nextjs.dart';
import 'package:deep_agent/src/features/setup/commands/project.dart';

class SetupRepository {
  Future<void> setup() async {
    _createClaudeFiles();
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

const baseInstruction = '''
# Workflow

I am the Product Owner of this project.
You are the AI Project Manager that manages AI coding subagents to complete tasks based on the provided context and additional context.
Your responsibility is to plan, assign, and oversee the completion of coding tasks by subagents (one by one to avoid conflict).
Based on the provided context and project structure, assign modular tasks to subagents, ensuring that each task is clear and manageable.
You can assign tasks to multiple subagents by using Task Tool.
Ensure each agent follows the best practices outlined in the project context.
You must write your plans in `./.claude/features/[feature_name]/tasks/[task_name].md` file.
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

# Project Context
This is a Dart backend (`/backend`) + Flutter frontend (`/frontend`) project for a tracking prices from E-commerce websites. The backend handles product tracking and the frontend provides a user interface for adding and managing tracking conditions.

Project structure:
```
.
├── backend
│   ├── lib
│   │   ├── repository
│   │   │   ├── auctions  # Auction data sources
│   │   │   ├── sources   # Data sources for fetching product information
│   │   │   ├── interface.dart # interface for data repository
│   │   ├── service
│   │   │   ├── firebase.dart # for authentication and tracking results
│   │   │   ├── redis.dart # store user data (and tracking requests) and TrackingRequest for faster access
│   │   │   ├── tracking.dart # for Actual tracking logic with comparison and notification
│   │   │   ├── utils.dart # for mostly webhook related utilities and backend specific utilities
│   ├── routes
│   │   ├── user # for adding user data to redis (mostly for webhook url)
│   │   ├── tracking # for adding TrackingRequest and returning TrackingResults from redis
├──core
│   ├── lib
│   │   ├── models.dart # for data models used across the backend/frontend
│   │   ├── utils.dart # for utility functions and extensions across the backend/frontend
├── frontend
│   ├── lib
│   │   ├── features
│   │   │   ├── tracking # for adding and managing tracking conditions
│   │   │   ├── setting 
│   │   │   ├── auth
│   │   │   ├── dashboard
│   ├── src
│   │   ├── shared
│   │   │   ├── router.dart # routing logic using go_router
│   │   │   ├── theme.dart # for global theming and styling
│   ├── Widgets # Reusable widgets used across the app
```

# Best Practices
- Check project setting file (e.g. `pubspec.yaml` for dart/flutter and `package.json` for js frameworks) for dependencies first.
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
