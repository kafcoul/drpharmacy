import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_list_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${_order.reference}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOrderContent(currencyFormat),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, ref),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderContent(NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Card
        _buildStatusCard(),
        const SizedBox(height: 16),

        // Customer Info
        _buildSectionCard(
          title: 'Informations Client',
          icon: Icons.person,
          children: [
            _buildInfoRow('Nom', _order.customerName),
            _buildInfoRow('Téléphone', _order.customerPhone),
            if (_order.deliveryAddress != null)
              _buildInfoRow('Adresse', _order.deliveryAddress!),
          ],
        ),
        const SizedBox(height: 16),

        // Order Items
        if (_order.items != null && _order.items!.isNotEmpty) ...[
          _buildSectionCard(
            title: 'Produits commandés',
            icon: Icons.shopping_bag,
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(item.totalPrice),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
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
          children: [
            if (_order.subtotal != null)
              _buildInfoRow(
                'Sous-total',
                currencyFormat.format(_order.subtotal),
              ),
            if (_order.deliveryFee != null)
              _buildInfoRow(
                'Frais de livraison',
                currencyFormat.format(_order.deliveryFee),
              ),
            const Divider(),
            _buildInfoRow(
              'Total',
              currencyFormat.format(_order.totalAmount),
              isBold: true,
            ),
            _buildInfoRow('Mode de paiement', _getPaymentModeLabel()),
          ],
        ),
        const SizedBox(height: 16),

        // Notes
        if (_order.customerNotes != null &&
            _order.customerNotes!.isNotEmpty)
          _buildSectionCard(
            title: 'Notes du client',
            icon: Icons.note,
            children: [
              Text(_order.customerNotes!),
            ],
          ),
        const SizedBox(height: 24),

        // Action Buttons
        _buildActionButtons(context, ref),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _getStatusColor().withOpacity(0.1),
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
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
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
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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
            icon: const Icon(Icons.handshake),
            label: const Text('Confirmer le Retrait Client'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
               ref.read(orderListProvider.notifier).updateOrderStatus(_order.id, 'delivered');
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commande marquée comme livrée !')));
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
