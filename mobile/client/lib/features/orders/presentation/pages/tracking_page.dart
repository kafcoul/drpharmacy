import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../../../config/providers.dart'; // Pour ordersRepositoryProvider
import '../../../../core/services/app_logger.dart';
import '../../../../core/constants/app_colors.dart';
import 'courier_chat_page.dart';

class TrackingPage extends ConsumerStatefulWidget {
  final int orderId;
  final DeliveryAddressEntity deliveryAddress;
  final String?
  pharmacyAddress; // Assuming we can get coordinates via geocoding or passed
  // Ideally, we need LatLng for pharmacy and delivery. Does OrderEntity have them?
  // OrderEntity has DeliveryAddressEntity which might have lat/lng?

  const TrackingPage({
    super.key,
    required this.orderId,
    required this.deliveryAddress,
    this.pharmacyAddress,
  });

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _courierPosition;
  Set<Marker> _markers = {};
  Timer? _timer;
  bool _isLoading = true;
  
  // Courier info
  int? _deliveryId;
  int? _courierId;
  String? _courierName;
  String? _courierPhone;

  // Mock coordinates if not available (Abidjan)
  static const LatLng _center = LatLng(5.3600, -4.0083);

  @override
  void initState() {
    super.initState();
    _fetchTrackingInfo();
    // Poll every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchTrackingInfo();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTrackingInfo() async {
    try {
      // We need a method in repo to get raw JSON or specifically tracking info
      // reusing getOrderDetails but accessing raw data via a new method in notifier/repo would be cleaner.
      // For now, let's assume we can get the updated order details via the provider.

      // Since OrderModel doesn't have courier lat/lng yet (we didn't run build runner),
      // we might need to add a specialized method in the repository or api client to fetch tracking data.

      // Let's rely on a direct API call or assume we added the method.
      // Since I cannot easily run build_runner, I will use a direct call in the widget (pragmatic approach)
      // or better: add a method to OrdersRepository that returns a Map<String, dynamic>.

      final trackingData = await ref
          .read(ordersRepositoryProvider)
          .getTrackingInfo(widget.orderId);

      if (trackingData != null) {
        // Extract delivery info
        final delivery = trackingData['delivery'];
        if (delivery != null) {
          _deliveryId = delivery['id'] as int?;
        }
        
        final courier = trackingData['courier'];
        if (courier != null) {
          _courierId = courier['id'] as int?;
          _courierName = courier['name'] as String?;
          _courierPhone = courier['phone'] as String?;
          
          if (courier['latitude'] != null) {
            final lat = double.parse(courier['latitude'].toString());
            final lng = double.parse(courier['longitude'].toString());

            setState(() {
              _courierPosition = LatLng(lat, lng);
              _updateMarkers();
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      AppLogger.warning('Error fetching tracking info: $e');
    }
  }

  void _updateMarkers() {
    _markers = {};

    // Add Delivery Location Marker
    if (widget.deliveryAddress.latitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            widget.deliveryAddress.latitude!,
            widget.deliveryAddress.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );
    }

    // Add Courier Marker
    if (_courierPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('courier'),
          position: _courierPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: _courierName ?? 'Livreur'),
        ),
      );
    }

    // Refresh UI
    setState(() {});
  }

  Future<void> _makePhoneCall() async {
    if (_courierPhone == null) return;
    final uri = Uri.parse('tel:$_courierPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp() async {
    if (_courierPhone == null) return;
    final phone = _courierPhone!.replaceAll(RegExp(r'[^\d+]'), '');
    final message = Uri.encodeComponent('Bonjour, je vous contacte concernant ma livraison.');
    final uri = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openChat() {
    if (_deliveryId == null || _courierId == null || _courierName == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourierChatPage(
          deliveryId: _deliveryId!,
          courierId: _courierId!,
          courierName: _courierName!,
          courierPhone: _courierPhone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de livraison'),
        backgroundColor: AppColors.primary,
      ),
      body: Stack(
        children: [
          // Map
          _isLoading && _courierPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target:
                        _courierPosition ??
                        (widget.deliveryAddress.latitude != null
                            ? LatLng(
                                widget.deliveryAddress.latitude!,
                                widget.deliveryAddress.longitude!,
                              )
                            : _center),
                    zoom: 14,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
          
          // Courier Info Card (bottom)
          if (_courierName != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Courier Info Row
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          radius: 24,
                          child: Icon(Icons.delivery_dining, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _courierName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Votre livreur',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        // Call Button
                        if (_courierPhone != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _makePhoneCall,
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Appeler'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        if (_courierPhone != null) const SizedBox(width: 8),
                        
                        // WhatsApp Button
                        if (_courierPhone != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openWhatsApp,
                              icon: const Icon(Icons.message, size: 18),
                              label: const Text('WhatsApp'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        if (_courierPhone != null) const SizedBox(width: 8),
                        
                        // Chat Button
                        if (_deliveryId != null && _courierId != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openChat,
                              icon: const Icon(Icons.chat, size: 18),
                              label: const Text('Chat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
