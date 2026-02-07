/// Utilitaires et widgets pour l'accessibilité (a11y)
/// Améliore l'expérience pour les utilisateurs avec des besoins spéciaux
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Constantes d'accessibilité
class A11yConstants {
  A11yConstants._();

  /// Taille minimale recommandée pour les éléments tactiles (48x48dp)
  static const double minTouchTargetSize = 48.0;

  /// Ratio de contraste minimum pour le texte normal (WCAG AA)
  static const double minContrastRatioNormal = 4.5;

  /// Ratio de contraste minimum pour le grand texte (WCAG AA)
  static const double minContrastRatioLarge = 3.0;

  /// Taille minimale pour le grand texte
  static const double largeTextSize = 18.0;

  /// Durée d'animation réduite pour les utilisateurs sensibles
  static const Duration reducedMotionDuration = Duration(milliseconds: 0);

  /// Durée d'animation normale
  static const Duration normalAnimationDuration = Duration(milliseconds: 300);
}

/// Service d'accessibilité
class AccessibilityService {
  AccessibilityService._();

  /// Vérifie si le mode mouvement réduit est activé
  static bool isReducedMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Vérifie si le mode contraste élevé est activé
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Vérifie si l'inversion des couleurs est activée
  static bool isInvertColorsEnabled(BuildContext context) {
    return MediaQuery.of(context).invertColors;
  }

  /// Vérifie si le texte en gras est activé
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Récupère le facteur d'échelle du texte
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Vérifie si le lecteur d'écran est activé
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Annonce un message au lecteur d'écran
  // ignore: deprecated_member_use
  static void announce(String message, {TextDirection textDirection = TextDirection.ltr}) {
    // ignore: deprecated_member_use
    SemanticsService.announce(message, textDirection);
  }

  /// Calcule le ratio de contraste entre deux couleurs
  static double calculateContrastRatio(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Vérifie si le contraste est suffisant
  static bool hasAdequateContrast(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    final minRatio = isLargeText
        ? A11yConstants.minContrastRatioLarge
        : A11yConstants.minContrastRatioNormal;
    return ratio >= minRatio;
  }
}

/// Widget avec sémantique améliorée pour les boutons
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeFromSemantics;
  final ButtonStyle? style;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.semanticHint,
    this.excludeFromSemantics = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: excludeFromSemantics,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style ?? _ensureMinTouchTarget(context),
        child: child,
      ),
    );
  }

  ButtonStyle _ensureMinTouchTarget(BuildContext context) {
    return ElevatedButton.styleFrom(
      minimumSize: const Size(
        A11yConstants.minTouchTargetSize,
        A11yConstants.minTouchTargetSize,
      ),
    );
  }
}

/// Widget avec sémantique améliorée pour les icônes
class AccessibleIcon extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final double? size;
  final Color? color;

  const AccessibleIcon({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Icon(
          icon,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}

/// Widget IconButton accessible avec taille tactile minimale
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final double? iconSize;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.semanticHint,
    this.onPressed,
    this.iconSize,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        icon: Icon(icon, color: color),
        iconSize: iconSize ?? 24,
        padding: padding ?? const EdgeInsets.all(12),
        constraints: const BoxConstraints(
          minWidth: A11yConstants.minTouchTargetSize,
          minHeight: A11yConstants.minTouchTargetSize,
        ),
        onPressed: onPressed,
        tooltip: semanticLabel,
      ),
    );
  }
}

/// Widget image accessible
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isDecorative;

  const AccessibleImage({
    super.key,
    required this.image,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: isDecorative ? null : semanticLabel,
    );

    if (isDecorative) {
      return ExcludeSemantics(child: imageWidget);
    }

    return Semantics(
      label: semanticLabel,
      image: true,
      child: imageWidget,
    );
  }
}

/// Widget de formulaire avec sémantique améliorée
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? semanticHint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.semanticHint,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: labelText,
      hint: semanticHint ?? hintText,
      textField: true,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          // Assurer une taille tactile suffisante
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        autofocus: autofocus,
        maxLines: maxLines,
        maxLength: maxLength,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
      ),
    );
  }
}

/// Widget de carte accessible
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AccessibleCard({
    super.key,
    required this.child,
    this.semanticLabel,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: margin ?? const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }
}

/// Widget pour grouper des éléments avec une étiquette
class AccessibleGroup extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  final bool isHeader;

  const AccessibleGroup({
    super.key,
    required this.label,
    this.hint,
    required this.child,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      header: isHeader,
      container: true,
      child: child,
    );
  }
}

