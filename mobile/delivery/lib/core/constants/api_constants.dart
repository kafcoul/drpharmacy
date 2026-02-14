// ...existing code...
import '../config/app_config.dart';

class ApiConstants {
  /// Base URL - utilise la configuration centralisée
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String registerCourier = '/auth/register/courier';
  static const String updatePassword = '/auth/password';
  static const String updateProfile = '/auth/profile'; // For general updates if needed

  // Courier
  static const String profile = '/courier/profile';
  static const String availability = '/courier/availability/toggle';
  static const String location = '/courier/location/update';
  static const String deliveries = '/courier/deliveries';
  static const String wallet = '/courier/wallet';
  static const String walletTopUp = '/courier/wallet/topup';
  static const String walletWithdraw = '/courier/wallet/withdraw';
  static const String walletCanDeliver = '/courier/wallet/can-deliver';
  static const String walletEarningsHistory = '/courier/wallet/earnings-history';

  // Statistics
  static const String statistics = '/courier/statistics';
  static const String leaderboard = '/courier/statistics/leaderboard';

  // Challenges & Bonuses
  static const String challenges = '/courier/challenges';
  static const String bonuses = '/courier/bonuses';

  static String acceptDelivery(int id) => '/courier/deliveries/$id/accept';
  static String pickupDelivery(int id) => '/courier/deliveries/$id/pickup';
  static String completeDelivery(int id) =>
      '/courier/deliveries/$id/deliver';
  static String rejectDelivery(int id) => '/courier/deliveries/$id/reject';
  static String rateCustomer(int deliveryId) =>
      '/courier/deliveries/$deliveryId/rate-customer';
  
  // Batch deliveries
  static const String batchAcceptDeliveries = '/courier/deliveries/batch-accept';
  static const String deliveriesRoute = '/courier/deliveries/route';
  
  static String messages(int orderId) => '/courier/orders/$orderId/messages';
  
  // JEKO Payments
  static const String paymentsInitiate = '/courier/payments/initiate';
  static const String paymentsMethods = '/courier/payments/methods';
  static const String paymentsHistory = '/courier/payments';
  static String paymentStatus(String reference) => '/courier/payments/$reference/status';
  static String cancelPayment(String reference) => '/courier/payments/$reference/cancel';

  // Auth - Profile updates
  static const String updateMe = '/auth/me/update';

  // Challenges & Bonuses (dynamic)
  static String claimChallenge(int challengeId) => '/courier/challenges/$challengeId/claim';
  static const String calculateBonus = '/courier/bonuses/calculate';

  // Support
  static const String supportTickets = '/support/tickets';
  static const String supportTicketsStats = '/support/tickets/stats';
  static String supportTicketDetail(int id) => '/support/tickets/$id';
  static String supportTicketMessages(int id) => '/support/tickets/$id/messages';
  static String supportTicketResolve(int id) => '/support/tickets/$id/resolve';
  static String supportTicketClose(int id) => '/support/tickets/$id/close';
}
