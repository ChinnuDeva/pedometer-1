/// Base class for all application failures
abstract class Failure {
  final String message;

  Failure({required this.message});
}

class SpeechRecognitionFailure extends Failure {
  SpeechRecognitionFailure({required String message})
      : super(message: message);
}

class GrammarCheckingFailure extends Failure {
  GrammarCheckingFailure({required String message})
      : super(message: message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure({required String message}) : super(message: message);
}

class PermissionFailure extends Failure {
  PermissionFailure({required String message}) : super(message: message);
}

class AuthFailure extends Failure {
  AuthFailure({required String message}) : super(message: message);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({required String message}) : super(message: message);
}
