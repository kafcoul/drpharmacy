import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';
import '../entities/delivery_address_entity.dart';
import '../repositories/orders_repository.dart';

class CreateOrderUseCase {
  final OrdersRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required int pharmacyId,
    required List<OrderItemEntity> items,
    required DeliveryAddressEntity deliveryAddress,
    required String paymentMode,
    String? prescriptionImage,
    String? customerNotes,
    int? prescriptionId, // ID de la prescription uploadée via checkout
  }) async {
    // Validation
    if (pharmacyId <= 0) {
      return Left(
        ValidationFailure(
          message: 'Invalid pharmacy ID',
          errors: {
            'pharmacyId': ['Invalid pharmacy ID'],
          },
        ),
      );
    }

    if (items.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Order must contain at least one item',
          errors: {
            'items': ['Order must contain at least one item'],
          },
        ),
      );
    }

    for (var item in items) {
      if (item.quantity <= 0) {
        return Left(
          ValidationFailure(
            message: 'Item quantity must be greater than 0',
            errors: {
              'quantity': ['Item quantity must be greater than 0'],
            },
          ),
        );
      }
      if (item.unitPrice < 0) {
        return Left(
          ValidationFailure(
            message: 'Item price cannot be negative',
            errors: {
              'price': ['Item price cannot be negative'],
            },
          ),
        );
      }
      if (item.name.trim().isEmpty) {
        return Left(
          ValidationFailure(
            message: 'Item name cannot be empty',
            errors: {
              'name': ['Item name cannot be empty'],
            },
          ),
        );
      }
    }

    if (deliveryAddress.address.trim().isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Delivery address is required',
          errors: {
            'address': ['Delivery address is required'],
          },
        ),
      );
    }

    if (paymentMode != 'platform' && paymentMode != 'on_delivery') {
      return Left(
        ValidationFailure(
          message: 'Invalid payment mode',
          errors: {
            'paymentMode': ['Invalid payment mode'],
          },
        ),
      );
    }

    return await repository.createOrder(
      pharmacyId: pharmacyId,
      items: items,
      deliveryAddress: deliveryAddress,
      paymentMode: paymentMode,
      prescriptionImage: prescriptionImage,
      customerNotes: customerNotes,
      prescriptionId: prescriptionId,
    );
  }
}
