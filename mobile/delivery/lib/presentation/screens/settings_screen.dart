import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure this is imported for other features if not already
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/background_location_service.dart';
import 'change_password_screen.dart';
import 'help_center_screen.dart';
import 'report_problem_screen.dart';
import 'support_tickets_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _navigationApp = 'google_maps'; // google_maps, waze, apple_maps
  String _language = 'fr'; // fr, en

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _navigationApp = prefs.getString('navigation_app') ?? 'google_maps';
      _language = prefs.getString('language') ?? 'fr';
    });
  }

  Future<void> _updateNotification(bool value) async {
    setState(() => _notificationsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> _updateNavigationApp(String value) async {
    setState(() => _navigationApp = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('navigation_app', value);
  }

  Future<void> _updateLanguage(String value) async {
    setState(() => _language = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    
    // In a real app, this would trigger a rebuild of the App with new locale
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Langue changée en ${value == 'fr' ? 'Français' : 'Anglais'} (Redémarrage requis)')),
      );
    }
  }

  Future<void> _openWebPage(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir la page web')));
      }
    }
  }

  Future<void> _contactSupport() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '+2250707070707',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lancer l\'appel')));
      }
    }
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('Choisir la langue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Français'),
              trailing: _language == 'fr' ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                _updateLanguage('fr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: _language == 'en' ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                _updateLanguage('en');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text('Paramètres', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Apparence'),
          _buildCard([
            _buildThemeSelector(themeMode),
          ]),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Préférences'),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications Push',
              subtitle: 'Recevoir des alertes pour les nouvelles courses',
              value: _notificationsEnabled,
              onChanged: _updateNotification,
            ),
            const Divider(height: 1),
            _buildNavigationSelector(),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Compte'),
          _buildCard([
            _buildActionTile(
              icon: Icons.lock_outline,
              title: 'Changer le mot de passe',
              onTap: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                 );
              },
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.language,
              title: 'Langue de l\'application',
              trailing: Text(_language == 'fr' ? 'Français' : 'English', style: const TextStyle(color: Colors.grey)),
              onTap: () => _showLanguageDialog(),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Sécurité'),
          _buildBiometricCard(),

          const SizedBox(height: 24),
          _buildSectionHeader('Optimisation'),
          _buildBatteryOptimizationCard(),

          const SizedBox(height: 24),
          _buildSectionHeader('Aide & Support'),
           _buildCard([
            _buildActionTile(
              icon: Icons.support_agent,
              title: 'Mes demandes de support',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportTicketsScreen()),
              ),
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.headset_mic_outlined,
              title: 'Contacter le support',
              onTap: _contactSupport,
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.help_outline,
              title: 'Centre d\'aide (FAQ)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
              ),
            ),
            const Divider(height: 1),
             _buildActionTile(
              icon: Icons.report_problem_outlined,
              title: 'Signaler un problème',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportProblemScreen()),
              ),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader('Informations'),
          _buildCard([
            _buildActionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Politique de confidentialité',
              onTap: () => _openWebPage('https://dr-pharma.com/privacy'),
            ),
             const Divider(height: 1),
            _buildActionTile(
              icon: Icons.description_outlined,
              title: 'Conditions d\'utilisation',
              onTap: () => _openWebPage('https://dr-pharma.com/terms'),
            ),
          ]),
          
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Version 1.0.0+1',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _buildBiometricCard() {
    final biometricService = ref.watch(biometricServiceProvider);
    final biometricSettings = ref.watch(biometricSettingsProvider);
    
    return FutureBuilder<bool>(
      future: biometricService.canCheckBiometrics(),
      builder: (context, snapshot) {
        final canUseBiometric = snapshot.data ?? false;
        
        if (!canUseBiometric) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return _buildCard([
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fingerprint, color: isDark ? Colors.grey.shade400 : Colors.grey, size: 20),
              ),
              title: const Text(
                'Connexion biométrique',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                'Non disponible sur cet appareil',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade500 : Colors.grey),
              ),
              trailing: Icon(Icons.info_outline, color: isDark ? Colors.grey.shade500 : Colors.grey, size: 20),
            ),
          ]);
        }
        
        return FutureBuilder<List<AppBiometricType>>(
          future: biometricService.getAvailableBiometrics(),
          builder: (context, biometricTypesSnapshot) {
            final biometricTypes = biometricTypesSnapshot.data ?? [];
            String biometricLabel = 'Face ID / Touch ID';
            IconData biometricIcon = Icons.fingerprint;
            
            if (biometricTypes.contains(AppBiometricType.faceId)) {
              biometricLabel = 'Face ID';
              biometricIcon = Icons.face;
            } else if (biometricTypes.contains(AppBiometricType.fingerprint)) {
              biometricLabel = 'Touch ID';
              biometricIcon = Icons.fingerprint;
            }
            
            return _buildCard([
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(biometricIcon, color: Colors.green, size: 20),
                ),
                title: Text(
                  'Connexion par $biometricLabel',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  biometricSettings 
                    ? 'Activé - Se connecter avec $biometricLabel' 
                    : 'Désactivé',
                  style: TextStyle(
                    fontSize: 12,
                    color: biometricSettings ? Colors.green : Colors.grey,
                  ),
                ),
                trailing: Switch.adaptive(
                  value: biometricSettings,
                  onChanged: (value) async {
                    if (value) {
                      // Demander l'authentification avant d'activer
                      final authenticated = await biometricService.authenticate(
                        reason: 'Confirmez votre identité pour activer $biometricLabel',
                      );
                      if (authenticated) {
                        await ref.read(biometricSettingsProvider.notifier).enableBiometricLogin();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$biometricLabel activé avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } else {
                      await ref.read(biometricSettingsProvider.notifier).disableBiometricLogin();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connexion biométrique désactivée'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                  activeTrackColor: Colors.green,
                ),
              ),
            ]);
          },
        );
      },
    );
  }

  Widget _buildBatteryOptimizationCard() {
    return FutureBuilder<bool>(
      future: BackgroundLocationService.isEnabled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;
        
        return _buildCard([
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.battery_charging_full, color: Colors.orange, size: 20),
            ),
            title: const Text(
              'Localisation en arrière-plan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(
              isEnabled 
                ? 'Activé - Position mise à jour même app fermée'
                : 'Désactivé - Économise la batterie',
              style: TextStyle(
                fontSize: 12,
                color: isEnabled ? Colors.orange : Colors.grey,
              ),
            ),
            trailing: Switch.adaptive(
              value: isEnabled,
              onChanged: (value) async {
                if (value) {
                  await BackgroundLocationService.startBackgroundUpdates();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Localisation en arrière-plan activée'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  await BackgroundLocationService.stopBackgroundUpdates();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Localisation en arrière-plan désactivée'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
                setState(() {}); // Rebuild pour mettre à jour l'UI
              },
              activeTrackColor: Colors.orange,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.speed, color: Colors.blue, size: 20),
            ),
            title: const Text(
              'Mode économie d\'énergie',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: const Text(
              'Réduit la précision GPS pour économiser la batterie',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () => _showBatteryModeDialog(),
          ),
        ]);
      },
    );
  }

  void _showBatteryModeDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Mode de localisation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Choisissez le mode selon vos besoins',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.battery_full, color: Colors.green),
              ),
              title: const Text('Économie maximale'),
              subtitle: const Text('GPS basse précision, mise à jour toutes les 5 min'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mode économie activé')),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.battery_std, color: Colors.orange),
              ),
              title: const Text('Équilibré'),
              subtitle: const Text('GPS moyenne précision, mise à jour toutes les 2 min'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mode équilibré activé')),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.battery_alert, color: Colors.red),
              ),
              title: const Text('Performance'),
              subtitle: const Text('GPS haute précision, mise à jour temps réel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mode performance activé')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: Colors.blue),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey.shade500 : Colors.grey),
    );
  }

  Widget _buildNavigationSelector() {
    String label = 'Google Maps';
    if (_navigationApp == 'waze') label = 'Waze';
    if (_navigationApp == 'apple_maps') label = 'Apple Maps';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: const Icon(Icons.map_outlined, color: Colors.orange, size: 20),
      ),
      title: const Text('Application de Navigation', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(
        label, 
        style: const TextStyle(fontSize: 12, color: Colors.blue),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text('Choisir l\'application GPS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.red),
                  title: const Text('Google Maps'),
                  trailing: _navigationApp == 'google_maps' ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    _updateNavigationApp('google_maps');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car, color: Colors.blue),
                  title: const Text('Waze'),
                  trailing: _navigationApp == 'waze' ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    _updateNavigationApp('waze');
                    Navigator.pop(context);
                  },
                ),
                 ListTile(
                  leading: const Icon(Icons.map_outlined, color: Colors.grey),
                  title: const Text('Apple Maps'),
                  trailing: _navigationApp == 'apple_maps' ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    _updateNavigationApp('apple_maps');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSelector(ThemeMode currentMode) {
    String label = 'Système';
    IconData icon = Icons.brightness_auto;
    
    if (currentMode == ThemeMode.light) {
      label = 'Clair';
      icon = Icons.light_mode;
    } else if (currentMode == ThemeMode.dark) {
      label = 'Sombre';
      icon = Icons.dark_mode;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1), 
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.purple, size: 20),
      ),
      title: const Text('Thème', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(label, style: const TextStyle(fontSize: 12, color: Colors.blue)),
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Choisir le thème',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.brightness_auto, color: Colors.grey),
                  title: const Text('Système'),
                  subtitle: const Text('Suit les paramètres de votre appareil'),
                  trailing: currentMode == ThemeMode.system
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode, color: Colors.orange),
                  title: const Text('Clair'),
                  trailing: currentMode == ThemeMode.light
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode, color: Colors.indigo),
                  title: const Text('Sombre'),
                  trailing: currentMode == ThemeMode.dark
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
