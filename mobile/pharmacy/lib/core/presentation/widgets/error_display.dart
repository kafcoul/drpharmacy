import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/error_messages.dart';

/// Widget unifié pour afficher les erreurs de manière cohérente
/// Peut être utilisé comme SnackBar, Dialog ou Widget inline
class ErrorDisplay {
  
  // ============================================
  // SNACKBAR - Pour les erreurs temporaires
  // ============================================
  
  /// Affiche un SnackBar d'erreur avec style cohérent
  static void showSnackBar(
    BuildContext context, {
    required String message,
    ErrorType type = ErrorType.error,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    bool showIcon = true,
  }) {
    HapticFeedback.mediumImpact();
    
    final colors = _getColors(type);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showIcon) ...[
              Icon(colors.icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
  
  /// Affiche un SnackBar d'erreur simple
  static void showError(BuildContext context, String message) {
    showSnackBar(context, message: message, type: ErrorType.error);
  }
  
  /// Affiche un SnackBar de succès
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message: message, type: ErrorType.success);
  }
  
  /// Affiche un SnackBar d'avertissement
  static void showWarning(BuildContext context, String message) {
    showSnackBar(context, message: message, type: ErrorType.warning);
  }
  
  /// Affiche un SnackBar d'information
  static void showInfo(BuildContext context, String message) {
    showSnackBar(context, message: message, type: ErrorType.info);
  }

  // ============================================
  // DIALOG - Pour les erreurs importantes
  // ============================================
  
  /// Affiche une boîte de dialogue d'erreur
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String message,
    String? title,
    ErrorType type = ErrorType.error,
    String? primaryButtonText,
    VoidCallback? onPrimaryButton,
    String? secondaryButtonText,
    VoidCallback? onSecondaryButton,
    bool barrierDismissible = true,
  }) async {
    HapticFeedback.heavyImpact();
    
    final colors = _getColors(type);
    
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.lightBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                colors.icon,
                size: 40,
                color: colors.iconColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Titre
            Text(
              title ?? type.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Boutons
            Column(
              children: [
                // Bouton principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onPrimaryButton?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      primaryButtonText ?? 'Compris',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                
                // Bouton secondaire (optionnel)
                if (secondaryButtonText != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        onSecondaryButton?.call();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        secondaryButtonText,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Affiche un dialogue de confirmation
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String message,
    String? title,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDangerous 
                    ? Colors.red.shade50 
                    : Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDangerous 
                    ? Icons.warning_rounded 
                    : Icons.help_outline_rounded,
                size: 40,
                color: isDangerous ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            
            // Titre
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDangerous ? Colors.red : null,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
    return result ?? false;
  }

  // ============================================
  // WIDGET INLINE - Pour les états d'erreur dans les pages
  // ============================================
  
  /// Widget à afficher en cas d'erreur (plein écran ou partiel)
  static Widget errorWidget({
    required String message,
    String? title,
    IconData? icon,
    VoidCallback? onRetry,
    String retryText = 'Réessayer',
    bool isFullScreen = true,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullScreen ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            
            // Titre
            Text(
              title ?? 'Oups ! Une erreur est survenue',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Bouton réessayer
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryText),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Widget pour état vide (pas une erreur mais pas de données)
  static Widget emptyWidget({
    required String message,
    String? title,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            
            // Titre
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            // Bouton d'action
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionText),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Widget pour état hors ligne
  static Widget offlineWidget({
    VoidCallback? onRetry,
  }) {
    return errorWidget(
      title: 'Pas de connexion',
      message: ErrorMessages.noInternet,
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      retryText: 'Réessayer',
    );
  }
  
  // ============================================
  // HELPERS PRIVÉS
  // ============================================
  
  static _ErrorColors _getColors(ErrorType type) {
    switch (type) {
      case ErrorType.error:
        return _ErrorColors(
          background: Colors.red.shade600,
          lightBackground: Colors.red.shade50,
          icon: Icons.error_rounded,
          iconColor: Colors.red.shade600,
          textColor: Colors.red.shade700,
          buttonColor: Colors.red.shade600,
        );
      case ErrorType.warning:
        return _ErrorColors(
          background: Colors.orange.shade600,
          lightBackground: Colors.orange.shade50,
          icon: Icons.warning_rounded,
          iconColor: Colors.orange.shade600,
          textColor: Colors.orange.shade700,
          buttonColor: Colors.orange.shade600,
        );
      case ErrorType.info:
        return _ErrorColors(
          background: Colors.blue.shade600,
          lightBackground: Colors.blue.shade50,
          icon: Icons.info_rounded,
          iconColor: Colors.blue.shade600,
          textColor: Colors.blue.shade700,
          buttonColor: Colors.blue.shade600,
        );
      case ErrorType.success:
        return _ErrorColors(
          background: Colors.green.shade600,
          lightBackground: Colors.green.shade50,
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green.shade600,
          textColor: Colors.green.shade700,
          buttonColor: Colors.green.shade600,
        );
    }
  }
}

class _ErrorColors {
  final Color background;
  final Color lightBackground;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color buttonColor;

  _ErrorColors({
    required this.background,
    required this.lightBackground,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.buttonColor,
  });
}

/// Extension pour faciliter l'affichage des erreurs depuis n'importe quel BuildContext
extension ErrorDisplayContext on BuildContext {
  void showError(String message) => ErrorDisplay.showError(this, message);
  void showSuccess(String message) => ErrorDisplay.showSuccess(this, message);
  void showWarning(String message) => ErrorDisplay.showWarning(this, message);
  void showInfo(String message) => ErrorDisplay.showInfo(this, message);
  
  Future<void> showErrorDialog(String message, {String? title}) => 
      ErrorDisplay.showErrorDialog(this, message: message, title: title);
  
  Future<bool> showConfirmDialog(String message, {String? title, bool isDangerous = false}) => 
      ErrorDisplay.showConfirmDialog(this, message: message, title: title, isDangerous: isDangerous);
}

// ============================================
// ALIAS CLASSES POUR FACILITER L'UTILISATION
// ============================================

/// Alias pour afficher des SnackBars - utilisation: ErrorSnackBar.showError(context, message)
class ErrorSnackBar {
  static void showError(BuildContext context, String message) {
    ErrorDisplay.showError(context, message);
  }
  
  static void showSuccess(BuildContext context, String message) {
    ErrorDisplay.showSuccess(context, message);
  }
  
  static void showWarning(BuildContext context, String message) {
    ErrorDisplay.showWarning(context, message);
  }
  
  static void showInfo(BuildContext context, String message) {
    ErrorDisplay.showInfo(context, message);
  }
}

/// Alias pour afficher des Dialogs - utilisation: ErrorDialog.show(context, ...)
class ErrorDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onRetry,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon ?? Icons.error_outline_rounded, color: iconColor ?? Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onRetry();
              },
              child: const Text('Réessayer'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}
