import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:drpharma_client/features/orders/data/datasources/orders_local_datasource.dart';
import 'package:drpharma_client/features/orders/data/models/order_model.dart';

import 'orders_local_datasource_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockSharedPreferences;
  late OrdersLocalDataSource dataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = OrdersLocalDataSource(mockSharedPreferences);
  });

  // Test data
  const testPharmacy = PharmacyBasicModel(
    id: 1,
    name: 'Pharmacie Test',
    phone: '+24107123456',
    address: 'Libreville',
  );

  final testOrderModel = OrderModel(
    id: 1,
    reference: 'ORD-001',
    status: 'pending',
    paymentStatus: 'pending',
    paymentMode: 'on_delivery',
    pharmacyId: 1,
    pharmacy: testPharmacy,
    items: const [],
    subtotal: 3000.0,
    deliveryFee: 500.0,
    totalAmount: 3500.0,
    currency: 'XOF',
    deliveryAddress: 'Test Address',
    deliveryCity: 'Libreville',
    customerPhone: '+24107123456',
    createdAt: '2026-02-01T10:00:00Z',
  );

  group('cacheOrders', () {
    test('should cache orders list to SharedPreferences', () async {
      // Arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheOrders([testOrderModel]);

      // Assert
      final expectedJson = jsonEncode([testOrderModel.toJson()]);
      verify(mockSharedPreferences.setString('cached_orders', expectedJson))
          .called(1);
    });

    test('should cache empty list', () async {
      // Arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheOrders([]);

      // Assert
      verify(mockSharedPreferences.setString('cached_orders', '[]')).called(1);
    });
  });

  group('getCachedOrders', () {
    test('should return cached orders when available', () {
      // Arrange
      final ordersJson = jsonEncode([testOrderModel.toJson()]);
      when(mockSharedPreferences.getString('cached_orders'))
          .thenReturn(ordersJson);

      // Act
      final result = dataSource.getCachedOrders();

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.id, 1);
      expect(result.first.reference, 'ORD-001');
    });

    test('should return null when no cached orders', () {
      // Arrange
      when(mockSharedPreferences.getString('cached_orders')).thenReturn(null);

      // Act
      final result = dataSource.getCachedOrders();

      // Assert
      expect(result, isNull);
    });

    test('should return empty list when cached empty array', () {
      // Arrange
      when(mockSharedPreferences.getString('cached_orders')).thenReturn('[]');

      // Act
      final result = dataSource.getCachedOrders();

      // Assert
      expect(result, isNotNull);
      expect(result!.isEmpty, true);
    });
  });

  group('cacheOrder', () {
    test('should cache single order with correct key', () async {
      // Arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheOrder(testOrderModel);

      // Assert
      final expectedJson = jsonEncode(testOrderModel.toJson());
      verify(mockSharedPreferences.setString('cached_order_1', expectedJson))
          .called(1);
    });
  });

  group('getCachedOrder', () {
    test('should return cached order by ID', () {
      // Arrange
      final orderJson = jsonEncode(testOrderModel.toJson());
      when(mockSharedPreferences.getString('cached_order_1'))
          .thenReturn(orderJson);

      // Act
      final result = dataSource.getCachedOrder(1);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.reference, 'ORD-001');
    });

    test('should return null when order not cached', () {
      // Arrange
      when(mockSharedPreferences.getString('cached_order_999'))
          .thenReturn(null);

      // Act
      final result = dataSource.getCachedOrder(999);

      // Assert
      expect(result, isNull);
    });
  });

  group('clearCache', () {
    test('should remove all cached orders', () async {
      // Arrange
      when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);
      when(mockSharedPreferences.getKeys()).thenReturn({
        'cached_orders',
        'cached_order_1',
        'cached_order_2',
        'other_key',
      });

      // Act
      await dataSource.clearCache();

      // Assert
      verify(mockSharedPreferences.remove('cached_orders')).called(1);
      verify(mockSharedPreferences.remove('cached_order_1')).called(1);
      verify(mockSharedPreferences.remove('cached_order_2')).called(1);
      verifyNever(mockSharedPreferences.remove('other_key'));
    });

    test('should handle empty cache', () async {
      // Arrange
      when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);
      when(mockSharedPreferences.getKeys()).thenReturn({});

      // Act
      await dataSource.clearCache();

      // Assert
      verify(mockSharedPreferences.remove('cached_orders')).called(1);
    });
  });
}
