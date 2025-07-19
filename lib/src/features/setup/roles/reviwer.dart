const reviewerCommandContent = '''
# Review Command

Review the implementation of tasks in the spec workflow.

## Usage
```
/review <task-id> [<feature-name>]
```

## Instructions
You are reviewing/modifying implementation tasks from the spec workflow.
1. **Prerequisites**
   - Ensure task.md exists and is approved
   - Load requirements.md, design.md, and task.md for context
   - Identify the specific task to review
2. **Task Review**
   - Focus on ONE task at a time
   - If task has sub-tasks, review those first
   - Follow the implementation details from design.md
   - Verify against requirements specified in the task   
3. **Run Tests**
   - Run tests if they exist
   - Check for lint/type errors
   - Ensure integration with existing code


## Examples
```
/review 1 user-authentication
/review 2.1 user-authentication
```

## Important Rules
- Only review ONE task at a time
- Ensure the implementation meets the requirements
- Validate against the design and requirements
- Make necessary modifications
- Don't skip reviewing any tasks
- Don't make unnecessary changes
''';
