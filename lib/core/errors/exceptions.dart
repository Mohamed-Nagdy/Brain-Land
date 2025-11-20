/// Custom exceptions for BrainLand game
library;

/// Base exception class for all game errors
class GameException implements Exception {
  final String message;
  final ErrorSeverity severity;
  final ErrorCategory category;
  final StackTrace? stackTrace;

  const GameException({
    required this.message,
    required this.severity,
    required this.category,
    this.stackTrace,
  });

  @override
  String toString() =>
      'GameException: $message (${severity.name}, ${category.name})';
}

/// Error severity levels
enum ErrorSeverity {
  low, // Graceful degradation, no user impact
  medium, // User notification, recoverable
  high, // Requires user action or restart
  critical, // Data loss risk, immediate action needed
}

/// Error categories
enum ErrorCategory { storage, gameLogic, assets, input, network }

/// Storage-related exceptions
class StorageException extends GameException {
  const StorageException({
    required super.message,
    super.severity = ErrorSeverity.medium,
    super.stackTrace,
  }) : super(category: ErrorCategory.storage);
}

/// Game logic exceptions
class GameLogicException extends GameException {
  const GameLogicException({
    required super.message,
    super.severity = ErrorSeverity.medium,
    super.stackTrace,
  }) : super(category: ErrorCategory.gameLogic);
}

/// Asset loading exceptions
class AssetException extends GameException {
  const AssetException({
    required super.message,
    super.severity = ErrorSeverity.low,
    super.stackTrace,
  }) : super(category: ErrorCategory.assets);
}

/// Input validation exceptions
class InputException extends GameException {
  const InputException({
    required super.message,
    super.severity = ErrorSeverity.low,
    super.stackTrace,
  }) : super(category: ErrorCategory.input);
}

/// Network-related exceptions (for future use)
class NetworkException extends GameException {
  const NetworkException({
    required super.message,
    super.severity = ErrorSeverity.medium,
    super.stackTrace,
  }) : super(category: ErrorCategory.network);
}
