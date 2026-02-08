import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_list_provider.dart';
import '../../../chat/presentation/pages/chat_page.dart';

class OrderDetailsPage extends ConsumerStatefulWidget {
  final OrderEntity order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends ConsumerState<OrderDetailsPage> {
  bool _isLoading = false;
  late OrderEntity _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _confirmOrder() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(orderListProvider.notifier).confirmOrder(_order.id);
      setState(() {
        _order = _order.copyWith(status: 'confirmed');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande confirmée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsReady() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(orderListProvider.notifier).markOrderReady(_order.id);
      setState(() {
        _order = _order.copyWith(status: 'ready');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande prête pour le ramassage'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_CI',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('Commande #${_order.reference}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOrderContent(currencyFormat, isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderContent(NumberFormat currencyFormat, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Card
        _buildStatusCard(isDark),
        const SizedBox(height: 16),

        // Courier Info (if assigned)
        if (_order.courierId != null) ...[
          _buildCourierCard(isDark),
          const SizedBox(height: 16),
        ],

        // Customer Info
        _buildSectionCard(
          title: 'Informations Client',
          icon: Icons.person,
          isDark: isDark,
          children: [
            _buildInfoRow('Nom', _order.customerName, isDark: isDark),
            _buildInfoRow('Téléphone', _order.customerPhone, isDark: isDark),
            if (_order.deliveryAddress != null)
              _buildInfoRow('Adresse', _order.deliveryAddress!, isDark: isDark),
          ],
        ),
        const SizedBox(height: 16),

        // Order Items
        if (_order.items != null && _order.items!.isNotEmpty) ...[
          _buildSectionCard(
            title: 'Produits commandés',
            icon: Icons.shopping_bag,
            isDark: isDark,
            children: [
              ..._order.items!.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black87),
                              ),
                              Text(
                                '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(item.totalPrice),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Order Summary
        _buildSectionCard(
          title: 'Résumé',
          icon: Icons.receipt,
          isDark: isDark,
          children: [
            if (_order.subtotal != null)
              _buildInfoRow(
                'Sous-total',
                currencyFormat.format(_order.subtotal),
                isDark: isDark,
              ),
            if (_order.deliveryFee != null)
              _buildInfoRow(
                'Frais de livraison',
                currencyFormat.format(_order.deliveryFee),
                isDark: isDark,
              ),
            Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
            _buildInfoRow(
              'Total',
              currencyFormat.format(_order.totalAmount),
              isBold: true,
              isDark: isDark,
            ),
            _buildInfoRow('Mode de paiement', _getPaymentModeLabel(), isDark: isDark),
          ],
        ),
        const SizedBox(height: 16),

        // Notes
        if (_order.customerNotes != null &&
            _order.customerNotes!.isNotEmpty)
          _buildSectionCard(
            title: 'Notes du client',
            icon: Icons.note,
            isDark: isDark,
            children: [
              Text(_order.customerNotes!, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87)),
            ],
          ),
        const SizedBox(height: 24),

        // Action Buttons
        _buildActionButtons(context, ref),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Card(
      color: isDark ? _getStatusColor().withOpacity(0.2) : _getStatusColor().withOpacity(0.1),
      elevation: isDark ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusLabel(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  Text(
                    'Créée le ${DateFormat('dd/MM/yyyy à HH:mm').format(_order.createdAt)}',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourierCard(bool isDark) {
    return Card(
      color: isDark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50,
      elevation: isDark ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 20,
                  child: const Icon(Icons.delivery_dining, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Livreur assigné',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.orange[300] : Colors.orange),
                      ),
                      Text(
                        _order.courierName ?? 'Coursier',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (_order.courierPhone != null)
                        Text(
                          _order.courierPhone!,
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Chat button with courier
            if (_order.deliveryId != null && _order.courierId != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('💬 Chat avec le livreur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          deliveryId: _order.deliveryId!,
                          participantType: 'courier',
                          participantId: _order.courierId!,
                          participantName: _order.courierName ?? 'Livreur',
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isDark = false,
  }) {
    return Card(
      color: isDark ? AppColors.darkCard : Colors.white,
      elevation: isDark ? 0 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isDark ? Colors.blue[300] : Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    if (_order.status == 'paid') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Commande Prête (Retrait)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                   ref.read(orderListProvider.notifier).updateOrderStatus(_order.id, 'ready');
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.motorcycle),
                label: const Text('Demander un Coursier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                    // Logic to assign courier
                    ref.read(orderListProvider.notifier).updateOrderStatus(_order.id, 'assigned'); // Mocking assignment prompt
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recherche de coursier lancée...')));
                },
              ),
            ),
          ],
        ),
      );
    }
    
    if (_order.status == 'ready' || _order.status == 'ready_for_pickup') {
       return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.handshake),
            label: Text(_isLoading ? 'Traitement...' : 'Confirmer le Retrait Client'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _isLoading ? null : () async {
              setState(() => _isLoading = true);
              try {
                await ref.read(orderListProvider.notifier).markOrderDelivered(_order.id);
                setState(() {
                  _order = _order.copyWith(status: 'delivered');
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Commande livrée avec succès !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getStatusLabel() {
    switch (_order.status) {
      case 'pending':
        return 'En attente de confirmation';
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'En préparation';
      case 'ready':
      case 'ready_for_pickup':
        return 'Prête pour ramassage';
      case 'on_the_way':
        return 'En cours de livraison';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return _order.status;
    }
  }

  Color _getStatusColor() {
    switch (_order.status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'preparing':
        return Colors.blue;
      case 'ready':
      case 'ready_for_pickup':
        return Colors.purple;
      case 'on_the_way':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_order.status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check;
      case 'preparing':
        return Icons.inventory;
      case 'ready':
      case 'ready_for_pickup':
        return Icons.local_shipping;
      case 'on_the_way':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getPaymentModeLabel() {
    switch (_order.paymentMode) {
      case 'platform':
        return 'Paiement en ligne';
      case 'on_delivery':
      case 'cash':
        return 'Paiement à la livraison';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        return _order.paymentMode;
    }
  }
}
