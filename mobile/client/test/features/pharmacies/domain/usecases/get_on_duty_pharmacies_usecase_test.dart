import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/pharmacies/domain/usecases/get_on_duty_pharmacies_usecase.dart';
import 'package:drpharma_client/features/pharmacies/domain/repositories/pharmacies_repository.dart';

class MockPharmaciesRepository extends Mock implements PharmaciesRepository {}

void main() {
  late GetOnDutyPharmaciesUseCase useCase;
  late MockPharmaciesRepository mockRepository;

  setUp(() {
    mockRepository = MockPharmaciesRepository();
    useCase = GetOnDutyPharmaciesUseCase(mockRepository);
  });

  group('GetOnDutyPharmaciesUseCase Tests', () {
    test('should be instantiable', () {
      expect(useCase, isNotNull);
    });

    test('should have call method', () {
      expect(useCase.call, isA<Function>());
    });
  });
}
