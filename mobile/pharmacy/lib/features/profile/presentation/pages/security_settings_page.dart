import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/presentation/widgets/widgets.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  bool _autoLockEnabled = true;
  int _sessionTimeoutMinutes = 15;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final securityService = ref.read(securityServiceProvider);
    setState(() {
      _biometricEnabled = securityService.isBiometricEnabled();
      _pinEnabled = securityService.isPinEnabled();
      _sessionTimeoutMinutes = securityService.getSessionTimeout().inMinutes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sécurité'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Authentification
                  _buildSectionHeader('Authentification', Icons.fingerprint),
                  const SizedBox(height: 16),
                  
                  ModernCard(
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          icon: Icons.fingerprint,
                          iconColor: Theme.of(context).colorScheme.primary,
                          title: 'Authentification biométrique',
                          subtitle: 'Utiliser Face ID / Empreinte digitale',
                          value: _biometricEnabled,
                          onChanged: _toggleBiometric,
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          icon: Icons.pin,
                          iconColor: Colors.purple,
                          title: 'Code PIN',
                          subtitle: 'Définir un code PIN de sécurité',
                          value: _pinEnabled,
                          onChanged: _togglePin,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Section Session
                  _buildSectionHeader('Session', Icons.timer_outlined),
                  const SizedBox(height: 16),
                  
                  ModernCard(
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          icon: Icons.lock_clock,
                          iconColor: Colors.orange,
                          title: 'Verrouillage automatique',
                          subtitle: 'Verrouiller après inactivité',
                          value: _autoLockEnabled,
                          onChanged: (value) {
                            setState(() => _autoLockEnabled = value);
                          },
                        ),
                        if (_autoLockEnabled) ...[
                          const Divider(height: 1),
                          _buildTimeoutSelector(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Section Données
                  _buildSectionHeader('Données', Icons.storage),
                  const SizedBox(height: 16),
                  
                  ModernCard(
                    child: Column(
                      children: [
                        _buildActionTile(
                          icon: Icons.delete_sweep,
                          iconColor: Colors.red,
                          title: 'Effacer le cache',
                          subtitle: 'Libérer de l\'espace',
                          onTap: _clearCache,
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          icon: Icons.sync,
                          iconColor: Colors.blue,
                          title: 'Synchroniser maintenant',
                          subtitle: 'Forcer la synchronisation',
                          onTap: _forceSync,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Informations de sécurité
                  AlertCard(
                    message: 'Vos données sont chiffrées et stockées de manière sécurisée sur votre appareil.',
                    type: AlertType.info,
                    icon: Icons.shield_outlined,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeoutSelector() {
    final options = [
      {'value': 5, 'label': '5 minutes'},
      {'value': 15, 'label': '15 minutes'},
      {'value': 30, 'label': '30 minutes'},
      {'value': 60, 'label': '1 heure'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Délai avant verrouillage',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = _sessionTimeoutMinutes == option['value'];
              return GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  setState(() => _sessionTimeoutMinutes = option['value'] as int);
                  final securityService = ref.read(securityServiceProvider);
                  await securityService.setSessionTimeout(
                    Duration(minutes: _sessionTimeoutMinutes),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    option['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled) {
      // Vérifier si l'appareil supporte la biométrie
      final securityService = ref.read(securityServiceProvider);
      final capability = await securityService.checkBiometricCapability();
      
      if (!capability.isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentification biométrique non disponible sur cet appareil'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Authentifier d'abord
      final result = await securityService.authenticateWithBiometric(
        reason: 'Confirmez votre identité pour activer la biométrie',
      );
      
      if (result.success) {
        await securityService.setBiometricEnabled(true);
        setState(() => _biometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentification biométrique activée'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      final securityService = ref.read(securityServiceProvider);
      await securityService.setBiometricEnabled(false);
      setState(() => _biometricEnabled = false);
    }
  }

  Future<void> _togglePin(bool enabled) async {
    if (enabled) {
      _showSetPinDialog();
    } else {
      _showConfirmDisablePinDialog();
    }
  }

  void _showSetPinDialog() {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Définir un code PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Code PIN (4-6 chiffres)',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le code PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              if (pinController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le PIN doit faire au moins 4 chiffres')),
                );
                return;
              }
              if (pinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Les codes PIN ne correspondent pas')),
                );
                return;
              }
              
              final securityService = ref.read(securityServiceProvider);
              await securityService.setPinEnabled(true, pin: pinController.text);
              setState(() => _pinEnabled = true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code PIN défini avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDisablePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Désactiver le code PIN ?'),
        content: const Text(
          'Votre compte sera moins sécurisé sans code PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              final securityService = ref.read(securityServiceProvider);
              await securityService.setPinEnabled(false);
              setState(() => _pinEnabled = false);
              Navigator.pop(context);
            },
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer le cache ?'),
        content: const Text(
          'Cette action supprimera les données temporaires. Vous devrez peut-être vous reconnecter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cacheService = ref.read(cacheServiceProvider);
      await cacheService.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache effacé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _forceSync() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Synchronisation en cours...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Simuler une synchronisation
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Synchronisation terminée'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
