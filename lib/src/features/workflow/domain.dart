// ignore_for_file: sort_constructors_first

enum Provider { claudeCode, geminiCli, llmApi }

Provider getProvider(String provider) {
  switch (provider.toLowerCase()) {
    case 'claudecode':
      return Provider.claudeCode;
    default:
      throw ArgumentError('Unknown provider: $provider');
  }
}

String getProviderName(Provider provider) {
  switch (provider) {
    case Provider.claudeCode:
      return 'ClaudeCode';
    default:
      throw ArgumentError('Unknown provider: $provider');
  }
}

class WorkflowStep {
  WorkflowStep({
    required this.name,
    required this.provider,
    required this.prompt,
  });
  final String name;
  final Provider provider;
  final String prompt;

  @override
  String toString() {
    return 'WorkflowStep(name: $name, provider: $provider, prompt: $prompt)';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'provider': provider.name,
      'prompt': prompt,
    };
  }

  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    return WorkflowStep(
      name: json['name'] as String,
      provider: Provider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => throw ArgumentError(
          'Unknown provider: ${json['provider']}',
        ),
      ),
      prompt: json['prompt'] as String,
    );
  }
}

class AIResponse {
  AIResponse({
    this.action,
    this.userAction,
    this.output,
    this.error,
  }) {
    // if all fields are null, put error message
    if (action == null &&
        userAction == null &&
        output == null &&
        error == null) {
      error = 'No response from AI';
    }
  }
  final String? action;
  final UserAction? userAction;
  final String? output;
  String? error;

  @override
  String toString() {
    return 'AIResponse(action: $action, userAction: $userAction, output: $output, error: $error)';
  }

  Map<String, dynamic> toJson() {
    return {
      if (action != null) 'action': action,
      if (userAction != null) 'userAction': userAction?.toJson(),
      if (output != null) 'output': output,
      if (error != null) 'error': error,
    };
  }

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      action: json['action'] as String?,
      userAction: json['userAction'] != null
          ? UserAction.fromJson(json['userAction'] as Map<String, dynamic>)
          : null,
      output: json['output'] as String?,
    );
  }
}

/// Shell command result
class ShellCommandResult {
  ShellCommandResult(
    this.pid,
    this.exitCode,
    this.stdout,
    this.stderr,
  );
  final int pid;
  final int exitCode;
  final String stdout;
  final String? stderr;

  @override
  String toString() {
    return 'ShellCommandResult(pid: $pid, exitCode: $exitCode, stdout: $stdout, stderr: $stderr)';
  }

  Map<String, dynamic> toJson() {
    return {
      'stdout': stdout,
      'stderr': stderr,
      'exitCode': exitCode,
      'pid': pid,
    };
  }

  factory ShellCommandResult.fromJson(Map<String, dynamic> json) {
    return ShellCommandResult(
      json['pid'] as int,
      json['exitCode'] as int,
      json['stdout'] as String,
      json['stderr'] as String?,
    );
  }
}

class UserAction {
  UserAction({
    required this.options,
    required this.question,
  });
  final List<String> options;
  final String question;

  @override
  String toString() {
    return 'UserAction(options: $options, question: $question)';
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options,
      'question': question,
    };
  }

  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      options: List<String>.from(json['options'] as List),
      question: json['question'] as String,
    );
  }
}

class WorkflowResult {
  WorkflowResult({
    required this.response,
    required this.success,
    this.error,
  });
  final AIResponse response;
  final bool success;
  final String? error;

  @override
  String toString() {
    return 'WorkflowResult(response: $response, success: $success, error: $error)';
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response.toJson(),
      'success': success,
      'error': error,
    };
  }

  factory WorkflowResult.fromJson(Map<String, dynamic> json) {
    return WorkflowResult(
      response: AIResponse.fromJson(json['response'] as Map<String, dynamic>),
      success: json['success'] as bool,
      error: json['error'] as String?,
    );
  }
}
