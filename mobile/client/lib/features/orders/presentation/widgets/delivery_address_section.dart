import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../addresses/domain/entities/address_entity.dart';
import '../../../addresses/presentation/widgets/address_selector.dart';
import 'delivery_address_form.dart';

/// Section complète de sélection/saisie d'adresse de livraison
class DeliveryAddressSection extends StatelessWidget {
  final bool useManualAddress;
  final bool hasAddresses;
  final AddressEntity? selectedAddress;
  final ValueChanged<bool> onToggleManualAddress;
  final ValueChanged<AddressEntity?> onAddressSelected;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController phoneController;
  final TextEditingController labelController;
  final bool saveAddress;
  final ValueChanged<bool> onSaveAddressChanged;
  final bool isDark;

  const DeliveryAddressSection({
    super.key,
    required this.useManualAddress,
    required this.hasAddresses,
    required this.selectedAddress,
    required this.onToggleManualAddress,
    required this.onAddressSelected,
    required this.addressController,
    required this.cityController,
    required this.phoneController,
    required this.labelController,
    required this.saveAddress,
    required this.onSaveAddressChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasAddresses) ...[
          _buildAddressTypeToggle(),
          const SizedBox(height: 16),
        ],
        if (useManualAddress || !hasAddresses)
          DeliveryAddressForm(
            addressController: addressController,
            cityController: cityController,
            phoneController: phoneController,
            labelController: labelController,
            saveAddress: saveAddress,
            onSaveAddressChanged: onSaveAddressChanged,
            isDark: isDark,
          )
        else
          AddressSelector(
            initialAddress: selectedAddress,
            onAddressSelected: onAddressSelected,
          ),
      ],
    );
  }

  Widget _buildAddressTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _AddressTypeButton(
            icon: Icons.bookmark,
            label: 'Adresse enregistrée',
            isSelected: !useManualAddress,
            onTap: () => onToggleManualAddress(false),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AddressTypeButton(
            icon: Icons.edit_location_alt,
            label: 'Nouvelle adresse',
            isSelected: useManualAddress,
            onTap: () => onToggleManualAddress(true),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

/// Bouton de sélection du type d'adresse
class _AddressTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _AddressTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
