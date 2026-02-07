import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:drpharma_client/features/notifications/domain/repositories/notifications_repository.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  late GetNotificationsUseCase useCase;
  late MockNotificationsRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationsRepository();
    useCase = GetNotificationsUseCase(mockRepository);
  });

  group('GetNotificationsUseCase Tests', () {
    test('should be instantiable', () {
      expect(useCase, isNotNull);
    });

    test('should have call method', () {
      expect(useCase.call, isA<Function>());
    });
  });
}
