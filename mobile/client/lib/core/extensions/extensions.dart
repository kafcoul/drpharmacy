import 'package:flutter/material.dart';

/// Extensions pour les nombres
extension IntExtensions on int {
  /// Ajoute un zéro devant si < 10 (ex: 5 -> "05")
  String get twoDigits => toString().padLeft(2, '0');
  
  /// Formate en prix FCFA
  String get formatPrice => '${toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} ',
  )} FCFA';
}

/// Extensions pour les doubles
extension DoubleExtensions on double {
  /// Formate en prix FCFA
  String get formatPrice => '${toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} ',
  )} FCFA';
}

/// Extensions pour les chaînes
extension StringExtensions on String {
  /// Première lettre en majuscule
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  
  /// Chaque mot avec première lettre en majuscule
  String get titleCase => split(' ').map((word) => word.capitalize).join(' ');
  
  /// Tronque avec "..." si trop long
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }
  
  /// Valide un email
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }
  
  /// Valide un numéro de téléphone (format local ou international)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^(\+225|00225)?[0-9]{10}$');
    return phoneRegex.hasMatch(replaceAll(' ', '').replaceAll('-', ''));
  }
  
  /// Formate un numéro de téléphone
  String get formatPhone {
    final cleaned = replaceAll(' ', '').replaceAll('-', '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    }
    return this;
  }
  
  /// Normalise le numéro au format international E.164 (+225XXXXXXXXXX)
  /// Requis pour Firebase Phone Auth
  /// IMPORTANT: Valide strictement le format pour éviter les bypass
  String get toInternationalPhone {
    String cleaned = replaceAll(' ', '').replaceAll('-', '').replaceAll('(', '').replaceAll(')', '');
    
    // Déjà au bon format +225 suivi de exactement 10 chiffres
    if (cleaned.startsWith('+225') && cleaned.length == 14) {
      // Vérifier que les 10 chiffres commencent par 0
      final localPart = cleaned.substring(4); // Retire +225
      if (localPart.length == 10 && localPart.startsWith('0')) {
        return cleaned;
      }
      // Format invalide - ne pas accepter
      throw FormatException('Format de numéro invalide: doit être +225 suivi de 10 chiffres commençant par 0');
    }
    
    // Format 00225... (14 caractères)
    if (cleaned.startsWith('00225') && cleaned.length == 15) {
      final localPart = cleaned.substring(5); // Retire 00225
      if (localPart.length == 10 && localPart.startsWith('0')) {
        return '+${cleaned.substring(2)}';
      }
      throw FormatException('Format de numéro invalide: doit être 00225 suivi de 10 chiffres commençant par 0');
    }
    
    // Format 225... (sans +) - REJETER ce format pour éviter les bypass
    // Auparavant, ce format permettait de contourner la validation
    if (cleaned.startsWith('225') && !cleaned.startsWith('2250')) {
      throw FormatException('Format de numéro invalide: utilisez le format local (0X XX XX XX XX) ou international (+225...)');
    }
    
    // Format local 10 chiffres (0X XX XX XX XX) - SEUL FORMAT LOCAL ACCEPTÉ
    if (cleaned.length == 10 && cleaned.startsWith('0')) {
      return '+225$cleaned';
    }
    
    // Tout autre format est invalide
    throw FormatException('Format de numéro invalide: doit être 10 chiffres commençant par 0, ou format international +225...');
  }
}

/// Extensions pour DateTime
extension DateTimeExtensions on DateTime {
  /// Formate en "jj/mm/aaaa"
  String get formatDate => '${day.twoDigits}/${month.twoDigits}/$year';
  
  /// Formate en "jj/mm/aaaa hh:mm"
  String get formatDateTime => '$formatDate ${hour.twoDigits}:${minute.twoDigits}';
  
  /// Formate en "hh:mm"
  String get formatTime => '${hour.twoDigits}:${minute.twoDigits}';
  
  /// Vérifie si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Vérifie si c'est hier
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// Formate intelligemment (aujourd'hui, hier, date)
  String get smartFormat {
    if (isToday) return 'Aujourd\'hui à $formatTime';
    if (isYesterday) return 'Hier à $formatTime';
    return formatDateTime;
  }
  
  /// Temps relatif (il y a X minutes/heures/jours)
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return formatDate;
  }
}

/// Extensions pour les listes
extension ListExtensions<T> on List<T> {
  /// Récupère l'élément à l'index ou null si hors limites
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// Sépare la liste avec un élément
  List<T> separatedBy(T separator) {
    if (isEmpty) return [];
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}

/// Extensions pour BuildContext (navigation et theming)
extension BuildContextExtensions on BuildContext {
  /// Accès rapide au thème
  ThemeData get theme => Theme.of(this);
  
  /// Accès rapide au TextTheme
  TextTheme get textTheme => theme.textTheme;
  
  /// Accès rapide au ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Vérifie si le thème est sombre
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  /// Largeur de l'écran
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Hauteur de l'écran
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Padding du système (safe area)
  EdgeInsets get safePadding => MediaQuery.of(this).padding;
  
  /// Navigation: retour
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  
  /// Navigation: push
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
    MaterialPageRoute(builder: (_) => page),
  );
  
  /// Navigation: replace
  Future<T?> pushReplacement<T>(Widget page) => Navigator.of(this).pushReplacement(
    MaterialPageRoute(builder: (_) => page),
  );
  
  /// Affiche un SnackBar
  void showSnackBar(String message, {Color? backgroundColor, Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  
  /// Affiche un SnackBar d'erreur
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }
  
  /// Affiche un SnackBar de succès
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}

/// Extensions pour les widgets
extension WidgetExtensions on Widget {
  /// Ajoute un padding
  Widget withPadding(EdgeInsets padding) => Padding(padding: padding, child: this);
  
  /// Ajoute un padding horizontal et vertical
  Widget withSymmetricPadding({double horizontal = 0, double vertical = 0}) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
  
  /// Ajoute une marge
  Widget withMargin(EdgeInsets margin) => Container(margin: margin, child: this);
  
  /// Centre le widget
  Widget centered() => Center(child: this);
  
  /// Rend le widget cliquable
  Widget onTap(VoidCallback? onTap) => GestureDetector(onTap: onTap, child: this);
  
  /// Rend le widget visible ou non
  Widget visible(bool isVisible) => Visibility(visible: isVisible, child: this);
  
  /// Rend le widget opaque ou transparent
  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);
  
  /// Enveloppe dans un Expanded
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
  
  /// Enveloppe dans un Flexible
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);
  
  /// Ajoute un SafeArea
  Widget safeArea({bool top = true, bool bottom = true}) => 
      SafeArea(top: top, bottom: bottom, child: this);
}
