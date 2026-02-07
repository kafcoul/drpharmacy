import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/prescriptions/domain/usecases/pay_prescription_usecase.dart';
import 'package:drpharma_client/features/prescriptions/domain/repositories/prescriptions_repository.dart';

class MockPrescriptionsRepository extends Mock implements PrescriptionsRepository {}

void main() {
  late PayPrescriptionUseCase useCase;
  late MockPrescriptionsRepository mockRepository;

  setUp(() {
    mockRepository = MockPrescriptionsRepository();
    useCase = PayPrescriptionUseCase(mockRepository);
  });

  group('PayPrescriptionUseCase Tests', () {
    test('should be instantiable', () {
      expect(useCase, isNotNull);
    });

    test('should have call method', () {
      expect(useCase.call, isA<Function>());
    });
  });
}
