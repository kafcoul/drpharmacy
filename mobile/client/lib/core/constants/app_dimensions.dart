import 'package:flutter/material.dart';

/// Constantes de dimensions pour assurer la cohérence visuelle
class AppDimensions {
  AppDimensions._();
  
  // ==================== Spacing ====================
  
  /// 4.0 - Très petit espacement
  static const double spaceXS = 4.0;
  
  /// 8.0 - Petit espacement
  static const double spaceSM = 8.0;
  
  /// 12.0 - Espacement moyen-petit
  static const double spaceMD = 12.0;
  
  /// 16.0 - Espacement standard
  static const double space = 16.0;
  
  /// 20.0 - Espacement moyen-grand
  static const double spaceLG = 20.0;
  
  /// 24.0 - Grand espacement
  static const double spaceXL = 24.0;
  
  /// 32.0 - Très grand espacement
  static const double space2XL = 32.0;
  
  /// 48.0 - Espacement extra large
  static const double space3XL = 48.0;
  
  // ==================== Padding ====================
  
  /// Padding horizontal standard pour les pages
  static const double pagePaddingHorizontal = 20.0;
  
  /// Padding vertical standard pour les pages
  static const double pagePaddingVertical = 16.0;
  
  /// Padding standard des pages
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pagePaddingHorizontal,
    vertical: pagePaddingVertical,
  );
  
  /// Padding des cartes
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  
  /// Padding des boutons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );
  
  /// Padding des champs de formulaire
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 14.0,
  );
  
  // ==================== Border Radius ====================
  
  /// 4.0 - Très petit rayon
  static const double radiusXS = 4.0;
  
  /// 8.0 - Petit rayon
  static const double radiusSM = 8.0;
  
  /// 12.0 - Rayon standard
  static const double radius = 12.0;
  
  /// 16.0 - Grand rayon
  static const double radiusLG = 16.0;
  
  /// 20.0 - Très grand rayon
  static const double radiusXL = 20.0;
  
  /// 24.0 - Extra grand rayon
  static const double radius2XL = 24.0;
  
  /// Rayon standard pour les cartes
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(12.0));
  
  /// Rayon pour les boutons
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12.0));
  
  /// Rayon pour les champs de formulaire
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12.0));
  
  /// Rayon pour les bottom sheets
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
  
  // ==================== Icon Sizes ====================
  
  /// 16.0 - Petite icône
  static const double iconSM = 16.0;
  
  /// 20.0 - Icône standard petite
  static const double iconMD = 20.0;
  
  /// 24.0 - Icône standard
  static const double icon = 24.0;
  
  /// 32.0 - Grande icône
  static const double iconLG = 32.0;
  
  /// 48.0 - Très grande icône
  static const double iconXL = 48.0;
  
  /// 64.0 - Icône extra large
  static const double icon2XL = 64.0;
  
  // ==================== Component Heights ====================
  
  /// Hauteur des boutons standards
  static const double buttonHeight = 52.0;
  
  /// Hauteur des champs de formulaire
  static const double inputHeight = 56.0;
  
  /// Hauteur de l'AppBar
  static const double appBarHeight = 56.0;
  
  /// Hauteur de la BottomNavigationBar
  static const double bottomNavHeight = 64.0;
  
  /// Hauteur des éléments de liste
  static const double listItemHeight = 72.0;
  
  // ==================== Elevation ====================
  
  /// 0.0 - Pas d'ombre
  static const double elevationNone = 0.0;
  
  /// 2.0 - Ombre légère
  static const double elevationSM = 2.0;
  
  /// 4.0 - Ombre standard
  static const double elevation = 4.0;
  
  /// 8.0 - Ombre moyenne
  static const double elevationLG = 8.0;
  
  /// 12.0 - Grande ombre
  static const double elevationXL = 12.0;
  
  // ==================== Animation Durations ====================
  
  /// 150ms - Animation très rapide
  static const Duration animationFast = Duration(milliseconds: 150);
  
  /// 300ms - Animation standard
  static const Duration animation = Duration(milliseconds: 300);
  
  /// 500ms - Animation lente
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  /// 1000ms - Animation très lente
  static const Duration animationVerySlow = Duration(milliseconds: 1000);
}
