import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../../../config/providers.dart'; // Pour ordersRepositoryProvider
import '../../../../core/services/app_logger.dart';

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
        final courier = trackingData['courier'];
        if (courier != null && courier['latitude'] != null) {
          final lat = double.parse(courier['latitude'].toString());
          final lng = double.parse(courier['longitude'].toString());

          setState(() {
            _courierPosition = LatLng(lat, lng);
            _updateMarkers();
            _isLoading = false;
          });
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
          infoWindow: const InfoWindow(title: 'Livreur'),
        ),
      );
    }

    // Refresh UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de livraison')),
      body: _isLoading && _courierPosition == null
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
    );
  }
}
