import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/addresses/domain/entities/address_entity.dart';
import 'package:drpharma_client/features/addresses/domain/repositories/address_repository.dart';
import 'package:drpharma_client/features/addresses/presentation/providers/addresses_provider.dart';

import 'addresses_notifier_test.mocks.dart';

@GenerateMocks([AddressRepository])
void main() {
  late MockAddressRepository mockRepository;
  late AddressesNotifier notifier;

  // Test data
  final now = DateTime.now();
  
  final testAddress1 = AddressEntity(
    id: 1,
    label: 'Maison',
    address: '123 Rue Test',
    city: 'Cotonou',
    district: 'Akpakpa',
    phone: '+22990000001',
    instructions: 'Portail bleu',
    latitude: 6.3702,
    longitude: 2.3912,
    isDefault: true,
    fullAddress: '123 Rue Test, Akpakpa, Cotonou',
    hasCoordinates: true,
    createdAt: now,
    updatedAt: now,
  );

  final testAddress2 = AddressEntity(
    id: 2,
    label: 'Bureau',
    address: '456 Avenue Commerce',
    city: 'Cotonou',
    district: 'Cadjehoun',
    phone: '+22990000002',
    instructions: null,
    latitude: 6.3650,
    longitude: 2.4100,
    isDefault: false,
    fullAddress: '456 Avenue Commerce, Cadjehoun, Cotonou',
    hasCoordinates: true,
    createdAt: now,
    updatedAt: now,
  );

  final testAddresses = [testAddress1, testAddress2];

  setUp(() {
    mockRepository = MockAddressRepository();
    notifier = AddressesNotifier(mockRepository);
  });

  group('AddressesNotifier', () {
    group('initialization', () {
      test('should start with empty state', () {
        expect(notifier.state.addresses, isEmpty);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNull);
        expect(notifier.state.selectedAddress, isNull);
      });
    });

    group('loadAddresses', () {
      test('should load addresses and select default on success', () async {
        // Arrange
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Right(testAddresses));

        // Act
        await notifier.loadAddresses();

        // Assert
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.addresses, equals(testAddresses));
        expect(notifier.state.selectedAddress, equals(testAddress1)); // Default
        expect(notifier.state.error, isNull);
      });

      test('should set error on failure', () async {
        // Arrange
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Left(ServerFailure(message: 'Erreur réseau')));

        // Act
        await notifier.loadAddresses();

        // Assert
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, equals('Erreur réseau'));
        expect(notifier.state.addresses, isEmpty);
      });

      test('should set loading state during fetch', () async {
        // Arrange
        when(mockRepository.getAddresses())
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 10));
              return Right(testAddresses);
            });

        // Act
        final future = notifier.loadAddresses();
        
        // Assert - should be loading immediately
        expect(notifier.state.isLoading, isTrue);
        
        await future;
        expect(notifier.state.isLoading, isFalse);
      });
    });

    group('createAddress', () {
      test('should add new address to list on success', () async {
        // Arrange
        final newAddress = AddressEntity(
          id: 3,
          label: 'Ami',
          address: '789 Rue Nouvelle',
          city: 'Cotonou',
          isDefault: false,
          fullAddress: '789 Rue Nouvelle, Cotonou',
          hasCoordinates: false,
          createdAt: now,
          updatedAt: now,
        );

        when(mockRepository.createAddress(
          label: anyNamed('label'),
          address: anyNamed('address'),
          city: anyNamed('city'),
          district: anyNamed('district'),
          phone: anyNamed('phone'),
          instructions: anyNamed('instructions'),
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          isDefault: anyNamed('isDefault'),
        )).thenAnswer((_) async => Right(newAddress));

        // Act
        final result = await notifier.createAddress(
          label: 'Ami',
          address: '789 Rue Nouvelle',
          city: 'Cotonou',
        );

        // Assert
        expect(result, isTrue);
        expect(notifier.state.addresses.contains(newAddress), isTrue);
        expect(notifier.state.error, isNull);
      });

      test('should update other addresses when new one is default', () async {
        // Arrange - load existing addresses first
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Right(testAddresses));
        await notifier.loadAddresses();

        final newDefaultAddress = AddressEntity(
          id: 3,
          label: 'Nouveau Défaut',
          address: '999 Rue Principale',
          city: 'Cotonou',
          isDefault: true,
          fullAddress: '999 Rue Principale, Cotonou',
          hasCoordinates: false,
          createdAt: now,
          updatedAt: now,
        );

        when(mockRepository.createAddress(
          label: anyNamed('label'),
          address: anyNamed('address'),
          city: anyNamed('city'),
          district: anyNamed('district'),
          phone: anyNamed('phone'),
          instructions: anyNamed('instructions'),
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          isDefault: anyNamed('isDefault'),
        )).thenAnswer((_) async => Right(newDefaultAddress));

        // Act
        await notifier.createAddress(
          label: 'Nouveau Défaut',
          address: '999 Rue Principale',
          isDefault: true,
        );

        // Assert - old default should lose its flag
        final oldDefault = notifier.state.addresses.firstWhere((a) => a.id == 1);
        expect(oldDefault.isDefault, isFalse);
        expect(notifier.state.selectedAddress, equals(newDefaultAddress));
      });

      test('should return false and set error on failure', () async {
        // Arrange
        when(mockRepository.createAddress(
          label: anyNamed('label'),
          address: anyNamed('address'),
          city: anyNamed('city'),
          district: anyNamed('district'),
          phone: anyNamed('phone'),
          instructions: anyNamed('instructions'),
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          isDefault: anyNamed('isDefault'),
        )).thenAnswer((_) async => Left(ServerFailure(message: 'Erreur création')));

        // Act
        final result = await notifier.createAddress(
          label: 'Test',
          address: 'Test Address',
        );

        // Assert
        expect(result, isFalse);
        expect(notifier.state.error, equals('Erreur création'));
      });
    });

    group('updateAddress', () {
      test('should update address in list on success', () async {
        // Arrange - load existing addresses first
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Right(testAddresses));
        await notifier.loadAddresses();

        final updatedAddress = testAddress2.copyWith(
          label: 'Bureau Principal',
          phone: '+22999999999',
        );

        when(mockRepository.updateAddress(
          id: anyNamed('id'),
          label: anyNamed('label'),
          address: anyNamed('address'),
          city: anyNamed('city'),
          district: anyNamed('district'),
          phone: anyNamed('phone'),
          instructions: anyNamed('instructions'),
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          isDefault: anyNamed('isDefault'),
        )).thenAnswer((_) async => Right(updatedAddress));

        // Act
        final result = await notifier.updateAddress(
          id: 2,
          label: 'Bureau Principal',
          phone: '+22999999999',
        );

        // Assert
        expect(result, isTrue);
        final address = notifier.state.addresses.firstWhere((a) => a.id == 2);
        expect(address.label, equals('Bureau Principal'));
      });

      test('should return false on failure', () async {
        // Arrange
        when(mockRepository.updateAddress(
          id: anyNamed('id'),
          label: anyNamed('label'),
          address: anyNamed('address'),
          city: anyNamed('city'),
          district: anyNamed('district'),
          phone: anyNamed('phone'),
          instructions: anyNamed('instructions'),
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          isDefault: anyNamed('isDefault'),
        )).thenAnswer((_) async => Left(ServerFailure(message: 'Adresse introuvable')));

        // Act
        final result = await notifier.updateAddress(id: 999, label: 'Test');

        // Assert
        expect(result, isFalse);
        expect(notifier.state.error, equals('Adresse introuvable'));
      });
    });

    group('deleteAddress', () {
      test('should remove address from list on success', () async {
        // Arrange - load existing addresses first
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Right(testAddresses));
        await notifier.loadAddresses();

        when(mockRepository.deleteAddress(2))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await notifier.deleteAddress(2);

        // Assert
        expect(result, isTrue);
        expect(notifier.state.addresses.any((a) => a.id == 2), isFalse);
        expect(notifier.state.addresses.length, equals(1));
      });

      test('should select new address when deleting selected', () async {
        // Arrange - load addresses and select address2
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Right(testAddresses));
        await notifier.loadAddresses();
        notifier.selectAddress(testAddress2);
        expect(notifier.state.selectedAddress, equals(testAddress2));

        when(mockRepository.deleteAddress(2))
            .thenAnswer((_) async => const Right(null));

        // Act
        await notifier.deleteAddress(2);

        // Assert - should select default or first available
        expect(notifier.state.selectedAddress, equals(testAddress1));
      });

      test('should return false on failure', () async {
        // Arrange
        when(mockRepository.deleteAddress(1))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Impossible de supprimer')));

        // Act
        final result = await notifier.deleteAddress(1);

        // Assert
        expect(result, isFalse);
        expect(notifier.state.error, equals('Impossible de supprimer'));
      });
    });

    group('setDefaultAddress', () {
      test('should update default flag on success', () async {
        // Arrange - load existing addresses first
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Right(testAddresses));
        await notifier.loadAddresses();

        final newDefault = testAddress2.copyWith(isDefault: true);

        when(mockRepository.setDefaultAddress(2))
            .thenAnswer((_) async => Right(newDefault));

        // Act
        final result = await notifier.setDefaultAddress(2);

        // Assert
        expect(result, isTrue);
        final oldDefault = notifier.state.addresses.firstWhere((a) => a.id == 1);
        final currentDefault = notifier.state.addresses.firstWhere((a) => a.id == 2);
        expect(oldDefault.isDefault, isFalse);
        expect(currentDefault.isDefault, isTrue);
        expect(notifier.state.selectedAddress?.id, equals(2));
      });
    });

    group('selectAddress', () {
      test('should update selected address', () {
        // Act
        notifier.selectAddress(testAddress2);

        // Assert
        expect(notifier.state.selectedAddress, equals(testAddress2));
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Arrange - trigger an error first
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Left(ServerFailure(message: 'Erreur')));
        await notifier.loadAddresses();
        expect(notifier.state.error, isNotNull);

        // Act
        notifier.clearError();

        // Assert
        expect(notifier.state.error, isNull);
      });
    });

    group('defaultAddress getter', () {
      test('should return default address from state', () async {
        // Arrange
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Right(testAddresses));
        await notifier.loadAddresses();

        // Assert
        expect(notifier.state.defaultAddress, equals(testAddress1));
      });

      test('should return null when no default', () async {
        // Arrange
        final noDefaultAddresses = [
          testAddress1.copyWith(isDefault: false),
          testAddress2,
        ];
        when(mockRepository.getAddresses())
            .thenAnswer((_) async => Right(noDefaultAddresses));
        await notifier.loadAddresses();

        // Assert
        expect(notifier.state.defaultAddress, isNull);
      });
    });
  });
}