/// Widget de chargement accessible
class AccessibleLoadingIndicator extends StatelessWidget {
  final String? semanticLabel;
  final double? size;
  final Color? color;

  const AccessibleLoadingIndicator({
    super.key,
    this.semanticLabel,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Chargement en cours',
      child: SizedBox(
        width: size ?? 24,
        height: size ?? 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
        ),
      ),
    );
  }
}

/// Widget pour indiquer un état (succès, erreur, etc.)
class AccessibleStatusIndicator extends StatelessWidget {
  final StatusType type;
  final String message;
  final IconData? customIcon;

  const AccessibleStatusIndicator({
    super.key,
    required this.type,
    required this.message,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, semanticPrefix) = switch (type) {
      StatusType.success => (Icons.check_circle, Colors.green, 'Succès :'),
      StatusType.error => (Icons.error, Colors.red, 'Erreur :'),
      StatusType.warning => (Icons.warning, Colors.orange, 'Attention :'),
      StatusType.info => (Icons.info, Colors.blue, 'Information :'),
    };

    return Semantics(
      label: '$semanticPrefix $message',
      liveRegion: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(customIcon ?? icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType { success, error, warning, info }

/// Extension pour ajouter facilement des sémantiques
extension SemanticExtensions on Widget {
  /// Ajoute une étiquette sémantique
  Widget withSemanticLabel(String label) {
    return Semantics(
      label: label,
      child: this,
    );
  }

  /// Marque comme bouton
  Widget asSemanticButton({String? label, String? hint}) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      child: this,
    );
  }

  /// Marque comme en-tête
  Widget asSemanticHeader({String? label}) {
    return Semantics(
      label: label,
      header: true,
      child: this,
    );
  }

  /// Marque comme image
  Widget asSemanticImage(String label) {
    return Semantics(
      label: label,
      image: true,
      child: this,
    );
  }

  /// Exclut des sémantiques (pour éléments décoratifs)
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Ajoute un ordre de lecture
  Widget withSortKey(double order) {
    return Semantics(
      sortKey: OrdinalSortKey(order),
      child: this,
    );
  }

  /// Assure une taille tactile minimale
  Widget ensureMinTouchTarget() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: A11yConstants.minTouchTargetSize,
        minHeight: A11yConstants.minTouchTargetSize,
      ),
      child: this,
    );
  }
}

/// Mixin pour les animations respectueuses de l'accessibilité
mixin AccessibleAnimationMixin<T extends StatefulWidget> on State<T> {
  /// Durée d'animation adaptée aux préférences utilisateur
  Duration get accessibleAnimationDuration {
    if (!mounted) return A11yConstants.normalAnimationDuration;
    
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return reducedMotion
        ? A11yConstants.reducedMotionDuration
        : A11yConstants.normalAnimationDuration;
  }

  /// Vérifie si les animations doivent être réduites
  bool get shouldReduceMotion {
    if (!mounted) return false;
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }
}

/// Provider pour les préférences d'accessibilité
class AccessibilityPreferences extends InheritedWidget {
  final bool highContrast;
  final bool reducedMotion;
  final double textScale;
  final bool screenReaderEnabled;

  const AccessibilityPreferences({
    super.key,
    required this.highContrast,
    required this.reducedMotion,
    required this.textScale,
    required this.screenReaderEnabled,
    required super.child,
  });

  static AccessibilityPreferences? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AccessibilityPreferences>();
  }

  static AccessibilityPreferences of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No AccessibilityPreferences found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AccessibilityPreferences oldWidget) {
    return highContrast != oldWidget.highContrast ||
        reducedMotion != oldWidget.reducedMotion ||
        textScale != oldWidget.textScale ||
        screenReaderEnabled != oldWidget.screenReaderEnabled;
  }
}

/// Widget builder pour les préférences d'accessibilité
class AccessibilityBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AccessibilityPreferences prefs) builder;

  const AccessibilityBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    final prefs = AccessibilityPreferences(
      highContrast: mediaQuery.highContrast,
      reducedMotion: mediaQuery.disableAnimations,
      textScale: mediaQuery.textScaler.scale(1.0),
      screenReaderEnabled: mediaQuery.accessibleNavigation,
      child: const SizedBox.shrink(),
    );

    return builder(context, prefs);
  }
}
