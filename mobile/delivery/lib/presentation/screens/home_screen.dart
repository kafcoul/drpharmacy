import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_html/flutter_html.dart' hide Marker;
import 'package:intl/intl.dart';
import '../../data/models/courier_profile.dart';
import '../../data/models/route_info.dart';
import '../../data/models/wallet_data.dart';
import '../../data/repositories/wallet_repository.dart';
import '../providers/delivery_providers.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../core/services/location_service.dart';
import 'chat_screen.dart';
import 'multi_route_screen.dart';

// Provider pour le solde du wallet sur l'écran d'accueil (même source que le profil)
final homeWalletProvider = FutureProvider.autoDispose<WalletData?>((ref) async {
  try {
    return await ref.read(walletRepositoryProvider).getWalletData();
  } catch (e) {
    return null;
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polylines = {};
  int? _lastDeliveryId;
  String? _lastStatus;
  bool _isFollowingUser = true;
  RouteInfo? _currentRouteInfo;
  
  // Abidjan coordinates as default
  static const CameraPosition _kAbidjan = CameraPosition(
    target: LatLng(5.3600, -4.0083),
    zoom: 14.4746,
  );

  bool _isOnline = false;
  bool _isTogglingStatus = false; // Indicateur de chargement pour le changement de statut

  @override
  void initState() {
    super.initState();
    // Sync local state with provider initial value if possible, 
    // but usually provider loads async. We'll rely on the consumer build.
  }

  Future<void> _toggleAvailability(bool value) async {
    // Empêcher les clics multiples pendant le chargement
    if (_isTogglingStatus) return;
    
    setState(() => _isTogglingStatus = true);
    
    try {
      // Optimistic update
      setState(() => _isOnline = value);
      
      // Envoie le statut souhaité explicitement pour éviter les désynchronisations
      final desiredStatus = value ? 'available' : 'offline';
      final actualStatus = await ref.read(deliveryRepositoryProvider).toggleAvailability(desiredStatus: desiredStatus);
      
      // Synchroniser avec le statut réel retourné par le serveur
      setState(() => _isOnline = actualStatus);
      ref.invalidate(profileProvider);

      final locationService = ref.read(locationServiceProvider);
      if (actualStatus) {
        locationService.startTracking();
      } else {
        locationService.stopTracking();
      }
    } catch (e) {
      // Revert on error
      setState(() => _isOnline = !value);
      if (mounted) {
        // Extraire le message d'erreur propre
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final activeDeliveriesAsync = ref.watch(deliveriesProvider('active'));

    // Update local state when provider data changes
    ref.listen<AsyncValue<CourierProfile>>(profileProvider, (prev, next) {
      if (next.hasValue) {
        setState(() => _isOnline = next.value!.status == 'available');
      }
    });

    // Listen to active deliveries to update route
    ref.listen<AsyncValue<List<dynamic>>>(deliveriesProvider('active'), (prev, next) {
      if (next.hasValue && next.value!.isNotEmpty) {
         final delivery = next.value!.first;
         if (delivery.id != _lastDeliveryId || delivery.status != _lastStatus) {
            _lastDeliveryId = delivery.id;
            _lastStatus = delivery.status;
            _updateRoute(delivery, null); 
         }
      } else if (next.hasValue && next.value!.isEmpty) {
         // Plus de livraison active - nettoyer l'état
         _lastDeliveryId = null;
         _lastStatus = null;
         _currentRouteInfo = null;
         if (_polylines.isNotEmpty) {
           setState(() => _polylines = {});
         }
      }
    });

    // Listen to location updates for live tracking
    ref.watch(locationStreamProvider);
    
    // Effect: Update camera when location changes
    ref.listen<AsyncValue<Position>>(locationStreamProvider, (prev, next) {
      if (next.hasValue && next.value != null && _isOnline && _isFollowingUser) {
        final pos = next.value!;
        final latLng = LatLng(pos.latitude, pos.longitude);
        
        _controller.future.then((controller) {
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: latLng,
              zoom: 17.0, // Zoom closer for navigation feeling
              bearing: pos.heading, // Rotate map with movement
              tilt: 45.0, // 3D effect
            ),
          ));
        });
      }
    });

    return Scaffold(
      body: activeDeliveriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
        data: (activeDeliveries) {
          final hasActiveDelivery = activeDeliveries.isNotEmpty;
          final activeDelivery = hasActiveDelivery ? activeDeliveries.first : null;

          // Prepare Markers & Polylines
          Set<Marker> markers = {};
          // Use our calculated polylines (Directions API) instead of manual straight line
          Set<Polyline> polylines = _polylines; 
          
          if (activeDelivery != null) {
              LatLng? pharmacyLoc;
              LatLng? customerLoc;

              if (activeDelivery.pharmacyLat != null && activeDelivery.pharmacyLng != null) {
                pharmacyLoc = LatLng(activeDelivery.pharmacyLat!, activeDelivery.pharmacyLng!);
                markers.add(Marker(
                  markerId: const MarkerId('pharmacy'),
                  position: pharmacyLoc,
                  infoWindow: const InfoWindow(title: 'Pharmacie'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                ));
              }

              if (activeDelivery.deliveryLat != null && activeDelivery.deliveryLng != null) {
                customerLoc = LatLng(activeDelivery.deliveryLat!, activeDelivery.deliveryLng!);
                markers.add(Marker(
                  markerId: const MarkerId('customer'),
                  position: customerLoc,
                  infoWindow: const InfoWindow(title: 'Client'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ));
              }

              // Add Courier Marker (simulated vehicle if needed, or rely on Blue Dot)
              // But for "Seeing displacement", let's ensure the blue dot is visible.
              // IF we want a custom icon (Motorbike), we would add it here using _currentPosition.
              
              // We also want to re-calculate route from MY position to destination periodically
              // But for now, stationary route is safer to avoid flickering.
          }

          return Stack(
            children: [
              // 1. MAP BACKGROUND
              _buildMap(markers: markers, polylines: polylines),

              // Re-Center Button (Floating)
              if (_isOnline && !_isFollowingUser)
                Positioned(
                  right: 16,
                  bottom: hasActiveDelivery ? 200 : 120,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_btn',
                    onPressed: () => setState(() => _isFollowingUser = true),
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.gps_fixed, color: Colors.blue),
                  ),
                ),

              // Multi-Route Button (Quand plusieurs livraisons actives)
              if (activeDeliveries.length > 1)
                Positioned(
                  right: 16,
                  bottom: 260,
                  child: FloatingActionButton.extended(
                    heroTag: 'multi_route_btn',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MultiRouteScreen(),
                        ),
                      );
                    },
                    backgroundColor: Colors.deepPurple,
                    icon: const Icon(Icons.route, color: Colors.white),
                    label: Text(
                      '${activeDeliveries.length} livraisons',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // 2. OVERLAY FOR OFFLINE STATE
              if (!_isOnline && !hasActiveDelivery)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 80, color: Colors.white54),
                        const SizedBox(height: 20),
                        const Text(
                          'VOUS ÊTES HORS LIGNE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Passez en ligne pour recevoir des commandes',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. TOP STATUS BAR (Earnings & Status)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Wallet Balance Pill - Using same source as profile screen
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.monetization_on, size: 18, color: Colors.green.shade700),
                              const SizedBox(width: 6),
                              // Use wallet balance (same as profile screen) for consistency
                              Consumer(
                                builder: (context, ref, _) {
                                  final walletAsync = ref.watch(homeWalletProvider);
                                  return walletAsync.when(
                                    data: (walletData) {
                                      final balance = walletData?.balance ?? 0;
                                      final balanceFormatted = NumberFormat("#,##0", "fr_FR").format(balance);
                                      return Text(
                                        '$balanceFormatted FCFA', 
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      );
                                    },
                                    loading: () => SizedBox(
                                      width: 60,
                                      child: LinearProgressIndicator(
                                        minHeight: 8,
                                        color: Colors.green.shade300,
                                        backgroundColor: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    error: (error, stack) => Text(
                                      '--- FCFA', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        // Profile/Status
                        profileAsync.when(
                          data: (profile) => Row(
                            children: [
                              Text(
                                profile.name.split(' ').first,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(Icons.person, size: 20, color: Colors.blue),
                              ),
                            ],
                          ),
                          loading: () => const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2)
                          ),
                          error: (error, stack) => const Icon(Icons.error_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. BOTTOM ACTION BUTTON (GO ONLINE)
              if (!hasActiveDelivery)
              Positioned(
                bottom: 30,
                left: 40,
                right: 40,
                child: GestureDetector(
                  onTap: _isTogglingStatus ? null : () => _toggleAvailability(!_isOnline),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isTogglingStatus 
                          ? Colors.grey.shade400
                          : (_isOnline ? Colors.red.shade400 : Colors.green.shade600),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _isTogglingStatus 
                              ? Colors.grey.withValues(alpha: 0.3)
                              : ((_isOnline ? Colors.red : Colors.green).withValues(alpha: 0.4)),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: _isTogglingStatus
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'CHANGEMENT EN COURS...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isOnline ? Icons.power_settings_new : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isOnline ? 'PASSER HORS LIGNE' : 'PASSER EN LIGNE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              
              // 5. FINDING ORDERS ANIMATION (When Online)
              if (_isOnline && !hasActiveDelivery) ...[
                // Status Indicator
                Positioned(
                  bottom: 110,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 12, height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recherche de commandes...',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // NEW ORDER ALERT CARD
                _buildIncomingOrderCard(ref), 
              ],

              // 6. ACTIVE DELIVERY PANEL
              if (hasActiveDelivery)
                 _buildActiveDeliveryPanel(context, ref, activeDelivery),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIncomingOrderCard(WidgetRef ref) {
    // Listen to pending deliveries
    final deliveriesAsync = ref.watch(deliveriesProvider('pending'));

    return deliveriesAsync.when(
      data: (deliveries) {
        if (deliveries.isEmpty) return const SizedBox.shrink();

        // Get the oldest pending delivery
        final delivery = deliveries.first;

        return Positioned(
          top: 100,
          left: 16,
          right: 16,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NOUVELLE COURSE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Commande prête !',
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '${delivery.totalAmount} F',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.store, size: 18, color: Colors.white70),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  delivery.pharmacyName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18, color: Colors.white70),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  delivery.deliveryAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, height: 1.3, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(deliveryRepositoryProvider)
                                    .rejectDelivery(delivery.id);
                                ref.invalidate(deliveriesProvider('pending'));
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Course ignorée')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e')),
                                  );
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('IGNORER', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(deliveryRepositoryProvider)
                                    .acceptDelivery(delivery.id);
                                ref.invalidate(deliveriesProvider('pending'));
                                ref.invalidate(deliveriesProvider('active'));
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Course acceptée !'),
                                      backgroundColor: Color(0xFF2E7D32),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1B5E20),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('ACCEPTER', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                SizedBox(width: 8),
                                Icon(Icons.check_circle, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Future<void> _launchNavigation(double lat, double lng) async {
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
       await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Impossible d\'ouvrir la navigation')),
         );
       }
    }
  }

  Widget _buildMap({Set<Marker>? markers, Set<Polyline>? polylines}) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kAbidjan,
      myLocationEnabled: true,
      myLocationButtonEnabled: false, // We use custom logic
      zoomControlsEnabled: false,
      markers: markers ?? {},
      polylines: polylines ?? {},
      onCameraMoveStarted: () {
         // If user touches map, stop following automatically
         // We might need a better heuristic, but this is simple.
         // _isFollowingUser = false; 
         // Actually onCameraMoveStarted is triggered by animations too.
         // Use gesture recognizers if needed, but let's keep it simple: 
         // allow user to pan, but snap back on next location update IF _isFollowingUser is true.
         // If they want to stop, they should toggle a button. 
         // For now, let's assume "Navigation Mode" means Always Follow.
      },
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
    );
  }

  Widget _buildActiveDeliveryPanel(BuildContext context, WidgetRef ref, dynamic delivery) {
    // Determine status text and button action
    String statusText = '';
    String buttonText = '';
    VoidCallback onAction = () {};
    VoidCallback onNavigate = () {};
    String? phoneToCall;
    Color statusColor = Colors.blue;

    if (delivery.status == 'assigned' || delivery.status == 'accepted') {
      statusText = 'En route vers la pharmacie';
      buttonText = 'CONFIRMER RÉCUPÉRATION';
      statusColor = Colors.orange;
      phoneToCall = delivery.pharmacyPhone;
      onNavigate = () {
        if (delivery.pharmacyLat != null && delivery.pharmacyLng != null) {
          _launchNavigation(delivery.pharmacyLat!, delivery.pharmacyLng!);
        }
      };
      onAction = () async {
        try {
           await ref.read(deliveryRepositoryProvider).pickupDelivery(delivery.id);
           ref.invalidate(deliveriesProvider('active'));
        } catch(e) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      };
    } else if (delivery.status == 'picked_up') {
      statusText = 'En route vers le client';
      buttonText = 'CONFIRMER LIVRAISON';
      statusColor = Colors.green;
      phoneToCall = delivery.customerPhone;
      onNavigate = () {
        if (delivery.deliveryLat != null && delivery.deliveryLng != null) {
          _launchNavigation(delivery.deliveryLat!, delivery.deliveryLng!);
        }
      };
      onAction = () {
        _showDeliveryConfirmationDialog(context, ref, delivery.id);
      };
    }

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
            Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                // ITINERARY BUTTON (Preview)
                if (_currentRouteInfo != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FloatingActionButton.small(
                    heroTag: 'itinerary_btn',
                    onPressed: () => _showItinerarySheet(),
                    backgroundColor: Theme.of(context).cardColor,
                    shape: CircleBorder(side: BorderSide(color: Colors.blue.shade100)),
                    elevation: 0,
                    child: const Icon(Icons.list_alt, color: Colors.blue),
                  ),
                ),
                // NAVIGATION BUTTON
                FloatingActionButton.small(
                  heroTag: 'nav_btn',
                  onPressed: onNavigate,
                  backgroundColor: Colors.blue.shade50,
                  elevation: 0,
                  child: const Icon(Icons.navigation, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Route Info
            Row(
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
                // Actions
                Column(
                  children: [
                    if (phoneToCall != null && phoneToCall.isNotEmpty)
                    IconButton(
                      onPressed: () => _makePhoneCall(context, phoneToCall!),
                      icon: const Icon(Icons.phone, color: Colors.green),
                      tooltip: 'Appeler',
                    ),
                    IconButton(
                      onPressed: () => _showChatOptions(context, delivery),
                      icon: const Icon(Icons.chat_bubble, color: Colors.blue),
                      tooltip: 'Message',
                    ),
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Main Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliverySuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'Livraison Terminée !',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Excellent travail ! La commission de 200 FCFA a été déduite de votre wallet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Commission: -200 FCFA',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('CONTINUER', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryConfirmationDialog(BuildContext context, WidgetRef ref, int deliveryId) {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Code de confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Demandez le code au client pour valider la livraison.'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '0000',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = otpController.text.trim();
              if (code.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le code doit contenir 4 chiffres')),
                );
                return;
              }
              
              try {
                await ref.read(deliveryRepositoryProvider).completeDelivery(
                  deliveryId, 
                  code,
                );
                
                // Fermer le dialog de confirmation
                if (mounted) Navigator.pop(ctx);
                
                // Force refresh des providers (pas juste invalidate)
                ref.invalidate(deliveriesProvider('active'));
                ref.invalidate(deliveriesProvider('history'));
                
                // Afficher le dialogue de succès avec animation
                if (mounted) {
                  _showDeliverySuccessDialog(context);
                }
              } catch(e) {
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('VALIDER'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRoute(dynamic delivery, LatLng? myLocation) async {
    if (delivery == null) {
      if (_polylines.isNotEmpty) setState(() => _polylines = {});
      return;
    }

    // Determine Origin and Destination based on status
    LatLng? origin;
    LatLng? destination;

    if (delivery.status == 'assigned' || delivery.status == 'accepted') {
       // From Me (or saved location) to Pharmacy
       // For better UX, we should use real-time location, but for visual stability, 
       // let's use the location when we accepted or just refresh if we have myLocation.
       origin = myLocation ?? const LatLng(5.3600, -4.0083); // Fallback to Abidjan center
       if (delivery.pharmacyLat != null && delivery.pharmacyLng != null) {
         destination = LatLng(delivery.pharmacyLat!, delivery.pharmacyLng!);
       }
    } else if (delivery.status == 'picked_up') {
       // From Pharmacy to Customer
       if (delivery.pharmacyLat != null && delivery.pharmacyLng != null) {
          origin = LatLng(delivery.pharmacyLat!, delivery.pharmacyLng!);
       }
       if (delivery.deliveryLat != null && delivery.deliveryLng != null) {
          destination = LatLng(delivery.deliveryLat!, delivery.deliveryLng!);
       }
    }

    if (origin != null && destination != null) {
       final routeService = ref.read(routeServiceProvider);
       final routeInfo = await routeService.getRouteInfo(origin, destination);
       
       if (routeInfo != null && mounted) {
          setState(() {
            _currentRouteInfo = routeInfo;
            final points = routeInfo.points.cast<LatLng>();
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                points: points,
                color: Colors.blue,
                width: 5,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
            
            // Fit camera to route
            _fitBounds(points);
          });
       }
    }
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    if (points.isEmpty) return;
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      50, // padding
    ));
  }

  /// Effectue un appel téléphonique avec gestion d'erreur
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    // Nettoyer le numéro de téléphone (enlever espaces, tirets, etc.)
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
      // Essayer d'abord avec canLaunchUrl
      final canLaunch = await canLaunchUrl(telUri);
      
      if (canLaunch) {
        final launched = await launchUrl(
          telUri, 
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'appeler $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Tenter quand même le lancement (certains appareils retournent false mais fonctionnent)
        await launchUrl(
          telUri, 
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel: $e');
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

  void _showChatOptions(BuildContext context, dynamic delivery) {
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

  void _showItinerarySheet() {
    if (_currentRouteInfo == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20, top: 8),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Itinéraire', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    '${_currentRouteInfo!.totalDistance} • ${_currentRouteInfo!.totalDuration}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              const Divider(height: 30),
              Expanded(
                child: ListView.separated(
                  controller: controller, // Needed for DraggableScrollableSheet
                  itemCount: _currentRouteInfo!.steps.length,
                  itemBuilder: (context, index) {
                    final step = _currentRouteInfo!.steps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const Icon(Icons.directions, color: Colors.grey, size: 20),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                Html(
                                  data: step.instruction,
                                  style: {
                                    "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero, fontSize: FontSize(14)),
                                    "b": Style(fontWeight: FontWeight.bold),
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${step.distance} • ${step.duration}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                )
                               ],
                             ),
                           )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
