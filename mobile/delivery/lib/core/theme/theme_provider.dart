import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour le mode thème (clair/sombre)
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    // Par défaut, utiliser le thème clair
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return; // Provider may have been disposed during await
    final themeString = prefs.getString(_themeKey);
    
    if (themeString != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == themeString,
        orElse: () => ThemeMode.light,
      );
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }

  bool get isDark => state == ThemeMode.dark;
  bool get isLight => state == ThemeMode.light;
  bool get isSystem => state == ThemeMode.system;
}

/// Thème clair personnalisé
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F9FD),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade200,
    thickness: 1,
  ),
);

/// Thème sombre personnalisé
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white70),
    labelLarge: TextStyle(color: Colors.white),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2C2C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    modalBackgroundColor: Color(0xFF1E1E1E),
    surfaceTintColor: Colors.transparent,
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF2C2C2C),
    thickness: 1,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white70,
    textColor: Colors.white,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.blue;
      }
      return Colors.grey;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.blue.withValues(alpha: 0.5);
      }
      return Colors.grey.withValues(alpha: 0.3);
    }),
  ),
);

/// Extension pour accéder facilement aux couleurs du thème
extension ThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  Color get scaffoldBackground => isDark 
      ? const Color(0xFF121212) 
      : const Color(0xFFF8F9FD);
  
  Color get cardBackground => isDark 
      ? const Color(0xFF1E1E1E) 
      : Colors.white;
  
  Color get surfaceColor => isDark 
      ? const Color(0xFF2C2C2C) 
      : Colors.grey.shade100;
  
  Color get primaryText => isDark 
      ? Colors.white 
      : Colors.black;
  
  Color get secondaryText => isDark 
      ? Colors.white70 
      : Colors.grey.shade600;
  
  Color get tertiaryText => isDark 
      ? Colors.white54 
      : Colors.grey.shade500;
  
  Color get dividerColor => isDark 
      ? const Color(0xFF2C2C2C) 
      : Colors.grey.shade200;
  
  Color get iconColor => isDark 
      ? Colors.white70 
      : Colors.grey.shade700;
}
