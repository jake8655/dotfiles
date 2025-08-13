# Agent Development Guidelines

## Naming Conventions

- Use descriptive names that convey purpose
- Variables/functions: camelCase
- Classes/Types: PascalCase
- Constants: UPPER_SNAKE_CASE
- Private properties: _prefixWithUnderscore
- File names: kebab-case

## Formatting

- Use 2 spaces for indentation
- Place opening brace on same line
- Add spaces around operators and after commas
- Keep lines under 100 characters

## Error Handling

- Use descriptive error messages
- Catch specific error types
- Add context to thrown errors

## Documentation

- When the user requests code examples, setup or configuration steps,
or library/API documentation, use the context7 tool

## IMPORTANT

- DO NOT use `else` statements unless necessary
- DO NOT use `try`/`catch` if it can be avoided
- DO NOT use the `any` type unless absolutely necessary
- AVOID `let` statements
- PREFER single word variable names where possible
- When programming in React, DO NOT use `memo`, `useMemo`, or `useCallback` because they are not needed with React Compiler
- You DO NOT need to worry about function recreation on every render in useEffect dependency arrays because React Compiler handles this automatically
- AVOID using index as a key in React lists
- ALWAYS use `bun` and `bunx` instead of `npm` or `yarn`
- PREFER default exports for single exports or main components in react files
