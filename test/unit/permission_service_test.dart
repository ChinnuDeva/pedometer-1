import 'package:flutter_test/flutter_test.dart';
import 'package:word_pedometer/core/services/permission_service.dart';

void main() {
  group('PermissionService Tests', () {
    late PermissionService service;

    setUp(() {
      service = PermissionService();
    });

    test('getPermissionStatusMessage returns correct messages', () {
      // Test denied status
      var message = service.getPermissionStatusMessage(
        PermissionStatus.denied,
      );
      expect(message, 'Permission denied');

      // Test granted status
      message = service.getPermissionStatusMessage(
        PermissionStatus.granted,
      );
      expect(message, 'Permission granted');

      // Test permanently denied status
      message = service.getPermissionStatusMessage(
        PermissionStatus.permanentlyDenied,
      );
      expect(
        message,
        'Permission permanently denied. Please enable in settings.',
      );

      // Test restricted status
      message = service.getPermissionStatusMessage(
        PermissionStatus.restricted,
      );
      expect(message, 'Permission restricted by device policy');

      // Test limited status
      message = service.getPermissionStatusMessage(
        PermissionStatus.limited,
      );
      expect(message, 'Permission limited');

      // Test provisional status
      message = service.getPermissionStatusMessage(
        PermissionStatus.provisional,
      );
      expect(message, 'Permission provisional (iOS only)');
    });
  });
}
