import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/delivery.dart';
import '../../../data/models/route_info.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../providers/delivery_providers.dart';
import '../../screens/chat_screen.dart';
import 'delivery_dialogs.dart';

/// Panneau en bas de l'écran affichant la livraison active
class ActiveDeliveryPanel extends ConsumerWidget {
  final Delivery delivery;
  final RouteInfo? routeInfo;
  final VoidCallback onShowItinerary;

  const ActiveDeliveryPanel({
    super.key,
    required this.delivery,
    this.routeInfo,
    required this.onShowItinerary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusInfo = _getStatusInfo(context, ref);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status Header
            _buildStatusHeader(context, statusInfo),
            const SizedBox(height: 16),

            // Route Info
            _buildRouteInfo(context, statusInfo),

            const SizedBox(height: 24),

            // Main Action Button
            _buildActionButton(statusInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, _StatusInfo info) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: info.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          info.statusText.toUpperCase(),
          style: TextStyle(
            color: info.color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const Spacer(),
        if (routeInfo != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FloatingActionButton.small(
              heroTag: 'itinerary_btn',
              onPressed: onShowItinerary,
              backgroundColor: Theme.of(context).cardColor,
              shape: CircleBorder(side: BorderSide(color: Colors.blue.shade100)),
              elevation: 0,
              child: const Icon(Icons.list_alt, color: Colors.blue),
            ),
          ),
        FloatingActionButton.small(
          heroTag: 'nav_btn',
          onPressed: info.onNavigate,
          backgroundColor: Colors.blue.shade50,
          elevation: 0,
          child: const Icon(Icons.navigation, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(BuildContext context, _StatusInfo info) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.circle, size: 12, color: Colors.blue),
            Container(width: 2, height: 30, color: Colors.grey.shade300),
            const Icon(Icons.location_on, size: 12, color: Colors.red),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                delivery.pharmacyName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                delivery.customerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Column(
          children: [
            if (info.phoneToCall != null && info.phoneToCall!.isNotEmpty)
              IconButton(
                onPressed: () => _makePhoneCall(context, info.phoneToCall!),
                icon: const Icon(Icons.phone, color: Colors.green),
                tooltip: 'Appeler',
              ),
            IconButton(
              onPressed: () => _showChatOptions(context),
              icon: const Icon(Icons.chat_bubble, color: Colors.blue),
              tooltip: 'Message',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(_StatusInfo info) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: info.onAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: info.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          info.buttonText,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  _StatusInfo _getStatusInfo(BuildContext context, WidgetRef ref) {
    if (delivery.status == 'assigned' || delivery.status == 'accepted') {
      return _StatusInfo(
        statusText: 'En route vers la pharmacie',
        buttonText: 'CONFIRMER RÉCUPÉRATION',
        color: Colors.orange,
        phoneToCall: delivery.pharmacyPhone,
        onNavigate: () {
          if (delivery.pharmacyLat != null && delivery.pharmacyLng != null) {
            _launchNavigation(delivery.pharmacyLat!, delivery.pharmacyLng!);
          }
        },
        onAction: () async {
          try {
            await ref.read(deliveryRepositoryProvider).pickupDelivery(delivery.id);
            ref.invalidate(deliveriesProvider('active'));
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
            }
          }
        },
      );
    } else {
      return _StatusInfo(
        statusText: 'En route vers le client',
        buttonText: 'CONFIRMER LIVRAISON',
        color: Colors.green,
        phoneToCall: delivery.customerPhone,
        onNavigate: () {
          if (delivery.deliveryLat != null && delivery.deliveryLng != null) {
            _launchNavigation(delivery.deliveryLat!, delivery.deliveryLng!);
          }
        },
        onAction: () {
          DeliveryDialogs.showConfirmation(context, ref, delivery.id);
        },
      );
    }
  }

  Future<void> _launchNavigation(double lat, double lng) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanNumber.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro de téléphone invalide'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final Uri telUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      final canLaunch = await canLaunchUrl(telUri);
      if (canLaunch) {
        final launched = await launchUrl(telUri, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'appeler $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: impossible d\'appeler $phoneNumber'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Copier',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: phoneNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Numéro copié dans le presse-papier'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Discuter avec...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Colors.blue),
            title: const Text('Pharmacie'),
            subtitle: Text(delivery.pharmacyName),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    orderId: delivery.id,
                    target: 'pharmacy',
                    title: delivery.pharmacyName,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text('Client'),
            subtitle: Text(delivery.customerName),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    orderId: delivery.id,
                    target: 'customer',
                    title: delivery.customerName,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatusInfo {
  final String statusText;
  final String buttonText;
  final Color color;
  final String? phoneToCall;
  final VoidCallback onNavigate;
  final VoidCallback onAction;

  _StatusInfo({
    required this.statusText,
    required this.buttonText,
    required this.color,
    this.phoneToCall,
    required this.onNavigate,
    required this.onAction,
  });
}
