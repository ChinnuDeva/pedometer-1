import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

/// Exception for permission-related errors
class PermissionException implements Exception {

  PermissionException({
    required this.message,
    this.status,
  });
  final String message;
  final PermissionStatus? status;

  @override
  String toString() => 'PermissionException: $message';
}

/// Service for managing app permissions
class PermissionService {
  final Logger _logger = Logger();

  /// Request microphone permission
  /// Returns true if permission is granted
  Future<bool> requestMicrophonePermission() async {
    try {
      _logger.d('Requesting microphone permission...');
      
      final status = await Permission.microphone.request();
      
      _logger.d('Microphone permission status: $status');

      return _handlePermissionStatus(status, 'Microphone');
    } catch (e) {
      _logger.e('Error requesting microphone permission: $e');
      throw PermissionException(
        message: 'Failed to request microphone permission: $e',
      );
    }
  }

  /// Check if microphone permission is granted
  Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      _logger.d('Microphone permission status: $status');
      return status.isGranted;
    } catch (e) {
      _logger.e('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Request required permissions for speech recognition
  /// Requests: Microphone
  Future<Map<Permission, PermissionStatus>> requestAllRequiredPermissions() async {
    try {
      _logger.d('Requesting all required permissions...');
      
      final statuses = await [
        Permission.microphone,
      ].request();

      _logger.d('Permissions requested: $statuses');

      return statuses;
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
      throw PermissionException(
        message: 'Failed to request permissions: $e',
      );
    }
  }

  /// Check if all required permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    try {
      final microphoneGranted = await Permission.microphone.isGranted;
      return microphoneGranted;
    } catch (e) {
      _logger.e('Error checking permissions: $e');
      return false;
    }
  }

  /// Open app settings to manually grant permissions
  Future<bool> openAppSettings() async {
    try {
      _logger.d('Opening app settings...');
      return await openAppSettings();
    } catch (e) {
      _logger.e('Error opening app settings: $e');
      return false;
    }
  }

  /// Get human-readable permission status message
  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied. Please enable in settings.';
      case PermissionStatus.restricted:
        return 'Permission restricted by device policy';
      case PermissionStatus.limited:
        return 'Permission limited';
      case PermissionStatus.provisional:
        return 'Permission provisional (iOS only)';
    }
  }

  // Private helpers

  bool _handlePermissionStatus(
    PermissionStatus status,
    String permissionName,
  ) {
    switch (status) {
      case PermissionStatus.granted:
        _logger.i('$permissionName permission granted');
        return true;
      case PermissionStatus.denied:
        _logger.w('$permissionName permission denied by user');
        return false;
      case PermissionStatus.permanentlyDenied:
        _logger.w('$permissionName permission permanently denied');
        return false;
      case PermissionStatus.restricted:
        _logger.w('$permissionName permission restricted');
        return false;
      case PermissionStatus.limited:
        _logger.i('$permissionName permission limited');
        return true;
      case PermissionStatus.provisional:
        _logger.i('$permissionName permission provisional');
        return true;
    }
  }
}
