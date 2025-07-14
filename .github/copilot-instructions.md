# Base Instruction
Project Name: DeepAgent
## Description
DeepAgent is a Dart CLI application that functions as a Coding Agent by integrating multiple AI coding tools—Claude Code, Gemini CLI, and GitHub Copilot CLI—into a streamlined development workflow.

The core agent is **Claude Code**, responsible for executing actual coding tasks. **Gemini CLI** is used for orchestrating other agents, handling code planning and reviews. **GitHub Copilot CLI** ensures markdown documentation (.md files) stays current and synchronized.

The integration of these agents is managed using Dart’s `Process.run` function, enabling modular and programmatic control over their execution.

## CLI Template
This project uses the `very_good_cli` template structure. Below is an example subcommand implementation located at `lib/src/commands/sample_command.dart`:

```dart
/// {@template sample_command}
///
/// `deep_agent sample`
/// A [Command] to exemplify a sub command
/// {@endtemplate}
class SampleCommand extends Command<int> {
  /// {@macro sample_command}
  SampleCommand({required Logger logger}) : _logger = logger {
    argParser.addFlag(
      'cyan',
      abbr: 'c',
      help: 'Prints the same joke, but in cyan',
      negatable: false,
    );
  }

  @override
  String get description => 'A sample sub command that just prints one joke';

  @override
  String get name => 'sample';

  final Logger _logger;

  @override
  Future<int> run() async {
    var output = 'Which unicorn has a cold? The Achoo-nicorn!';
    if (argResults?['cyan'] == true) {
      output = lightCyan.wrap(output)!;
    }
    _logger.info(output);
    return ExitCode.success.code;
  }
}
```

## Coding Practices
- Follow the DRY (Don't Repeat Yourself) principle.
- Follow very_good_analysis style
- Use enums instead of Strings for fixed sets of values.
- Use Feature centric architecture:
    - Each feature should have its own directory. e.g. `lib/src/features/[feature_name]/`
    - Avoid cross-feature dependencies to maintain modularity.
- Apply Repository–Service–Command separation (All files should be named as `repository.dart`, `service.dart`, `command.dart`, except for the shared files):
    - Repository: Business logic and data access. e.g. `lib/src/features/[feature_name]/repository.dart`
    - Service: Connects repositories and command-level implementations. e.g. `lib/src/features/[feature_name]/service.dart`
    - Command: Handles user input and orchestrates service calls. e.g. `lib/src/features/[feature_name]/command.dart`
    - Shared files should be placed in `lib/src/shared/[descriptive_name].dart`.
- Use Dart models created with the freezed package when returning multiple values instead of raw objects or maps.
- Ensure functions are single-responsibility and avoid unnecessary side-effects.
- functions must not modify parameters directly inside from itself.
- sub functions must not modify the global/class variables from itself.
- Avoid using void return types unless absolutely necessary.
- Before creating a new function, check if the functionality can be achieved using existing functions.


## Allowed Libraries
Use only the following external packages. If additional libraries are required, consult the Product Owner (Human).
- ansicolor
- dio
- freezed
- cli_completion
- mason_logger