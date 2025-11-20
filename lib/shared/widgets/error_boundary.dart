import 'package:flutter/material.dart';

import '../../core/errors/exceptions.dart';

/// A widget that catches and displays errors gracefully
///
/// This widget acts as an error boundary, catching errors from child widgets
/// and displaying a user-friendly error UI instead of crashing the app.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(GameException error)? errorBuilder;
  final void Function(GameException error)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  GameException? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          DefaultErrorWidget(
            error: _error!,
            onRetry: () {
              setState(() {
                _error = null;
              });
            },
          );
    }

    return ErrorCatcher(
      onError: (error) {
        setState(() {
          _error = error;
        });
        widget.onError?.call(error);
      },
      child: widget.child,
    );
  }
}

/// Widget that catches errors from its child
class ErrorCatcher extends StatelessWidget {
  final Widget child;
  final void Function(GameException error) onError;

  const ErrorCatcher({super.key, required this.child, required this.onError});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Default error widget displayed when an error occurs
class DefaultErrorWidget extends StatelessWidget {
  final GameException error;
  final VoidCallback? onRetry;

  const DefaultErrorWidget({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon based on severity
            Icon(
              _getIconForSeverity(error.severity),
              size: 80,
              color: _getColorForSeverity(error.severity),
            ),
            const SizedBox(height: 24),

            // Error title
            Text(
              _getTitleForSeverity(error.severity),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // User-friendly error message
            Text(
              _getUserFriendlyMessage(error),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Retry button (if recoverable)
            if (_isRecoverable(error.severity) && onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info_outline;
      case ErrorSeverity.medium:
        return Icons.warning_amber_rounded;
      case ErrorSeverity.high:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getColorForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  String _getTitleForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 'Oops!';
      case ErrorSeverity.medium:
        return 'Something went wrong';
      case ErrorSeverity.high:
        return 'We hit a snag';
      case ErrorSeverity.critical:
        return 'Critical Error';
    }
  }

  String _getUserFriendlyMessage(GameException error) {
    // Convert technical error messages to child-friendly messages
    switch (error.category) {
      case ErrorCategory.storage:
        if (error.severity == ErrorSeverity.critical) {
          return 'We had trouble saving your progress. Please restart the game.';
        }
        return 'Having trouble saving your progress. Let\'s try that again!';

      case ErrorCategory.gameLogic:
        return 'Something unexpected happened in the game. Let\'s try again!';

      case ErrorCategory.assets:
        return 'We couldn\'t load some game content. Let\'s try again!';

      case ErrorCategory.input:
        return 'We didn\'t understand that. Please try again!';

      case ErrorCategory.network:
        return 'We couldn\'t connect. Please check your internet!';
    }
  }

  bool _isRecoverable(ErrorSeverity severity) {
    return severity != ErrorSeverity.critical;
  }
}

/// A simple error display widget for inline errors
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: onRetry,
                color: Colors.red.shade700,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.red.shade700, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A loading state widget with error fallback
class LoadingWithError<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget Function(Object? error)? errorBuilder;

  const LoadingWithError({
    super.key,
    required this.snapshot,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      if (errorBuilder != null) {
        return errorBuilder!(snapshot.error);
      }

      final error = snapshot.error;
      if (error is GameException) {
        return DefaultErrorWidget(error: error);
      }

      return InlineErrorWidget(
        message: 'Something went wrong. Please try again!',
      );
    }

    if (snapshot.hasData) {
      return builder(snapshot.data as T);
    }

    return loadingWidget ?? const Center(child: CircularProgressIndicator());
  }
}
