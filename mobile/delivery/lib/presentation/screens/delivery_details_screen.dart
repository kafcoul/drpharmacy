import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/location_service.dart';
import '../../data/models/delivery.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../core/network/api_client.dart';

class DeliveryDetailsScreen extends ConsumerStatefulWidget {
  final Delivery delivery;

  const DeliveryDetailsScreen({super.key, required this.delivery});

  @override
  ConsumerState<DeliveryDetailsScreen> createState() =>
      _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends ConsumerState<DeliveryDetailsScreen> {
  final Set<Marker> _staticMarkers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupMarkers();
  }

  void _setupMarkers() {
    // ...existing code...
    if (widget.delivery.pharmacyLat != null &&
        widget.delivery.pharmacyLng != null) {
      _staticMarkers.add(
        Marker(
          markerId: const MarkerId('pharmacy'),
          position: LatLng(
            widget.delivery.pharmacyLat!,
            widget.delivery.pharmacyLng!,
          ),
          infoWindow: InfoWindow(
            title: widget.delivery.pharmacyName,
            snippet: 'Pharmacie (Récupération)',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (widget.delivery.deliveryLat != null &&
        widget.delivery.deliveryLng != null) {
      _staticMarkers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: LatLng(
            widget.delivery.deliveryLat!,
            widget.delivery.deliveryLng!,
          ),
          infoWindow: InfoWindow(
            title: widget.delivery.customerName,
            snippet: 'Client (Livraison)',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    final navApp = prefs.getString('navigation_app') ?? 'google_maps';
    
    Uri? uri;
    
    if (navApp == 'waze') {
      uri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
    } else if (navApp == 'apple_maps') {
      uri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');
    } else {
      // Google Maps (Default)
      uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    }

    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        launched = true;
      }
    } catch (e) {
      // Ignore initial launch errors
    }
    
    // Fallback logic if preferred app is not installed
    if (!launched) {
       // 1. Try Google Maps Universal Link (Web/App fallback)
       final googleWeb = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
       // 2. Try Apple Maps (iOS fallback)
       final appleMaps = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');

       if (await canLaunchUrl(googleWeb)) {
         await launchUrl(googleWeb);
       } else if (await canLaunchUrl(appleMaps)) {
         await launchUrl(appleMaps);
       } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Impossible de lancer la navigation avec $navApp.')),
            );
         }
       }
    }
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Numéro de téléphone non disponible')),
          );
        }
        return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de passer l\'appel.')),
        );
      }
    }
  }

  /// Ouvrir WhatsApp avec un message pré-rempli
  Future<void> _openWhatsApp(String? phoneNumber, {String? recipientName, bool isPharmacy = true}) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Numéro WhatsApp non disponible')),
        );
      }
      return;
    }
    
    // Nettoyer le numéro (enlever espaces, tirets, etc.)
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Si le numéro ne commence pas par +, ajouter le code pays Côte d'Ivoire
    if (!cleanPhone.startsWith('+')) {
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '+225${cleanPhone.substring(1)}';
      } else {
        cleanPhone = '+225$cleanPhone';
      }
    }
    
    // Message pré-rempli selon le destinataire
    final orderRef = widget.delivery.reference;
    String message;
    if (isPharmacy) {
      message = 'Bonjour, je suis le livreur pour la commande $orderRef. ';
    } else {
      message = 'Bonjour ${recipientName ?? ''}, je suis votre livreur pour la commande $orderRef. ';
    }
    
    // Encoder le message pour l'URL
    final encodedMessage = Uri.encodeComponent(message);
    
    // Essayer d'abord wa.me (fonctionne sur tous les appareils)
    final waUrl = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');
    
    if (await canLaunchUrl(waUrl)) {
      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: essayer le schéma whatsapp://
      final whatsappUrl = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMessage');
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp n\'est pas installé sur cet appareil')),
          );
        }
      }
    }
  }

  /// Vérifier le solde avant de permettre la livraison
  Future<bool> _checkBalanceForDelivery() async {
    try {
      final walletRepo = ref.read(walletRepositoryProvider);
      final result = await walletRepo.canDeliver();
      
      final bool canDeliver = result['can_deliver'] ?? false;
      final double balance = (result['balance'] ?? 0).toDouble();
      final double required = (result['commission_amount'] ?? 200).toDouble();

      if (!canDeliver) {
        if (!mounted) return false;
        
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.orange.shade700,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Solde Insuffisant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre solde actuel (${balance.toStringAsFixed(0)} FCFA) ne couvre pas la commission de ${required.toStringAsFixed(0)} FCFA.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rechargez votre wallet pour continuer à livrer.',
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Plus tard'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Naviguer vers l'écran wallet
                          Navigator.pushNamed(context, '/wallet');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Recharger'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        return false;
      }
      
      return true;
    } catch (e) {
      // En cas d'erreur de vérification, on montre un avertissement
      // mais on permet quand même de continuer (backend vérifiera)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impossible de vérifier le solde, vérification côté serveur...'),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }
      return true; // On laisse le backend gérer
    }
  }

  Future<void> _updateStatus(String action) async {
    String? confirmationCode;

    // Si c'est pour livrer, vérifier le solde d'abord
    if (action == 'deliver') {
      // Vérifier le solde avant de permettre la livraison
      final canDeliverResult = await _checkBalanceForDelivery();
      if (!canDeliverResult) return;

      confirmationCode = await _showConfirmationDialog();
      // Si pas de code, on annule l'action (retour)
      if (confirmationCode == null) return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(deliveryRepositoryProvider);
      
      switch (action) {
        case 'accept':
          await repo.acceptDelivery(widget.delivery.id);
          break;
        case 'pickup':
          await repo.pickupDelivery(widget.delivery.id);
          break;
        case 'deliver':
          await repo.completeDelivery(widget.delivery.id, confirmationCode!);
          break;
        default:
          throw Exception('Action inconnue');
      }

        if (!mounted) return;

        if (action == 'deliver') {
          // Success Feedback
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
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
                    const Text('Livraison Terminée !', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close details
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('CONTINUER', style: TextStyle(fontWeight: FontWeight.bold))
                      ),
                    )
                ],
              ),
            )
          );
        } else {
           Navigator.pop(context);
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _showConfirmationDialog() async {
    final codeController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Text('Demandez le code de confirmation au client pour valider la livraison.'),
             const SizedBox(height: 16),
             TextField(
               controller: codeController,
               keyboardType: TextInputType.number,
               maxLength: 4,
               textAlign: TextAlign.center,
               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
               decoration: const InputDecoration(
                 hintText: '----',
                 border: OutlineInputBorder(),
                 counterText: '',
               ),
             ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
               if (codeController.text.length == 4) {
                 Navigator.pop(context, codeController.text);
               }
            },
            child: const Text('Valider'),
          ),
        ],
      )
    );
  }

  Future<void> _cancelDelivery() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Motif d\'annulation'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, "Problème mécanique"),
            child: const Padding(padding: EdgeInsets.all(8.0), child: Text("Problème mécanique")),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, "Accident"),
            child: const Padding(padding: EdgeInsets.all(8.0), child: Text("Accident")),
          ),
          SimpleDialogOption(
             onPressed: () => Navigator.pop(context, "Client injoignable"),
            child: const Padding(padding: EdgeInsets.all(8.0), child: Text("Client injoignable")),
          ),
           SimpleDialogOption(
             onPressed: () => Navigator.pop(context, "Autre"),
            child: const Padding(padding: EdgeInsets.all(8.0), child: Text("Autre")),
          ),
        ],
      ),
    );

    if (reason != null && mounted) {
      try {
        // Envoi au backend (via SupportTicket car c'est un incident)
        // On pourrait créer un endpoint spécifique /report-incident mais /report-problem fait l'affaire
        // ou utiliser une nouvelle méthode reportIncident dans le repository
        final dio = ref.read(dioProvider);
        await dio.post('/courier/report-problem', data: {
          'category': 'delivery',
          'subject': 'Incident Livraison #${widget.delivery.id}',
          'description': 'Motif: $reason',
          'metadata': {'delivery_id': widget.delivery.id, 'reason': reason}
        });

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Incident signalé: $reason. Le support a été prévenu.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur envoi signalement: $e')),
          );
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // Default to Abidjan if no coords
    final initialPos = widget.delivery.pharmacyLat != null
        ? LatLng(widget.delivery.pharmacyLat!, widget.delivery.pharmacyLng!)
        : const LatLng(5.3600, -4.0083);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Full Screen Map
          StreamBuilder<Position>(
            stream: ref.watch(locationServiceProvider).locationStream,
            builder: (context, snapshot) {
              final Set<Marker> currentMarkers = Set.from(_staticMarkers);

              if (snapshot.hasData) {
                final position = snapshot.data!;
                currentMarkers.add(
                  Marker(
                    markerId: const MarkerId('courier'),
                    position: LatLng(position.latitude, position.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                    infoWindow: const InfoWindow(
                      title: 'Moi',
                      snippet: 'Position actuelle',
                    ),
                    rotation: position.heading,
                  ),
                );
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPos,
                  zoom: 14,
                ),
                markers: currentMarkers,
                onMapCreated: (controller) {},
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                padding: const EdgeInsets.only(bottom: 250), // Padding for bottom sheet
              );
            },
          ),

          // 2. Sliding Detail Panel
          DraggableScrollableSheet(
            initialChildSize: 0.50,
            minChildSize: 0.25,
            maxChildSize: 0.90,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.26), // Updated from 26
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Scrollable Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          _buildTimeline(),
                          const SizedBox(height: 20),
                          _buildPaymentInfo(),
                          const SizedBox(height: 24),
                          // Action Buttons INSIDE the scroll (not floating)
                          _buildActionButtons(),
                          const SizedBox(height: 30), // Bottom safe area
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #${widget.delivery.reference}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.delivery.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20), // Capsule shape
                  ),
                  child: Text(
                    _getStatusText(widget.delivery.status),
                    style: TextStyle(
                      color: _getStatusColor(widget.delivery.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: Colors.blue, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        // Pharmacy (Pickup)
        _buildTimelineItem(
          title: 'Pharmacie',
          name: widget.delivery.pharmacyName,
          address: widget.delivery.pharmacyAddress,
          icon: Icons.store_mall_directory_outlined,
          color: Colors.blue,
          isFirst: true,
          phone: widget.delivery.pharmacyPhone,
          lat: widget.delivery.pharmacyLat,
          lng: widget.delivery.pharmacyLng,
          isPharmacy: true,
        ),
        // Connector Line
        Container(
          height: 30,
          margin: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid)),
          ),
        ),
        // Customer (Dropoff)
        _buildTimelineItem(
          title: 'Client',
          name: widget.delivery.customerName,
          address: widget.delivery.deliveryAddress,
          icon: Icons.person_outline,
          color: Colors.orange,
          isLast: true,
          phone: widget.delivery.customerPhone,
          lat: widget.delivery.deliveryLat,
          lng: widget.delivery.deliveryLng,
          isPharmacy: false,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String name,
    required String address,
    required IconData icon,
    required Color color,
    required double? lat,
    required double? lng,
    String? phone,
    bool isFirst = false,
    bool isLast = false,
    bool isPharmacy = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(address, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                   if (lat != null && lng != null)
                  _SmallActionButton(
                    icon: Icons.navigation_outlined,
                    label: 'Y aller',
                    color: Colors.blue.shade700,
                    onTap: () => _launchMaps(lat, lng),
                  ),
                  if (phone != null && phone.isNotEmpty)
                  _SmallActionButton(
                    icon: Icons.phone_outlined,
                    label: 'Appeler',
                    color: Colors.green.shade700,
                    onTap: () => _makePhoneCall(phone),
                  ),
                  if (phone != null && phone.isNotEmpty)
                  _SmallActionButton(
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366), // Couleur WhatsApp
                    onTap: () => _openWhatsApp(phone, recipientName: name, isPharmacy: isPharmacy),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    final isPending = widget.delivery.status == 'pending';
    final deliveryFee = widget.delivery.deliveryFee ?? 500;
    final commission = widget.delivery.commission ?? 200;
    final estimatedEarnings = widget.delivery.estimatedEarnings ?? (deliveryFee - commission);
    final distanceKm = widget.delivery.distanceKm;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant total client
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total à la livraison:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                '${widget.delivery.totalAmount.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          
          // Afficher les gains estimés pour les courses en attente
          if (isPending) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.monetization_on, color: Colors.green.shade700, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vos gains estimés',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${estimatedEarnings.toStringAsFixed(0)} FCFA',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Détail du calcul
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildEarningsRow(
                          'Frais de livraison',
                          '+${deliveryFee.toStringAsFixed(0)} FCFA',
                          Colors.black87,
                        ),
                        const SizedBox(height: 6),
                        _buildEarningsRow(
                          'Commission plateforme',
                          '-${commission.toStringAsFixed(0)} FCFA',
                          Colors.red.shade600,
                        ),
                        if (distanceKm != null) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          _buildEarningsRow(
                            'Distance estimée',
                            '${distanceKm.toStringAsFixed(1)} km',
                            Colors.blue.shade700,
                            icon: Icons.straighten,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildEarningsRow(String label, String value, Color valueColor, {IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
            ],
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isLoading) {
       return const Padding(
         padding: EdgeInsets.symmetric(vertical: 16),
         child: Center(child: CircularProgressIndicator()),
       );
    }

    String label;
    Color color;
    IconData icon;
    String action;

    switch (widget.delivery.status) {
      case 'pending':
        label = 'Accepter la course';
        color = Colors.green;
        icon = Icons.check_circle_outline;
        action = 'accept';
        break;
      case 'assigned':
        label = 'Confirmer récupération';
        color = Colors.blue;
        icon = Icons.store_mall_directory_outlined;
        action = 'pickup';
        break;
      case 'picked_up':
        label = 'Confirmer la livraison';
        color = Colors.orange.shade800;
        icon = Icons.local_shipping_outlined;
        action = 'deliver';
        break;
      default:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade400, size: 20),
              const SizedBox(width: 8),
              Text('Course terminée', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            ],
          ),
        );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Action Button - compact height
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: Icon(icon, color: Colors.white, size: 20),
            label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: () => _updateStatus(action),
          ),
        ),
        // Problem/Cancel - text button, minimal space
        if (widget.delivery.status != 'delivered')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: _cancelDelivery,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade300, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Signaler un problème / Annuler',
                    style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'assigned': return Colors.blue;
      case 'picked_up': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'En Attente';
      case 'assigned': return 'Assignée - En route Pharma';
      case 'picked_up': return 'En Livraison - Vers Client';
      case 'delivered': return 'Livrée';
      case 'cancelled': return 'Annulée';
      default: return status;
    }
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08), // Softer background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
