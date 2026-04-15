import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transcription.dart';
import '../repositories/speech_recognition_repository.dart';

/// Initialize speech recognition use case
class InitializeSpeechRecognitionUseCase
    extends UseCase<bool, NoParams> {

  InitializeSpeechRecognitionUseCase({
    required SpeechRecognitionRepository repository,
  }) : _repository = repository;
  final SpeechRecognitionRepository _repository;

  @override
  Future<Result<bool, Failure>> call(NoParams params) =>
      _repository.initialize();
}

/// Start listening use case
class StartListeningUseCase extends UseCase<void, NoParams> {

  StartListeningUseCase({
    required SpeechRecognitionRepository repository,
  }) : _repository = repository;
  final SpeechRecognitionRepository _repository;

  @override
  Future<Result<void, Failure>> call(NoParams params) =>
      _repository.startListening();
}

/// Stop listening use case
class StopListeningUseCase extends UseCase<void, NoParams> {

  StopListeningUseCase({
    required SpeechRecognitionRepository repository,
  }) : _repository = repository;
  final SpeechRecognitionRepository _repository;

  @override
  Future<Result<void, Failure>> call(NoParams params) =>
      _repository.stopListening();
}

/// Get last transcription use case
class GetLastTranscriptionUseCase
    extends UseCase<Transcription, NoParams> {

  GetLastTranscriptionUseCase({
    required SpeechRecognitionRepository repository,
  }) : _repository = repository;
  final SpeechRecognitionRepository _repository;

  @override
  Future<Result<Transcription, Failure>> call(NoParams params) =>
      _repository.getLastTranscription();
}

/// Dispose speech recognition use case
class DisposeSpeechRecognitionUseCase extends UseCase<void, NoParams> {

  DisposeSpeechRecognitionUseCase({
    required SpeechRecognitionRepository repository,
  }) : _repository = repository;
  final SpeechRecognitionRepository _repository;

  @override
  Future<Result<void, Failure>> call(NoParams params) =>
      _repository.dispose();
}
