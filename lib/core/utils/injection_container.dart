import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:word_pedometer/core/services/auth_service.dart';
import 'package:word_pedometer/core/services/conversational_phrase_database.dart';
import 'package:word_pedometer/core/services/database_service.dart';
import 'package:word_pedometer/core/services/english_fluency_rules.dart';
import 'package:word_pedometer/core/services/firebase_seed_service.dart';
import 'package:word_pedometer/core/services/grammar_checker_service.dart';
import 'package:word_pedometer/core/services/grammar_rules_engine.dart';
import 'package:word_pedometer/core/services/natural_language_validator.dart';
import 'package:word_pedometer/core/services/permission_service.dart';
import 'package:word_pedometer/core/services/speech_recognition_service.dart';
import 'package:word_pedometer/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:word_pedometer/features/authentication/domain/repositories/auth_repository.dart';
import 'package:word_pedometer/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:word_pedometer/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:word_pedometer/features/grammar_checker/data/datasources/grammar_checker_local_data_source.dart';
import 'package:word_pedometer/features/grammar_checker/data/repositories/grammar_checker_repository_impl.dart';
import 'package:word_pedometer/features/grammar_checker/domain/repositories/grammar_checker_repository.dart';
import 'package:word_pedometer/features/speech_recognition/data/datasources/speech_recognition_local_data_source.dart';
import 'package:word_pedometer/features/speech_recognition/data/repositories/speech_recognition_repository_impl.dart';
import 'package:word_pedometer/features/speech_recognition/domain/repositories/speech_recognition_repository.dart';
import 'package:word_pedometer/features/speech_recognition/domain/usecases/speech_recognition_usecases.dart';
import 'package:word_pedometer/features/speech_recognition/presentation/bloc/speech_recognition_bloc.dart';
import 'package:word_pedometer/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:word_pedometer/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:word_pedometer/features/analytics/domain/usecases/analytics_usecases.dart';
import 'package:word_pedometer/features/analytics/presentation/bloc/analytics_bloc.dart';

final getIt = GetIt.instance;

