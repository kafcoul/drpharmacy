import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/prescriptions/domain/usecases/get_prescription_details_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/repositories/prescriptions_repository.dart';

class MockPrescriptionsRepository extends Mock implements PrescriptionsRepository {}

void main() {
  late GetPrescriptionDetailsUseCase useCase;
  late MockPrescriptionsRepository mockRepository;

  setUp(() {
    mockRepository = MockPrescriptionsRepository();
    useCase = GetPrescriptionDetailsUseCase(mockRepository);
  });

  group('GetPrescriptionDetailsUseCase Tests', () {
    test('should be instantiable', () {
      expect(useCase, isNotNull);
    });

    test('should have call method', () {
      expect(useCase.call, isA<Function>());
    });
  });
}
