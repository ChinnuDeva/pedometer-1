import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/grammar_mistake.dart';
import '../../domain/usecases/grammar_checker_usecases.dart';
import '../../../../core/usecases/usecase.dart';

/// Events for grammar checking
abstract class GrammarCheckerEvent extends Equatable {
  const GrammarCheckerEvent();

  @override
  List<Object?> get props => [];
}

class CheckGrammarEvent extends GrammarCheckerEvent {

  const CheckGrammarEvent({required this.text});
  final String text;

  @override
  List<Object?> get props => [text];
}

class GetGrammarRulesEvent extends GrammarCheckerEvent {
  const GetGrammarRulesEvent();
}

/// States for grammar checking
abstract class GrammarCheckerState extends Equatable {
  const GrammarCheckerState();

  @override
  List<Object?> get props => [];
}

class GrammarCheckerInitial extends GrammarCheckerState {
  const GrammarCheckerInitial();
}

class GrammarCheckerLoading extends GrammarCheckerState {
  const GrammarCheckerLoading();
}

class GrammarCheckerLoaded extends GrammarCheckerState {

  const GrammarCheckerLoaded({
    required this.mistakes,
    required this.accuracy,
  });
  final List<GrammarMistake> mistakes;
  final double accuracy;

  @override
  List<Object?> get props => [mistakes, accuracy];
}

class GrammarCheckerError extends GrammarCheckerState {

  const GrammarCheckerError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class GrammarRulesLoaded extends GrammarCheckerState {

  const GrammarRulesLoaded({required this.rules});
  final Map<String, dynamic> rules;

  @override
  List<Object?> get props => [rules];
}

/// BLoC for managing grammar checking state
class GrammarCheckerBloc
    extends Bloc<GrammarCheckerEvent, GrammarCheckerState> {

  GrammarCheckerBloc({
    required CheckGrammarUseCase checkGrammarUseCase,
    required GetGrammarRulesUseCase getGrammarRulesUseCase,
    required CalculateAccuracyUseCase calculateAccuracyUseCase,
  })  : _checkGrammarUseCase = checkGrammarUseCase,
        _getGrammarRulesUseCase = getGrammarRulesUseCase,
        _calculateAccuracyUseCase = calculateAccuracyUseCase,
        super(const GrammarCheckerInitial()) {
    on<CheckGrammarEvent>(_onCheckGrammar);
    on<GetGrammarRulesEvent>(_onGetGrammarRules);
  }
  final CheckGrammarUseCase _checkGrammarUseCase;
  final GetGrammarRulesUseCase _getGrammarRulesUseCase;
  final CalculateAccuracyUseCase _calculateAccuracyUseCase;

  Future<void> _onCheckGrammar(
    CheckGrammarEvent event,
    Emitter<GrammarCheckerState> emit,
  ) async {
    emit(const GrammarCheckerLoading());

    final result = await _checkGrammarUseCase(
      CheckGrammarParams(text: event.text),
    );

    await result.fold(
      (failure) async {
        emit(GrammarCheckerError(message: failure.message));
      },
      (mistakes) async {
        final accuracyResult = await _calculateAccuracyUseCase(
          CalculateAccuracyParams(text: event.text, mistakes: mistakes),
        );

        accuracyResult.fold(
          (failure) => emit(
            GrammarCheckerError(message: failure.message),
          ),
          (accuracy) => emit(
            GrammarCheckerLoaded(mistakes: mistakes, accuracy: accuracy),
          ),
        );
      },
    );
  }

  Future<void> _onGetGrammarRules(
    GetGrammarRulesEvent event,
    Emitter<GrammarCheckerState> emit,
  ) async {
    final result = await _getGrammarRulesUseCase(const NoParams());

    result.fold(
      (failure) => emit(GrammarCheckerError(message: failure.message)),
      (rules) => emit(GrammarRulesLoaded(rules: rules)),
    );
  }
}
