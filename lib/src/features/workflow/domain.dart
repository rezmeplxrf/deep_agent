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
    this.input,
  });
  final String name;
  final Provider provider;
  final String prompt;
  final String? input;

  @override
  String toString() {
    return 'WorkflowStep(name: $name, provider: $provider, prompt: $prompt, input: $input)';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'provider': provider.name,
      'prompt': prompt,
      if (input != null) 'input': input,
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
      input: json['input'] as String?,
    );
  }
  // copyWith
  WorkflowStep copyWith({
    String? name,
    Provider? provider,
    String? prompt,
    String? input,
  }) {
    return WorkflowStep(
      name: name ?? this.name,
      provider: provider ?? this.provider,
      prompt: prompt ?? this.prompt,
      input: input ?? this.input,
    );
  }
}

class AIResponse {
  AIResponse({
    this.userAction,
    this.output,
    this.error,
  }) {
    // if all fields are null, put error message
    if (userAction == null && output == null && error == null) {
      error = 'No response from AI';
    }
  }
  final UserAction? userAction;
  final String? output;
  String? error;

  @override
  String toString() {
    return 'AIResponse(userAction: $userAction, output: $output, error: $error)';
  }

  Map<String, dynamic> toJson() {
    return {
      if (userAction != null) 'userAction': userAction?.toJson(),
      if (output != null) 'output': output,
      if (error != null) 'error': error,
    };
  }

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
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
      if (stderr != null) 'stderr': stderr,
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
    required this.workflowName,
    required this.success,
    this.response,
    this.error,
  });
  final AIResponse? response;
  final String workflowName;
  final bool success;
  final String? error;

  @override
  String toString() {
    return 'WorkflowResult(workflowName: $workflowName, response: $response, success: $success, error: $error)';
  }

  Map<String, dynamic> toJson() {
    return {
      'workflowName': workflowName,
      'success': success,
      if (response != null) 'response': response?.toJson(),
      if (error != null) 'error': error,
    };
  }

  factory WorkflowResult.fromJson(Map<String, dynamic> json) {
    return WorkflowResult(
      workflowName: json['workflowName'] as String,
      response: json['response'] != null
          ? AIResponse.fromJson(json['response'] as Map<String, dynamic>)
          : null,
      success: json['success'] as bool,
      error: json['error'] as String?,
    );
  }
}
