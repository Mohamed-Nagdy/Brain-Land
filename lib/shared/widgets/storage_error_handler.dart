import 'package:flutter/material.dart';

import '../../core/errors/exceptions.dart';
import 'error_boundary.dart';

/// A specialized error handler for storage operations
///
/// This widget wraps storage-dependent UI and provides user-friendly
/// error messages and retry functionality when storage operations fail.
class StorageErrorHandler extends StatefulWidget {
  final Future<void> Function() operation;
  final Widget Function(BuildContext context) builder;
  final Widget? loadingWidget;
  final void Function(StorageException error)? onError;

  const StorageErrorHandler({
    super.key,
    required this.operation,
    required this.builder,
    this.loadingWidget,
    this.onError,
  });

  @override
  State<StorageErrorHandler> createState() => _StorageErrorHandlerState();
}

class _StorageErrorHandlerState extends State<StorageErrorHandler> {
  bool _isLoading = true;
  StorageException? _error;

  @override
  void initState() {
    super.initState();
    _executeOperation();
  }

  Future<void> _executeOperation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.operation();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on StorageException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
        widget.onError?.call(e);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = StorageException(
            message: 'Unexpected error: $e',
            severity: ErrorSeverity.high,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return DefaultErrorWidget(error: _error!, onRetry: _executeOperation);
    }

    return widget.builder(context);
  }
}

/// A widget that shows a notification banner for storage errors
class StorageErrorNotification extends StatelessWidget {
  final StorageException error;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const StorageErrorNotification({
    super.key,
    required this.error,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(error.severity),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(_getIcon(error.severity), color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTitle(error.severity),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMessage(error),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: onRetry,
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onDismiss,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue.shade600;
      case ErrorSeverity.medium:
        return Colors.orange.shade600;
      case ErrorSeverity.high:
        return Colors.red.shade600;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  IconData _getIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info;
      case ErrorSeverity.medium:
        return Icons.warning;
      case ErrorSeverity.high:
      case ErrorSeverity.critical:
        return Icons.error;
    }
  }

  String _getTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 'Notice';
      case ErrorSeverity.medium:
        return 'Having trouble...';
      case ErrorSeverity.high:
        return 'Error saving progress';
      case ErrorSeverity.critical:
        return 'Critical Error';
    }
  }

  String _getMessage(StorageException error) {
    if (error.severity == ErrorSeverity.critical) {
      return 'We couldn\'t save your progress. Please restart the game.';
    }
    return 'Trying again... Your progress is safe!';
  }
}

/// Shows a storage error notification as a snackbar
void showStorageErrorSnackBar(
  BuildContext context,
  StorageException error, {
  VoidCallback? onRetry,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            error.severity == ErrorSeverity.critical
                ? Icons.error
                : Icons.warning,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.severity == ErrorSeverity.critical
                  ? 'Critical error saving progress'
                  : 'Having trouble saving. Trying again...',
            ),
          ),
        ],
      ),
      backgroundColor: error.severity == ErrorSeverity.critical
          ? Colors.red.shade900
          : Colors.orange.shade700,
      duration: const Duration(seconds: 4),
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    ),
  );
}
