import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import 'delivery_details_screen.dart';
import 'batch_deliveries_screen.dart';
import '../providers/delivery_providers.dart';
import 'package:intl/intl.dart';

class DeliveriesScreen extends ConsumerStatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  ConsumerState<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends ConsumerState<DeliveriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les changements de thème
    ref.watch(themeProvider);
    final isDark = context.isDark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text('Mes Courses', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        actions: [
          // Batch mode button
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BatchDeliveriesScreen()),
              );
            },
            icon: const Icon(Icons.layers, size: 20),
            label: const Text('Multi'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBar(),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: isDark ? Colors.white : Colors.black,
                  unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.05),
                         blurRadius: 4,
                         offset: const Offset(0, 2),
                       )
                    ],
                  ),
                  indicatorPadding: const EdgeInsets.all(4),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Disponibles'),
                    Tab(text: 'En Cours'),
                    Tab(text: 'Terminées'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DeliveryList(status: 'pending', searchQuery: _searchQuery),
          DeliveryList(status: 'active', searchQuery: _searchQuery),
          DeliveryList(status: 'history', searchQuery: _searchQuery),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Rechercher #REF, Pharmacie...',
          prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14), 
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class DeliveryList extends ConsumerWidget {
  final String status;
  final String searchQuery;

  const DeliveryList({super.key, required this.status, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesFuture = ref.watch(deliveriesProvider(status));

    return deliveriesFuture.when(
      data: (allDeliveries) {
        // Filter locally
        final deliveries = allDeliveries.where((d) {
          if (searchQuery.isEmpty) return true;
          return d.pharmacyName.toLowerCase().contains(searchQuery.toLowerCase()) || 
                 d.id.toString().contains(searchQuery);
        }).toList();

        if (deliveries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Aucune course trouvée', style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deliveries.length,
          itemBuilder: (context, index) {
            final delivery = deliveries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => DeliveryDetailsScreen(delivery: delivery)),
                   );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${delivery.id}', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                            ),
                          ),
                          Text(
                            delivery.createdAt != null 
                              ? DateFormat('dd/MM HH:mm').format(DateTime.tryParse(delivery.createdAt!) ?? DateTime.now())
                              : '',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const CircleAvatar(radius: 16, backgroundColor: Colors.orange, child: Icon(Icons.store, color: Colors.white, size: 16)),
                          const SizedBox(width: 12),
                          Expanded(
                             child: Text(delivery.pharmacyName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 20, 
                            decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade300)))
                          ),
                        ),
                      ),
                       Row(
                        children: [
                          const CircleAvatar(radius: 16, backgroundColor: Colors.green, child: Icon(Icons.location_on, color: Colors.white, size: 16)),
                          const SizedBox(width: 12),
                          Expanded(
                             child: Text(delivery.deliveryAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${delivery.totalAmount} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          _buildStatusBadge(delivery.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erreur: $e')),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch(status) {
      case 'pending': color = Colors.orange; text = 'En attente'; break;
      case 'active': color = Colors.blue; text = 'En cours'; break;
      case 'delivered': color = Colors.green; text = 'Terminée'; break;
      case 'cancelled': color = Colors.red; text = 'Annulée'; break;
      default: color = Colors.grey; text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}