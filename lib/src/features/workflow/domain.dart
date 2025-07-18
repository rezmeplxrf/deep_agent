// ignore_for_file: sort_constructors_first, constant_identifier_names

enum Provider { claudeCode, geminiCli, llmApi }

enum AIRole { Architect, Developer, LeadDeveloper }

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
    required this.role,
    this.input,
  });
  final String name;
  final Provider provider;
  final String prompt;
  final String? input;
  final AIRole role;

  @override
  String toString() {
    return 'WorkflowStep(name: $name, provider: $provider, prompt: $prompt, input: $input, role: $role)';
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
      role: AIRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => throw ArgumentError(
          'Unknown role: ${json['role']}',
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
      role: role,
    );
  }
}

class AIResponse {
  AIResponse({
    this.askUser,
    this.output,
    this.askAI,
    this.error,
  }) {
    // if all fields are null, put error message
    if (askUser == null && output == null && error == null && askAI == null) {
      error = 'No response from AI';
    }
  }
  final UserPrompt? askUser;
  final String? askAI;
  final String? output;
  String? error;

  @override
  String toString() {
    return 'AIResponse(userAction: $askUser, output: $output, error: $error, askAI: $askAI)';
  }

  Map<String, dynamic> toJson() {
    return {
      if (askUser != null) 'userAction': askUser?.toJson(),
      if (output != null) 'output': output,
      if (error != null) 'error': error,
      if (askAI != null) 'askAI': askAI,
    };
  }

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      askUser: json['askUser'] != null
          ? UserPrompt.fromJson(json['askUser'] as Map<String, dynamic>)
          : null,
      output: json['output'] as String?,
      error: json['error'] as String?,
      askAI: json['askAI'] as String?,
    );
  }
}

class UserPrompt {
  UserPrompt({
    required this.options,
    required this.question,
  });
  final List<String> options;
  final String question;

  @override
  String toString() {
    return 'UserPrompt(options: $options, question: $question)';
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options,
      'question': question,
    };
  }

  factory UserPrompt.fromJson(Map<String, dynamic> json) {
    return UserPrompt(
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
