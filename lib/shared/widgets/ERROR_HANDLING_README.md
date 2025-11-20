# Error Handling in BrainLand

This document explains how to use the error handling widgets and utilities in the BrainLand application.

## Overview

BrainLand implements a comprehensive error handling system with:
- **Error Boundaries**: Catch and display errors gracefully
- **Storage Error Handlers**: Specialized handling for storage operations
- **Inline Error Widgets**: Display errors within forms and UI components
- **Error Notifications**: Show temporary error messages to users
- **Retry Mechanisms**: Allow users to retry failed operations

## Components

### 1. ErrorBoundary

Wraps widgets to catch and handle errors gracefully.

```dart
ErrorBoundary(
  onError: (error) {
    // Log or report error
    print('Error: ${error.message}');
  },
  child: YourWidget(),
)
```

### 2. StorageErrorHandler

Specialized handler for storage operations with automatic retry.

```dart
StorageErrorHandler(
  operation: () async {
    await storage.save(
      boxName: 'progress',
      key: 'player_data',
      value: playerData,
    );
  },
  builder: (context) => YourSuccessWidget(),
  onError: (error) {
    showStorageErrorSnackBar(context, error);
  },
)
```

### 3. InlineErrorWidget

Display errors inline within your UI.

```dart
if (errorMessage != null)
  InlineErrorWidget(
    message: errorMessage,
    onRetry: () => retryOperation(),
    compact: true, // Use compact mode for forms
  )
```

### 4. LoadingWithError

Handle async operations with loading and error states.

```dart
FutureBuilder<Data>(
  future: loadData(),
  builder: (context, snapshot) {
    return LoadingWithError<Data>(
      snapshot: snapshot,
      builder: (data) => DataWidget(data: data),
      errorBuilder: (error) => CustomErrorWidget(error),
    );
  },
)
```

### 5. Storage Error Notifications

Show temporary error notifications.

```dart
try {
  await storage.save(...);
} on StorageException catch (e) {
  showStorageErrorSnackBar(context, e, onRetry: () => retry());
}
```

## Error Severity Levels

The system uses four severity levels:

1. **Low**: Minor issues, graceful degradation
   - Icon: Info
   - Color: Blue
   - Example: Asset loading failed, using placeholder

2. **Medium**: Recoverable errors requiring user notification
   - Icon: Warning
   - Color: Orange
   - Example: Save failed, retrying automatically

3. **High**: Errors requiring user action
   - Icon: Error
   - Color: Red
   - Example: Save failed after retries, user must retry

4. **Critical**: Severe errors, potential data loss
   - Icon: Dangerous
   - Color: Dark Red
   - Example: Storage corruption, app restart needed

## Error Categories

Errors are categorized by type:

- **Storage**: Data persistence issues
- **GameLogic**: Game state or logic errors
- **Assets**: Resource loading failures
- **Input**: User input validation errors
- **Network**: Connectivity issues (future use)

## Best Practices

### 1. Wrap Screens with ErrorBoundary

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: Scaffold(
        // Your screen content
      ),
    );
  }
}
```

### 2. Use StorageErrorHandler for Critical Operations

```dart
// When saving player progress
StorageErrorHandler(
  operation: () => saveProgress(),
  builder: (context) => SuccessScreen(),
  onError: (error) => logError(error),
)
```

### 3. Show User-Friendly Messages

Always convert technical errors to child-friendly messages:

```dart
// Bad
"Failed to write to Hive box: NullPointerException"

// Good
"Having trouble saving your progress. Let's try that again!"
```

### 4. Implement Retry Logic

Always provide retry options for recoverable errors:

```dart
DefaultErrorWidget(
  error: error,
  onRetry: () => retryOperation(),
)
```

### 5. Log Errors for Debugging

```dart
ErrorBoundary(
  onError: (error) {
    // Log to console in debug mode
    debugPrint('Error: ${error.message}');
    
    // Send to analytics in production
    AnalyticsService.logError(error);
  },
  child: YourWidget(),
)
```

## Storage Service Integration

The `StorageService` includes built-in retry mechanisms:

```dart
// Automatic retry with exponential backoff
await storage.save(
  boxName: 'progress',
  key: 'player_data',
  value: data,
  maxRetries: 3, // Default is 3
  onRetry: (attempt, max) {
    print('Retry attempt $attempt of $max');
  },
);
```

## Testing Error Handling

Test error scenarios in your tests:

```dart
test('handles storage errors gracefully', () async {
  // Simulate storage error
  when(() => mockStorage.save(...))
    .thenThrow(StorageException(
      message: 'Save failed',
      severity: ErrorSeverity.medium,
    ));
  
  // Verify error is handled
  await tester.pumpWidget(YourWidget());
  expect(find.byType(DefaultErrorWidget), findsOneWidget);
});
```

## Examples

See `error_boundary_example.dart` for complete working examples of:
- Screen-level error boundaries
- Storage error handling
- Form validation errors
- Async operation errors
- Custom error widgets
- Error notifications

## Child-Friendly Error Messages

Always use encouraging, non-technical language:

✅ "Oops! Let's try that again!"
✅ "Having trouble saving. Don't worry, we'll fix it!"
✅ "Something went wrong. Let's give it another try!"

❌ "NullPointerException in storage service"
❌ "Failed to serialize data to Hive"
❌ "Critical error: 0x8000FFFF"

## Accessibility

Error widgets include:
- Clear visual indicators (icons, colors)
- Descriptive text for screen readers
- Large, easy-to-tap retry buttons
- High contrast for visibility

## Future Enhancements

Planned improvements:
- Offline error queue for network operations
- Error reporting to analytics
- Automatic error recovery strategies
- Parent notification for critical errors