/// Configure dependency injection for the application
void setupInjectionContainer() {
  // Logger
  getIt.registerSingleton<Logger>(
    Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    ),
  );

  // ==================== CORE SERVICES ====================

  // Database Service
  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );

  // Permission Service
  getIt.registerSingleton<PermissionService>(
    PermissionService(),
  );

  // Speech Recognition Service
  getIt.registerSingleton<SpeechRecognitionService>(
    SpeechRecognitionService(),
  );

  // Grammar Rules Engine
  getIt.registerSingleton<GrammarRulesEngine>(
    GrammarRulesEngine(),
  );

  // Natural Language Validation Services
  getIt.registerSingleton<ConversationalPhraseDatabase>(
    ConversationalPhraseDatabase(),
  );

  getIt.registerSingleton<EnglishFluencyRules>(
    EnglishFluencyRules(),
  );

  getIt.registerSingleton<NaturalLanguageValidator>(
    NaturalLanguageValidator(
      phraseDatabase: getIt<ConversationalPhraseDatabase>(),
      fluencyRules: getIt<EnglishFluencyRules>(),
    ),
  );

  // Grammar Checker Service
  getIt.registerSingleton<GrammarCheckerService>(
    GrammarCheckerService(
      engine: getIt<GrammarRulesEngine>(),
      nlValidator: getIt<NaturalLanguageValidator>(),
    ),
  );

  // Auth Service
  getIt.registerSingleton<AuthService>(
    AuthService(),
  );

  // Firebase Seed Service
  getIt.registerSingleton<FirebaseSeedService>(
    FirebaseSeedService(),
  );

  // Data sources
  getIt.registerSingleton<SpeechRecognitionDataSource>(
    SpeechRecognitionDataSourceImpl(
      speechToText: stt.SpeechToText(),
    ),
  );

  // Repositories
  getIt.registerSingleton<SpeechRecognitionRepository>(
    SpeechRecognitionRepositoryImpl(
      dataSource: getIt<SpeechRecognitionDataSource>(),
    ),
  );

  // Use cases
  getIt.registerSingleton<InitializeSpeechRecognitionUseCase>(
    InitializeSpeechRecognitionUseCase(
      repository: getIt<SpeechRecognitionRepository>(),
    ),
  );

  getIt.registerSingleton<StartListeningUseCase>(
    StartListeningUseCase(
      repository: getIt<SpeechRecognitionRepository>(),
    ),
  );

  getIt.registerSingleton<StopListeningUseCase>(
    StopListeningUseCase(
      repository: getIt<SpeechRecognitionRepository>(),
    ),
  );

  getIt.registerSingleton<GetLastTranscriptionUseCase>(
    GetLastTranscriptionUseCase(
      repository: getIt<SpeechRecognitionRepository>(),
    ),
  );

  getIt.registerSingleton<DisposeSpeechRecognitionUseCase>(
    DisposeSpeechRecognitionUseCase(
      repository: getIt<SpeechRecognitionRepository>(),
    ),
  );

  // BLoCs
  getIt.registerSingleton<SpeechRecognitionBloc>(
    SpeechRecognitionBloc(
      initializeUseCase: getIt<InitializeSpeechRecognitionUseCase>(),
      startListeningUseCase: getIt<StartListeningUseCase>(),
      stopListeningUseCase: getIt<StopListeningUseCase>(),
      getLastTranscriptionUseCase: getIt<GetLastTranscriptionUseCase>(),
      disposeUseCase: getIt<DisposeSpeechRecognitionUseCase>(),
    ),
  );

  // ==================== AUTHENTICATION ====================

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      authService: getIt<AuthService>(),
    ),
  );

  // Use cases
  getIt.registerSingleton<SignInWithGoogleUseCase>(
    SignInWithGoogleUseCase(
      repository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerSingleton<SignOutUseCase>(
    SignOutUseCase(
      repository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(
      repository: getIt<AuthRepository>(),
    ),
  );

  // BLoCs
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // ==================== GRAMMAR CHECKER ====================

  // Data sources
  getIt.registerSingleton<GrammarCheckerDataSource>(
    GrammarCheckerDataSourceImpl(),
  );

  // Repositories
  getIt.registerSingleton<GrammarCheckerRepository>(
    GrammarCheckerRepositoryImpl(
      dataSource: getIt<GrammarCheckerDataSource>(),
    ),
  );

  // TODO: Register grammar checker use cases
  // TODO: Register grammar checker BLoCs

  // ==================== ANALYTICS ====================

  // Repositories
  getIt.registerSingleton<AnalyticsRepository>(
    AnalyticsRepositoryImpl(
      databaseService: getIt<DatabaseService>(),
    ),
  );

  // Use cases
  getIt.registerSingleton<GetDailyReportUseCase>(
    GetDailyReportUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerSingleton<GetWeeklyReportUseCase>(
    GetWeeklyReportUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerSingleton<GetMonthlyReportUseCase>(
    GetMonthlyReportUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerSingleton<GetAccuracyTrendUseCase>(
    GetAccuracyTrendUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerSingleton<GetErrorPatternsUseCase>(
    GetErrorPatternsUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerSingleton<GetProjectedImprovementUseCase>(
    GetProjectedImprovementUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerSingleton<GetPerformanceComparisonUseCase>(
    GetPerformanceComparisonUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerSingleton<GetOverallStatisticsUseCase>(
    GetOverallStatisticsUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  // BLoCs
  getIt.registerSingleton<AnalyticsBloc>(
    AnalyticsBloc(
      getDailyReportUseCase: getIt<GetDailyReportUseCase>(),
      getWeeklyReportUseCase: getIt<GetWeeklyReportUseCase>(),
      getMonthlyReportUseCase: getIt<GetMonthlyReportUseCase>(),
      getAccuracyTrendUseCase: getIt<GetAccuracyTrendUseCase>(),
      getErrorPatternsUseCase: getIt<GetErrorPatternsUseCase>(),
      getProjectedImprovementUseCase: getIt<GetProjectedImprovementUseCase>(),
      getPerformanceComparisonUseCase: getIt<GetPerformanceComparisonUseCase>(),
      getOverallStatisticsUseCase: getIt<GetOverallStatisticsUseCase>(),
    ),
  );
}
