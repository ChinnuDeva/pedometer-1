import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

/// Exception thrown by authentication service
class AuthException implements Exception {
  final String message;
  final dynamic originalError;

  AuthException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'AuthException: $message';
}

/// User model for authenticated users
class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  @override
  String toString() => 'AuthUser(email: $email, name: $displayName)';
}

/// Service for handling Google Sign-In authentication
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final Logger _logger = Logger();

  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize the auth service
  Future<void> initialize() async {
    _logger.d('AuthService initialized');
    
    // Try to restore previous session
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        _currentUser = AuthUser(
          id: account.id,
          email: account.email,
          displayName: account.displayName ?? 'User',
          photoUrl: account.photoUrl,
        );
        _logger.i('Restored previous session for: ${_currentUser!.email}');
      }
    } catch (e) {
      _logger.w('No previous session found: $e');
    }
  }

  /// Sign in with Google
  Future<AuthUser> signIn() async {
    try {
      _logger.d('Starting Google Sign-In...');
      
      final account = await _googleSignIn.signIn();
      
      if (account == null) {
        throw AuthException(message: 'Sign-in was cancelled by user');
      }

      _currentUser = AuthUser(
        id: account.id,
        email: account.email,
        displayName: account.displayName ?? 'User',
        photoUrl: account.photoUrl,
      );

      _logger.i('Successfully signed in: ${_currentUser!.email}');
      return _currentUser!;
    } catch (e) {
      _logger.e('Sign-in failed: $e');
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Failed to sign in with Google',
        originalError: e,
      );
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _logger.i('Successfully signed out');
    } catch (e) {
      _logger.e('Sign-out failed: $e');
      throw AuthException(
        message: 'Failed to sign out',
        originalError: e,
      );
    }
  }

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Disconnect the Google account
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
      _logger.i('Disconnected Google account');
    } catch (e) {
      _logger.e('Disconnect failed: $e');
    }
  }
}
