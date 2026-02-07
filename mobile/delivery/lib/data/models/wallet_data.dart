class WalletData {
  final double balance;
  final String currency;
  final List<WalletTransaction> transactions;
  final double? pendingPayouts;
  final double? availableBalance;
  final bool canDeliver;
  final int commissionAmount;
  final double totalTopups;
  final double totalEarnings;
  final double totalCommissions;
  final int deliveriesCount;

  WalletData({
    required this.balance,
    required this.currency,
    required this.transactions,
    this.pendingPayouts,
    this.availableBalance,
    this.canDeliver = true,
    this.commissionAmount = 200,
    this.totalTopups = 0,
    this.totalEarnings = 0,
    this.totalCommissions = 0,
    this.deliveriesCount = 0,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      balance: double.parse(json['balance'].toString()),
      currency: json['currency'] ?? 'XOF',
      transactions: (json['transactions'] as List? ?? [])
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
      pendingPayouts: json['pending_payouts'] != null 
          ? double.tryParse(json['pending_payouts'].toString()) 
          : 0.0,
      availableBalance: json['available_balance'] != null
          ? double.tryParse(json['available_balance'].toString())
          : null,
      canDeliver: json['can_deliver'] ?? true,
      commissionAmount: json['commission_amount'] ?? 200,
      totalTopups: json['total_topups'] != null 
          ? double.tryParse(json['total_topups'].toString()) ?? 0
          : 0,
      totalEarnings: json['total_earnings'] != null 
          ? double.tryParse(json['total_earnings'].toString()) ?? 0
          : 0,
      totalCommissions: json['total_commissions'] != null 
          ? double.tryParse(json['total_commissions'].toString()) ?? 0
          : 0,
      deliveriesCount: json['deliveries_count'] ?? 0,
    );
  }
}

class WalletTransaction {
  final int id;
  final double amount;
  final String type; // 'credit' | 'debit'
  final String? category; // 'topup', 'commission', 'withdrawal', etc.
  final String? description;
  final String? reference;
  final String? status;
  final int? deliveryId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.category,
    this.description,
    this.reference,
    this.status,
    this.deliveryId,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      type: json['type']?.toString().toLowerCase() ?? 'debit',
      category: json['category'],
      description: json['description'],
      reference: json['reference'],
      status: json['status'],
      deliveryId: json['delivery_id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now()),
    );
  }

  bool get isCredit => type == 'credit';
  bool get isCommission => category == 'commission';
  bool get isTopUp => category == 'topup';
  bool get isWithdrawal => category == 'withdrawal';
}
