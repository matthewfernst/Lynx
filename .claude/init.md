# Lynx Project Instructions

## Code Formatting

**IMPORTANT**: After making changes to Swift files, you must run `swift-format` to maintain code consistency.

### When to Format
- After editing any `.swift` file
- Before completing a task that involves Swift code changes
- Before creating commits that include Swift files

### How to Format

Run the following command to format all Swift files in the project:

```bash
find Lynx-SwiftUI -name "*.swift" -exec xcrun swift-format -i {} \;
```

### Example Workflow

1. Make changes to Swift files using Edit/Write tools
2. Run the format command above
3. Verify changes compiled successfully (if needed)
4. Complete the task

## Project Structure

### iOS App (Lynx-SwiftUI/)
- `Views/` - SwiftUI view components
- `ViewModels/` - Business logic and state management
- `Models/` - Data models
- `Apollo/` - GraphQL configuration
- `Utils/` - Extensions and helpers

### Backend API (lynx-api/)
- TypeScript/Node.js serverless backend
- See `lynx-api/README.md` for details

## Best Practices

1. **Always read before editing**: Use Read tool before modifying files
2. **Format Swift code**: Run swift-format after Swift changes
3. **Test builds**: Run xcodebuild to verify compilation when appropriate
4. **Follow existing patterns**: Match the coding style of surrounding code
5. **Keep it simple**: Avoid over-engineering or unnecessary abstractions
