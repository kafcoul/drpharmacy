import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/features/pharmacies/domain/usecases/get_pharmacy_details_usecase.dart';
import 'package:drpharma_client/features/pharmacies/domain/repositories/pharmacies_repository.dart';

class MockPharmaciesRepository extends Mock implements PharmaciesRepository {}

void main() {
  late GetPharmacyDetailsUseCase useCase;
  late MockPharmaciesRepository mockRepository;

  setUp(() {
    mockRepository = MockPharmaciesRepository();
    useCase = GetPharmacyDetailsUseCase(mockRepository);
  });

  group('GetPharmacyDetailsUseCase Tests', () {
    test('should be instantiable', () {
      expect(useCase, isNotNull);
    });

    test('should have call method', () {
      expect(useCase.call, isA<Function>());
    });
  });
}
