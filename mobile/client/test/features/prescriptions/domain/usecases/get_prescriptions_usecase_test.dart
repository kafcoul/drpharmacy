import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/prescriptions/domain/usecases/get_prescriptions_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/repositories/prescriptions_repository.dart';

class MockPrescriptionsRepository extends Mock implements PrescriptionsRepository {}

void main() {
  late GetPrescriptionsUseCase useCase;
  late MockPrescriptionsRepository mockRepository;

  setUp(() {
    mockRepository = MockPrescriptionsRepository();
    useCase = GetPrescriptionsUseCase(mockRepository);
  });

  group('GetPrescriptionsUseCase Tests', () {
    test('should be instantiable', () {
      expect(useCase, isNotNull);
    });

    test('should have call method', () {
      expect(useCase.call, isA<Function>());
    });
  });
}
