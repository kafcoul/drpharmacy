import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:courier_flutter/core/theme/theme_provider.dart';

void main() {
  group('ThemeProvider Tests', () {
    setUp(() {
      // Setup SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
    });

    test('should have system theme mode by default', () async {
      SharedPreferences.setMockInitialValues({});
      
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      // Wait for provider to initialize
      await Future.delayed(const Duration(milliseconds: 100));
      
      final themeMode = container.read(themeProvider);
      expect(themeMode, ThemeMode.system);
    });

    test('should persist theme mode to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Change theme to dark
      await container.read(themeProvider.notifier).setTheme(ThemeMode.dark);
      
      // Verify the change
      expect(container.read(themeProvider), ThemeMode.dark);
      
      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('should load saved theme mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      final themeMode = container.read(themeProvider);
      expect(themeMode, ThemeMode.light);
    });

    test('should toggle between light and dark mode', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(container.read(themeProvider), ThemeMode.light);
      
      await container.read(themeProvider.notifier).toggleTheme();
      
      expect(container.read(themeProvider), ThemeMode.dark);
    });
  });

  group('Light Theme Tests', () {
    test('should have correct primary color', () {
      expect(lightTheme.primaryColor, const Color(0xFF1E88E5));
    });

    test('should have white scaffold background', () {
      expect(lightTheme.scaffoldBackgroundColor, Colors.white);
    });

    test('should have correct app bar theme', () {
      expect(lightTheme.appBarTheme.backgroundColor, Colors.white);
      expect(lightTheme.appBarTheme.foregroundColor, const Color(0xFF1E1E1E));
    });
  });

  group('Dark Theme Tests', () {
    test('should have correct primary color', () {
      expect(darkTheme.primaryColor, const Color(0xFF42A5F5));
    });

    test('should have dark scaffold background', () {
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    test('should have correct app bar theme', () {
      expect(darkTheme.appBarTheme.backgroundColor, const Color(0xFF1E1E1E));
      expect(darkTheme.appBarTheme.foregroundColor, Colors.white);
    });

    test('should have elevated card color', () {
      expect(darkTheme.cardColor, const Color(0xFF1E1E1E));
    });
  });
}
