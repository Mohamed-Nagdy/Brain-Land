/// Example usage of error boundaries and error handling widgets
///
/// This file demonstrates how to use the error handling widgets
/// throughout the BrainLand application.
library;

import 'package:flutter/material.dart';

import '../../core/errors/exceptions.dart';
import '../../shared/services/storage_service.dart';
import 'error_boundary.dart';
import 'storage_error_handler.dart';

/// Example 1: Wrapping a screen with ErrorBoundary
class ExampleScreenWithErrorBoundary extends StatelessWidget {
  const ExampleScreenWithErrorBoundary({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (error) {
        // Log error or send to analytics
        debugPrint('Error caught: ${error.message}');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Example Screen')),
        body: const ExampleContent(),
      ),
    );
  }
}

class ExampleContent extends StatelessWidget {
  const ExampleContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Content that might throw errors'));
  }
}

/// Example 2: Using StorageErrorHandler for storage operations
class ExampleStorageScreen extends StatelessWidget {
  const ExampleStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Example')),
      body: StorageErrorHandler(
        operation: () async {
          // Perform storage operation
          final storage = StorageService.instance;
          await storage.save(
            boxName: 'example_box',
            key: 'example_key',
            value: {'data': 'example'},
          );
        },
        builder: (context) {
          return const Center(
            child: Text('Storage operation completed successfully!'),
          );
        },
        onError: (error) {
          // Show notification to user
          showStorageErrorSnackBar(context, error);
        },
      ),
    );
  }
}

/// Example 3: Using InlineErrorWidget for form validation
class ExampleFormWithInlineError extends StatefulWidget {
  const ExampleFormWithInlineError({super.key});

  @override
  State<ExampleFormWithInlineError> createState() =>
      _ExampleFormWithInlineErrorState();
}

class _ExampleFormWithInlineErrorState
    extends State<ExampleFormWithInlineError> {
  String? _errorMessage;

  void _validateAndSubmit() {
    setState(() {
      _errorMessage = 'Please enter a valid name';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              InlineErrorWidget(
                message: _errorMessage!,
                onRetry: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
                compact: true,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _validateAndSubmit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 4: Using LoadingWithError for async operations
class ExampleAsyncScreen extends StatefulWidget {
  const ExampleAsyncScreen({super.key});

  @override
  State<ExampleAsyncScreen> createState() => _ExampleAsyncScreenState();
}

class _ExampleAsyncScreenState extends State<ExampleAsyncScreen> {
  late Future<String> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<String> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate potential error
    // throw StorageException(
    //   message: 'Failed to load data',
    //   severity: ErrorSeverity.medium,
    // );
    return 'Data loaded successfully!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async Example')),
      body: FutureBuilder<String>(
        future: _dataFuture,
        builder: (context, snapshot) {
          return LoadingWithError<String>(
            snapshot: snapshot,
            builder: (data) {
              return Center(child: Text(data));
            },
            errorBuilder: (error) {
              if (error is StorageException) {
                return DefaultErrorWidget(
                  error: error,
                  onRetry: () {
                    setState(() {
                      _dataFuture = _loadData();
                    });
                  },
                );
              }
              return InlineErrorWidget(
                message: 'Something went wrong',
                onRetry: () {
                  setState(() {
                    _dataFuture = _loadData();
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Example 5: Showing storage error notification
class ExampleNotificationScreen extends StatelessWidget {
  const ExampleNotificationScreen({super.key});

  void _simulateStorageError(BuildContext context) {
    final error = StorageException(
      message: 'Failed to save progress',
      severity: ErrorSeverity.medium,
    );

    showStorageErrorSnackBar(
      context,
      error,
      onRetry: () {
        // Retry the operation
        debugPrint('Retrying storage operation...');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _simulateStorageError(context),
          child: const Text('Simulate Storage Error'),
        ),
      ),
    );
  }
}

/// Example 6: Custom error widget for specific use case
class CustomGameErrorWidget extends StatelessWidget {
  final GameException error;
  final VoidCallback onRetry;

  const CustomGameErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade100, Colors.blue.shade100],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Friendly character illustration
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 100,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),

            // Child-friendly message
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Don\'t worry, let\'s try that again!',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.purple.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Colorful retry button
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
