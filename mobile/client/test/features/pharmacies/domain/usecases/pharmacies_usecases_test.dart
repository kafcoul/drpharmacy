import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/pharmacies/domain/entities/pharmacy_entity.dart';
import 'package:drpharma_client/features/pharmacies/domain/repositories/pharmacies_repository.dart';
import 'package:drpharma_client/features/pharmacies/domain/usecases/get_pharmacies_usecase.dart';
import 'package:drpharma_client/features/pharmacies/domain/usecases/get_nearby_pharmacies_usecase.dart';
import 'package:drpharma_client/features/pharmacies/domain/usecases/get_on_duty_pharmacies_usecase.dart';
import 'package:drpharma_client/features/pharmacies/domain/usecases/get_featured_pharmacies_usecase.dart';
import 'package:drpharma_client/features/pharmacies/domain/usecases/get_pharmacy_details_usecase.dart';

import 'pharmacies_usecases_test.mocks.dart';

@GenerateMocks([PharmaciesRepository])
void main() {
  late MockPharmaciesRepository mockRepository;
  late GetPharmaciesUseCase getPharmaciesUseCase;
  late GetNearbyPharmaciesUseCase getNearbyPharmaciesUseCase;
  late GetOnDutyPharmaciesUseCase getOnDutyPharmaciesUseCase;
  late GetFeaturedPharmaciesUseCase getFeaturedPharmaciesUseCase;
  late GetPharmacyDetailsUseCase getPharmacyDetailsUseCase;

  setUp(() {
    mockRepository = MockPharmaciesRepository();
    getPharmaciesUseCase = GetPharmaciesUseCase(mockRepository);
    getNearbyPharmaciesUseCase = GetNearbyPharmaciesUseCase(mockRepository);
    getOnDutyPharmaciesUseCase = GetOnDutyPharmaciesUseCase(mockRepository);
    getFeaturedPharmaciesUseCase = GetFeaturedPharmaciesUseCase(mockRepository);
    getPharmacyDetailsUseCase = GetPharmacyDetailsUseCase(mockRepository);
  });

  // Test data
  const testPharmacy = PharmacyEntity(
    id: 1,
    name: 'Pharmacie du Centre',
    address: '123 Rue Principale, Libreville',
    phone: '+24107123456',
    email: 'contact@pharmacie-centre.ga',
    latitude: 0.4162,
    longitude: 9.4673,
    status: 'active',
    isOpen: true,
    distance: 1.5,
    openingHours: '08:00 - 20:00',
    description: 'Pharmacie moderne au centre-ville',
    isOnDuty: false,
  );

  const testPharmacyOnDuty = PharmacyEntity(
    id: 2,
    name: 'Pharmacie de Garde',
    address: '456 Rue de la Santé, Libreville',
    phone: '+24107654321',
    status: 'active',
    isOpen: true,
    isOnDuty: true,
    dutyType: 'night',
    dutyEndAt: '08:00',
  );

  final testPharmaciesList = [testPharmacy, testPharmacyOnDuty];

  group('GetPharmaciesUseCase', () {
    test('should return list of pharmacies on success', () async {
      // Arrange
      when(mockRepository.getPharmacies(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => Right(testPharmaciesList));

      // Act
      final result = await getPharmaciesUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned pharmacies'),
        (pharmacies) {
          expect(pharmacies.length, 2);
          expect(pharmacies.first.name, 'Pharmacie du Centre');
        },
      );
    });

    test('should pass pagination parameters to repository', () async {
      // Arrange
      when(mockRepository.getPharmacies(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => Right(testPharmaciesList));

      // Act
      await getPharmaciesUseCase(page: 2, perPage: 10);

      // Assert
      verify(mockRepository.getPharmacies(page: 2, perPage: 10)).called(1);
    });

    test('should return failure on repository error', () async {
      // Arrange
      when(mockRepository.getPharmacies(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => const Left(
        NetworkFailure(message: 'No internet connection'),
      ));

      // Act
      final result = await getPharmaciesUseCase();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });

    test('should use default pagination values', () async {
      // Arrange
      when(mockRepository.getPharmacies(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => Right(testPharmaciesList));

      // Act
      await getPharmaciesUseCase();

      // Assert
      verify(mockRepository.getPharmacies(page: 1, perPage: 20)).called(1);
    });
  });

  group('GetNearbyPharmaciesUseCase', () {
    test('should return nearby pharmacies on success', () async {
      // Arrange
      when(mockRepository.getNearbyPharmacies(
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        radius: anyNamed('radius'),
      )).thenAnswer((_) async => Right(testPharmaciesList));

      // Act
      final result = await getNearbyPharmaciesUseCase(
        latitude: 0.4162,
        longitude: 9.4673,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned pharmacies'),
        (pharmacies) => expect(pharmacies.length, 2),
      );
    });

    test('should pass coordinates and radius to repository', () async {
      // Arrange
      when(mockRepository.getNearbyPharmacies(
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        radius: anyNamed('radius'),
      )).thenAnswer((_) async => Right(testPharmaciesList));

      // Act
      await getNearbyPharmaciesUseCase(
        latitude: 0.4162,
        longitude: 9.4673,
        radius: 5.0,
      );

      // Assert
      verify(mockRepository.getNearbyPharmacies(
        latitude: 0.4162,
        longitude: 9.4673,
        radius: 5.0,
      )).called(1);
    });

    test('should use default radius of 10km', () async {
      // Arrange
      when(mockRepository.getNearbyPharmacies(
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        radius: anyNamed('radius'),
      )).thenAnswer((_) async => Right(testPharmaciesList));

      // Act
      await getNearbyPharmaciesUseCase(
        latitude: 0.4162,
        longitude: 9.4673,
      );

      // Assert
      verify(mockRepository.getNearbyPharmacies(
        latitude: 0.4162,
        longitude: 9.4673,
        radius: 10.0,
      )).called(1);
    });

    test('should return failure when location services fail', () async {
      // Arrange
      when(mockRepository.getNearbyPharmacies(
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        radius: anyNamed('radius'),
      )).thenAnswer((_) async => const Left(
        ServerFailure(message: 'Location services unavailable'),
      ));

      // Act
      final result = await getNearbyPharmaciesUseCase(
        latitude: 0.4162,
        longitude: 9.4673,
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('GetOnDutyPharmaciesUseCase', () {
    test('should return on-duty pharmacies on success', () async {
      // Arrange
      when(mockRepository.getOnDutyPharmacies(
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        radius: anyNamed('radius'),
      )).thenAnswer((_) async => Right([testPharmacyOnDuty]));

      // Act
      final result = await getOnDutyPharmaciesUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned pharmacies'),
        (pharmacies) {
          expect(pharmacies.length, 1);
          expect(pharmacies.first.isOnDuty, true);
        },
      );
    });

    test('should filter only on-duty pharmacies', () async {
      // Arrange
      when(mockRepository.getOnDutyPharmacies(
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        radius: anyNamed('radius'),
      )).thenAnswer((_) async => Right([testPharmacyOnDuty]));

      // Act
      final result = await getOnDutyPharmaciesUseCase(
        latitude: 0.4162,
        longitude: 9.4673,
      );

      // Assert
      result.fold(
        (failure) => fail('Should have returned pharmacies'),
        (pharmacies) {
          for (final pharmacy in pharmacies) {
            expect(pharmacy.isOnDuty, true);
          }
        },
      );
    });

    test('should return empty list when no on-duty pharmacies', () async {
      // Arrange
      when(mockRepository.getOnDutyPharmacies(
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        radius: anyNamed('radius'),
      )).thenAnswer((_) async => const Right([]));

      // Act
      final result = await getOnDutyPharmaciesUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned empty list'),
        (pharmacies) => expect(pharmacies.isEmpty, true),
      );
    });
  });

  group('GetFeaturedPharmaciesUseCase', () {
    test('should return featured pharmacies on success', () async {
      // Arrange
      when(mockRepository.getFeaturedPharmacies())
          .thenAnswer((_) async => Right(testPharmaciesList));

      // Act
      final result = await getFeaturedPharmaciesUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned pharmacies'),
        (pharmacies) => expect(pharmacies.length, 2),
      );
    });

    test('should return failure on repository error', () async {
      // Arrange
      when(mockRepository.getFeaturedPharmacies())
          .thenAnswer((_) async => const Left(
            ServerFailure(message: 'Server error'),
          ));

      // Act
      final result = await getFeaturedPharmaciesUseCase();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });
  });

  group('GetPharmacyDetailsUseCase', () {
    test('should return pharmacy details on success', () async {
      // Arrange
      when(mockRepository.getPharmacyDetails(any))
          .thenAnswer((_) async => const Right(testPharmacy));

      // Act
      final result = await getPharmacyDetailsUseCase(1);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned pharmacy'),
        (pharmacy) {
          expect(pharmacy.id, 1);
          expect(pharmacy.name, 'Pharmacie du Centre');
        },
      );
    });

    test('should pass correct id to repository', () async {
      // Arrange
      when(mockRepository.getPharmacyDetails(any))
          .thenAnswer((_) async => const Right(testPharmacy));

      // Act
      await getPharmacyDetailsUseCase(42);

      // Assert
      verify(mockRepository.getPharmacyDetails(42)).called(1);
    });

    test('should return failure when pharmacy not found', () async {
      // Arrange
      when(mockRepository.getPharmacyDetails(any))
          .thenAnswer((_) async => const Left(
            ServerFailure(message: 'Pharmacy not found', statusCode: 404),
          ));

      // Act
      final result = await getPharmacyDetailsUseCase(999);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).statusCode, 404);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return failure on network error', () async {
      // Arrange
      when(mockRepository.getPharmacyDetails(any))
          .thenAnswer((_) async => const Left(
            NetworkFailure(message: 'No internet connection'),
          ));

      // Act
      final result = await getPharmacyDetailsUseCase(1);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });
  });

  group('PharmacyEntity', () {
    test('should return correct initials for single word name', () {
      // Arrange
      const pharmacy = PharmacyEntity(
        id: 1,
        name: 'Pharmacie',
        address: 'Test',
        status: 'active',
        isOpen: true,
      );

      // Assert
      expect(pharmacy.initials, 'P');
    });

    test('should return correct initials for multi-word name', () {
      // Assert
      expect(testPharmacy.initials, 'PD');
    });

    test('should return correct distance label in meters', () {
      // Arrange
      const pharmacy = PharmacyEntity(
        id: 1,
        name: 'Test',
        address: 'Test',
        status: 'active',
        isOpen: true,
        distance: 0.5,
      );

      // Assert
      expect(pharmacy.distanceLabel, '500 m');
    });

    test('should return correct distance label in kilometers', () {
      // Assert
      expect(testPharmacy.distanceLabel, '1.5 km');
    });

    test('should return empty string for null distance', () {
      // Arrange
      const pharmacy = PharmacyEntity(
        id: 1,
        name: 'Test',
        address: 'Test',
        status: 'active',
        isOpen: true,
      );

      // Assert
      expect(pharmacy.distanceLabel, '');
    });

    test('should return correct status labels', () {
      // Assert
      expect(testPharmacy.statusLabel, 'Active');

      const inactivePharmacy = PharmacyEntity(
        id: 1,
        name: 'Test',
        address: 'Test',
        status: 'inactive',
        isOpen: false,
      );
      expect(inactivePharmacy.statusLabel, 'Inactive');

      const suspendedPharmacy = PharmacyEntity(
        id: 1,
        name: 'Test',
        address: 'Test',
        status: 'suspended',
        isOpen: false,
      );
      expect(suspendedPharmacy.statusLabel, 'Suspendue');
    });
  });
}
