/// Background Service Status Entity
enum BackgroundServiceStatus {
  stopped,
  starting,
  running,
  paused,
  stopping,
  error,
}

/// Background Service State Entity
class BackgroundServiceState {

  BackgroundServiceState({
    required this.status,
    required this.startTime,
    required this.elapsedTime,
    this.errorMessage,
  });
  final BackgroundServiceStatus status;
  final String? errorMessage;
  final DateTime startTime;
  final Duration elapsedTime;

  BackgroundServiceState copyWith({
    BackgroundServiceStatus? status,
    String? errorMessage,
    DateTime? startTime,
    Duration? elapsedTime,
  }) => BackgroundServiceState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );

  @override
  String toString() =>
      'BackgroundServiceState(status: $status, '
      'elapsedTime: $elapsedTime)';
}
