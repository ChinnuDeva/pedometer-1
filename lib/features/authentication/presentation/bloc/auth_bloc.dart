import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_pedometer/features/authentication/domain/entities/user.dart';
import 'package:word_pedometer/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:word_pedometer/core/usecases/usecase.dart';

/// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested();
}

class AuthSignInWithDemoRequested extends AuthEvent {
  const AuthSignInWithDemoRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Auth States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool isDemo;

  const AuthAuthenticated({required this.user, this.isDemo = false});

  @override
  List<Object?> get props => [user, isDemo];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignInWithDemoRequested>(_onSignInWithDemoRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final result = await getCurrentUserUseCase(const NoParams());
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final result = await signInWithGoogleUseCase(const NoParams());
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignInWithDemoRequested(
    AuthSignInWithDemoRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    // Create a demo user
    final demoUser = User(
      id: 'demo_user_001',
      email: 'demo@wordpedometer.app',
      displayName: 'Demo User',
      photoUrl: null,
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthAuthenticated(user: demoUser, isDemo: true));
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final result = await signOutUseCase(const NoParams());
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
