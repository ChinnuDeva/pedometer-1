import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_pedometer/features/speech_recognition/domain/entities/transcription.dart';
import 'package:word_pedometer/features/speech_recognition/domain/usecases/speech_recognition_usecases.dart';
import 'package:word_pedometer/core/usecases/usecase.dart';

/// Events for speech recognition
abstract class SpeechRecognitionEvent extends Equatable {
  const SpeechRecognitionEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSpeechRecognitionEvent extends SpeechRecognitionEvent {
  const InitializeSpeechRecognitionEvent();
}

class StartListeningEvent extends SpeechRecognitionEvent {
  const StartListeningEvent();
}

class StopListeningEvent extends SpeechRecognitionEvent {
  const StopListeningEvent();
}

class GetLastTranscriptionEvent extends SpeechRecognitionEvent {
  const GetLastTranscriptionEvent();
}

class TranscriptionReceivedEvent extends SpeechRecognitionEvent {
  final Transcription transcription;

  const TranscriptionReceivedEvent({required this.transcription});

  @override
  List<Object?> get props => [transcription];
}

class DisposeSpeechRecognitionEvent extends SpeechRecognitionEvent {
  const DisposeSpeechRecognitionEvent();
}

/// States for speech recognition
abstract class SpeechRecognitionState extends Equatable {
  const SpeechRecognitionState();

  @override
  List<Object?> get props => [];
}

class SpeechRecognitionInitial extends SpeechRecognitionState {
  const SpeechRecognitionInitial();
}

class SpeechRecognitionInitializing extends SpeechRecognitionState {
  const SpeechRecognitionInitializing();
}

class SpeechRecognitionInitialized extends SpeechRecognitionState {
  const SpeechRecognitionInitialized();
}

class SpeechRecognitionListening extends SpeechRecognitionState {
  final Transcription? currentTranscription;

  const SpeechRecognitionListening({this.currentTranscription});

  @override
  List<Object?> get props => [currentTranscription];
}

class SpeechRecognitionStopped extends SpeechRecognitionState {
  final Transcription? lastTranscription;

  const SpeechRecognitionStopped({this.lastTranscription});

  @override
  List<Object?> get props => [lastTranscription];
}

class SpeechRecognitionError extends SpeechRecognitionState {
  final String message;

  const SpeechRecognitionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TranscriptionReceived extends SpeechRecognitionState {
  final Transcription transcription;

  const TranscriptionReceived({required this.transcription});

  @override
  List<Object?> get props => [transcription];
}

/// BLoC for managing speech recognition state
class SpeechRecognitionBloc
    extends Bloc<SpeechRecognitionEvent, SpeechRecognitionState> {
  final InitializeSpeechRecognitionUseCase _initializeUseCase;
  final StartListeningUseCase _startListeningUseCase;
  final StopListeningUseCase _stopListeningUseCase;
  final GetLastTranscriptionUseCase _getLastTranscriptionUseCase;
  final DisposeSpeechRecognitionUseCase _disposeUseCase;

  StreamSubscription<Transcription>? _transcriptionSubscription;
  Transcription? _currentTranscription;

  SpeechRecognitionBloc({
    required InitializeSpeechRecognitionUseCase initializeUseCase,
    required StartListeningUseCase startListeningUseCase,
    required StopListeningUseCase stopListeningUseCase,
    required GetLastTranscriptionUseCase getLastTranscriptionUseCase,
    required DisposeSpeechRecognitionUseCase disposeUseCase,
  })  : _initializeUseCase = initializeUseCase,
        _startListeningUseCase = startListeningUseCase,
        _stopListeningUseCase = stopListeningUseCase,
        _getLastTranscriptionUseCase = getLastTranscriptionUseCase,
        _disposeUseCase = disposeUseCase,
        super(const SpeechRecognitionInitial()) {
    on<InitializeSpeechRecognitionEvent>(_onInitialize);
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<GetLastTranscriptionEvent>(_onGetLastTranscription);
    on<TranscriptionReceivedEvent>(_onTranscriptionReceived);
    on<DisposeSpeechRecognitionEvent>(_onDispose);
  }

  void listenToTranscriptionStream(Stream<Transcription> stream) {
    _transcriptionSubscription?.cancel();
    _transcriptionSubscription = stream.listen(
      (transcription) {
        _currentTranscription = transcription;
        add(TranscriptionReceivedEvent(transcription: transcription));
      },
      onError: (error) {
        add(TranscriptionReceivedEvent(
          transcription: Transcription(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: '',
            timestamp: DateTime.now(),
            confidence: 0,
            duration: Duration.zero,
          ),
        ));
      },
    );
  }

  Future<void> _onInitialize(
    InitializeSpeechRecognitionEvent event,
    Emitter<SpeechRecognitionState> emit,
  ) async {
    emit(const SpeechRecognitionInitializing());

    final result = await _initializeUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        SpeechRecognitionError(message: failure.message),
      ),
      (success) => emit(const SpeechRecognitionInitialized()),
    );
  }

  Future<void> _onStartListening(
    StartListeningEvent event,
    Emitter<SpeechRecognitionState> emit,
  ) async {
    _currentTranscription = null;
    final result = await _startListeningUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        SpeechRecognitionError(message: failure.message),
      ),
      (_) => emit(const SpeechRecognitionListening()),
    );
  }

  Future<void> _onStopListening(
    StopListeningEvent event,
    Emitter<SpeechRecognitionState> emit,
  ) async {
    final result = await _stopListeningUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        SpeechRecognitionError(message: failure.message),
      ),
      (_) => emit(SpeechRecognitionStopped(lastTranscription: _currentTranscription)),
    );
  }

  Future<void> _onGetLastTranscription(
    GetLastTranscriptionEvent event,
    Emitter<SpeechRecognitionState> emit,
  ) async {
    final result = await _getLastTranscriptionUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        SpeechRecognitionError(message: failure.message),
      ),
      (transcription) => emit(
        TranscriptionReceived(transcription: transcription),
      ),
    );
  }

  void _onTranscriptionReceived(
    TranscriptionReceivedEvent event,
    Emitter<SpeechRecognitionState> emit,
  ) {
    if (event.transcription.text.isNotEmpty) {
      emit(TranscriptionReceived(transcription: event.transcription));
    }
  }

  Future<void> _onDispose(
    DisposeSpeechRecognitionEvent event,
    Emitter<SpeechRecognitionState> emit,
  ) async {
    await _transcriptionSubscription?.cancel();
    await _disposeUseCase(const NoParams());
  }

  @override
  Future<void> close() {
    _transcriptionSubscription?.cancel();
    return super.close();
  }
}
