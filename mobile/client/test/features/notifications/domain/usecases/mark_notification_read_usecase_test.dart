import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:drpharma_client/features/notifications/domain/repositories/notifications_repository.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  late MarkNotificationReadUseCase useCase;
  late MockNotificationsRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationsRepository();
    useCase = MarkNotificationReadUseCase(mockRepository);
  });

  group('MarkNotificationReadUseCase Tests', () {
    test('should be instantiable', () {
      expect(useCase, isNotNull);
    });

    test('should have call method', () {
      expect(useCase.call, isA<Function>());
    });
  });
}
