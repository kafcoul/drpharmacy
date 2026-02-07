import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

// Provider pour les préférences de notification
final notificationPreferencesProvider = StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});

class NotificationPreferences {
  final bool pushEnabled;
  final bool orderUpdates;
  final bool promotions;
  final bool newProducts;
  final bool deliveryAlerts;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationPreferences({
    this.pushEnabled = true,
    this.orderUpdates = true,
    this.promotions = true,
    this.newProducts = false,
    this.deliveryAlerts = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? orderUpdates,
    bool? promotions,
    bool? newProducts,
    bool? deliveryAlerts,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      newProducts: newProducts ?? this.newProducts,
      deliveryAlerts: deliveryAlerts ?? this.deliveryAlerts,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(const NotificationPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationPreferences(
      pushEnabled: prefs.getBool('notif_push_enabled') ?? true,
      orderUpdates: prefs.getBool('notif_order_updates') ?? true,
      promotions: prefs.getBool('notif_promotions') ?? true,
      newProducts: prefs.getBool('notif_new_products') ?? false,
      deliveryAlerts: prefs.getBool('notif_delivery_alerts') ?? true,
      soundEnabled: prefs.getBool('notif_sound_enabled') ?? true,
      vibrationEnabled: prefs.getBool('notif_vibration_enabled') ?? true,
    );
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void togglePushEnabled(bool value) {
    state = state.copyWith(pushEnabled: value);
    _savePreference('notif_push_enabled', value);
  }

  void toggleOrderUpdates(bool value) {
    state = state.copyWith(orderUpdates: value);
    _savePreference('notif_order_updates', value);
  }

  void togglePromotions(bool value) {
    state = state.copyWith(promotions: value);
    _savePreference('notif_promotions', value);
  }

  void toggleNewProducts(bool value) {
    state = state.copyWith(newProducts: value);
    _savePreference('notif_new_products', value);
  }

  void toggleDeliveryAlerts(bool value) {
    state = state.copyWith(deliveryAlerts: value);
    _savePreference('notif_delivery_alerts', value);
  }

  void toggleSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    _savePreference('notif_sound_enabled', value);
  }

  void toggleVibrationEnabled(bool value) {
    state = state.copyWith(vibrationEnabled: value);
    _savePreference('notif_vibration_enabled', value);
  }

  void enableAll() {
    state = const NotificationPreferences(
      pushEnabled: true,
      orderUpdates: true,
      promotions: true,
      newProducts: true,
      deliveryAlerts: true,
      soundEnabled: true,
      vibrationEnabled: true,
    );
    _saveAll();
  }

  void disableAll() {
    state = const NotificationPreferences(
      pushEnabled: false,
      orderUpdates: false,
      promotions: false,
      newProducts: false,
      deliveryAlerts: false,
      soundEnabled: false,
      vibrationEnabled: false,
    );
    _saveAll();
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_push_enabled', state.pushEnabled);
    await prefs.setBool('notif_order_updates', state.orderUpdates);
    await prefs.setBool('notif_promotions', state.promotions);
    await prefs.setBool('notif_new_products', state.newProducts);
    await prefs.setBool('notif_delivery_alerts', state.deliveryAlerts);
    await prefs.setBool('notif_sound_enabled', state.soundEnabled);
    await prefs.setBool('notif_vibration_enabled', state.vibrationEnabled);
  }
}

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: textColor, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'enable_all') {
                notifier.enableAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toutes les notifications activées')),
                );
              } else if (value == 'disable_all') {
                notifier.disableAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toutes les notifications désactivées')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'enable_all',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Tout activer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'disable_all',
                child: Row(
                  children: [
                    Icon(Icons.notifications_off, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Tout désactiver'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Préférences de notification',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Personnalisez les notifications que vous\nsouhaitez recevoir',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtitleColor, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // Push Notifications Master Switch
            _buildMasterSwitch(
              context: context,
              icon: Icons.notifications_active,
              title: 'Notifications push',
              subtitle: 'Activer/désactiver toutes les notifications push',
              value: prefs.pushEnabled,
              onChanged: notifier.togglePushEnabled,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Category Notifications
            Text(
              'Types de notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),

            _buildNotificationCard(
              isDark: isDark,
              children: [
                _buildNotificationTile(
                  icon: Icons.shopping_bag,
                  iconColor: Colors.blue,
                  title: 'Mises à jour de commande',
                  subtitle: 'Statut de commande, confirmation, préparation',
                  value: prefs.orderUpdates,
                  onChanged: prefs.pushEnabled ? notifier.toggleOrderUpdates : null,
                  enabled: prefs.pushEnabled,
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : null),
                _buildNotificationTile(
                  icon: Icons.local_shipping,
                  iconColor: Colors.orange,
                  title: 'Alertes de livraison',
                  subtitle: 'Coursier en route, livraison imminente',
                  value: prefs.deliveryAlerts,
                  onChanged: prefs.pushEnabled ? notifier.toggleDeliveryAlerts : null,
                  enabled: prefs.pushEnabled,
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : null),
                _buildNotificationTile(
                  icon: Icons.local_offer,
                  iconColor: Colors.purple,
                  title: 'Promotions & Offres',
                  subtitle: 'Réductions, codes promo, offres spéciales',
                  value: prefs.promotions,
                  onChanged: prefs.pushEnabled ? notifier.togglePromotions : null,
                  enabled: prefs.pushEnabled,
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : null),
                _buildNotificationTile(
                  icon: Icons.new_releases,
                  iconColor: Colors.teal,
                  title: 'Nouveaux produits',
                  subtitle: 'Arrivages, nouveautés en pharmacie',
                  value: prefs.newProducts,
                  onChanged: prefs.pushEnabled ? notifier.toggleNewProducts : null,
                  enabled: prefs.pushEnabled,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sound & Vibration
            Text(
              'Son & Vibration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),

            _buildNotificationCard(
              isDark: isDark,
              children: [
                _buildNotificationTile(
                  icon: Icons.volume_up,
                  iconColor: Colors.green,
                  title: 'Son',
                  subtitle: 'Jouer un son pour les notifications',
                  value: prefs.soundEnabled,
                  onChanged: prefs.pushEnabled ? notifier.toggleSoundEnabled : null,
                  enabled: prefs.pushEnabled,
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : null),
                _buildNotificationTile(
                  icon: Icons.vibration,
                  iconColor: Colors.amber,
                  title: 'Vibration',
                  subtitle: 'Vibrer lors de la réception',
                  value: prefs.vibrationEnabled,
                  onChanged: prefs.pushEnabled ? notifier.toggleVibrationEnabled : null,
                  enabled: prefs.pushEnabled,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.blue.shade700 : Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: isDark ? Colors.blue.shade300 : Colors.blue.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bon à savoir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blue.shade300 : Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Les notifications de commande et de livraison sont importantes pour suivre vos achats en temps réel.',
                          style: TextStyle(
                            color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterSwitch({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value 
            ? AppColors.primary.withValues(alpha: 0.1) 
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value 
              ? AppColors.primary.withValues(alpha: 0.3) 
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? AppColors.primary : null),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
    required bool enabled,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected) ? AppColors.primary : null),
            ),
          ],
        ),
      ),
    );
  }
}
