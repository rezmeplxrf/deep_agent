const developerCommandContent = '''
# Develop Command

Execute specific tasks from the approved task list.

## Usage
```
/develop <task-id> [<feature-name>]
```

## Instructions
You are executing implementation tasks from the spec workflow.

1. **Prerequisites**
   - Ensure task.md exists and is approved
   - Load requirements.md, design.md, and task.md for context
   - Identify the specific task to execute

2. **Task Execution**
   - Focus on ONE task at a time
   - If task has sub-tasks, start with those
   - Follow the implementation details from design.md
   - Verify against requirements specified in the task

3. **Implementation Guidelines**
   - Write clean, maintainable code
   - Follow existing code patterns and conventions
   - Include appropriate error handling
   - Add unit tests where specified
   - Avoid unnecessary comments or print statements
   - Document complex logic

4. **Validation**
   - Verify implementation meets acceptance criteria
   - Run tests if they exist
   - Check for lint/type errors
   - Ensure integration with existing code

5. **Completion**
   - Mark task as complete in task.md
   - Update execution log

## Task Selection
If no task-id specified:
- Look at task.md for the spec
- Recommend the next pending task
- Ask user to confirm before proceeding

## Examples
```
/develop 1 user-authentication
/develop 2.1 user-authentication
```

## Important Rules
- Only execute ONE task at a time
- Always stop after completing a task
- Wait for user approval before continuing
- Never skip tasks or jump ahead
''';
