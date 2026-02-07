import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/app_logger.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrdersRemoteDataSource {
  final ApiClient apiClient;

  OrdersRemoteDataSource(this.apiClient);

  /// Get all orders for the current user
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await apiClient.get(
      '/customer/orders',
      queryParameters: queryParams,
    );

    final List<dynamic> ordersJson = response.data['data'] as List<dynamic>;
    return ordersJson
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get order details by ID
  Future<OrderModel> getOrderDetails(int orderId) async {
    AppLogger.debug('[GetOrderDetails] Fetching order $orderId');
    final response = await apiClient.get('/customer/orders/$orderId');
    final orderData = response.data['data'] as Map<String, dynamic>;
    AppLogger.debug('[GetOrderDetails] Order loaded successfully');
    return OrderModel.fromJson(orderData);
  }

  /// Create a new order
  Future<OrderModel> createOrder({
    required int pharmacyId,
    required List<OrderItemModel> items,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMode,
    String? prescriptionImage,
    String? customerNotes,
    int? prescriptionId, // ID de la prescription uploadée via checkout
  }) async {
    // Ensure customer_phone is present (required by API)
    final customerPhone = deliveryAddress['phone'] as String?;
    if (customerPhone == null || customerPhone.isEmpty) {
      throw ValidationException(
        errors: {'customer_phone': ['Le numéro de téléphone est requis']},
      );
    }

    final data = {
      'pharmacy_id': pharmacyId,
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress['address'],
      'customer_phone': customerPhone,
      if (deliveryAddress['city'] != null)
        'delivery_city': deliveryAddress['city'],
      if (deliveryAddress['latitude'] != null)
        'delivery_latitude': deliveryAddress['latitude'],
      if (deliveryAddress['longitude'] != null)
        'delivery_longitude': deliveryAddress['longitude'],
      'payment_mode': paymentMode,
      if (prescriptionImage != null) 'prescription_image': prescriptionImage,
      if (prescriptionId != null) 'prescription_id': prescriptionId,
      if (customerNotes != null) 'customer_notes': customerNotes,
    };

    AppLogger.debug('[CreateOrder] Creating order for pharmacy $pharmacyId with ${items.length} items');
    final response = await apiClient.post('/customer/orders', data: data);

    // API returns simplified response on creation
    final responseData = response.data['data'] as Map<String, dynamic>;
    final orderId = responseData['order_id'] as int;
    AppLogger.info('[CreateOrder] Order created successfully with ID: $orderId');

    // Fetch full order details
    return await getOrderDetails(orderId);
  }

  /// Cancel an order
  Future<void> cancelOrder(int orderId, String reason) async {
    await apiClient.post(
      '/customer/orders/$orderId/cancel',
      data: {'reason': reason},
    );
  }

  /// Initiate payment for an order
  Future<Map<String, dynamic>> initiatePayment({
    required int orderId,
    required String provider,
  }) async {
    final response = await apiClient.post(
      '/customer/orders/$orderId/payment/initiate',
      data: {'provider': provider},
    );

    return response.data['data'] as Map<String, dynamic>;
  }

  /// Get tracking info manually (returns raw json for delivery part)
  Future<Map<String, dynamic>?> getTrackingInfo(int orderId) async {
    final response = await apiClient.get('/customer/orders/$orderId');
    final data = response.data['data'] as Map<String, dynamic>;
    if (data['delivery'] != null) {
      return data['delivery'] as Map<String, dynamic>;
    }
    return null;
  }
}
