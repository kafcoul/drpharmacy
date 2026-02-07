import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/address_entity.dart';
import '../providers/addresses_provider.dart';

/// Page de liste des adresses de livraison
class AddressesListPage extends ConsumerStatefulWidget {
  /// Si true, permet de sélectionner une adresse (mode sélection pour commande)
  final bool selectionMode;
  
  const AddressesListPage({
    super.key,
    this.selectionMode = false,
  });

  @override
  ConsumerState<AddressesListPage> createState() => _AddressesListPageState();
}

class _AddressesListPageState extends ConsumerState<AddressesListPage> {
  @override
  void initState() {
    super.initState();
    // Charger les adresses au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressesProvider.notifier).loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode 
            ? 'Sélectionner une adresse' 
            : 'Mes adresses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddAddress(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Nouvelle adresse'),
      ),
    );
  }

  Widget _buildBody(AddressesState state) {
    if (state.isLoading && state.addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(addressesProvider.notifier).loadAddresses(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.addresses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(addressesProvider.notifier).loadAddresses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.addresses.length,
        itemBuilder: (context, index) {
          final address = state.addresses[index];
          return _buildAddressCard(address, state);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune adresse enregistrée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez une adresse de livraison\npour passer vos commandes plus rapidement',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddAddress(),
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Ajouter une adresse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressEntity address, AddressesState state) {
    final isSelected = widget.selectionMode && 
        state.selectedAddress?.id == address.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: widget.selectionMode 
            ? () => _selectAddress(address)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLabelIcon(address.label),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Par défaut',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.fullAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.selectionMode)
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, address),
                      itemBuilder: (context) => [
                        if (!address.isDefault)
                          const PopupMenuItem(
                            value: 'default',
                            child: Row(
                              children: [
                                Icon(Icons.star_outline, size: 20),
                                SizedBox(width: 12),
                                Text('Définir par défaut'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (widget.selectionMode && isSelected)
                    Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
              if (address.phone != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Text(
                      address.phone!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (address.instructions != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address.instructions!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelIcon(String label) {
    IconData icon;
    Color color;
    
    switch (label.toLowerCase()) {
      case 'maison':
        icon = Icons.home;
        color = AppColors.primary;
        break;
      case 'bureau':
        icon = Icons.business;
        color = AppColors.secondary;
        break;
      case 'famille':
        icon = Icons.family_restroom;
        color = AppColors.accent;
        break;
      default:
        icon = Icons.location_on;
        color = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _handleMenuAction(String action, AddressEntity address) {
    switch (action) {
      case 'default':
        _setAsDefault(address);
        break;
      case 'edit':
        _navigateToEditAddress(address);
        break;
      case 'delete':
        _confirmDelete(address);
        break;
    }
  }

  Future<void> _setAsDefault(AddressEntity address) async {
    final success = await ref.read(addressesProvider.notifier)
        .setDefaultAddress(address.id);
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${address.label} est maintenant votre adresse par défaut'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _confirmDelete(AddressEntity address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'adresse'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${address.label}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(address);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress(AddressEntity address) async {
    final success = await ref.read(addressesProvider.notifier)
        .deleteAddress(address.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Adresse supprimée' 
                : 'Erreur lors de la suppression',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _navigateToAddAddress() {
    context.goToAddAddress();
  }

  void _navigateToEditAddress(AddressEntity address) {
    context.goToEditAddress(address);
  }

  void _selectAddress(AddressEntity address) {
    ref.read(addressesProvider.notifier).selectAddress(address);
    Navigator.pop(context, address);
  }
}
