import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drpharma_client/core/providers/theme_provider.dart';
import 'package:drpharma_client/config/providers.dart';

void main() {
  group('ThemeState', () {
    test('should have correct default values', () {
      const state = ThemeState();
      expect(state.appThemeMode, AppThemeMode.system);
      expect(state.themeMode, ThemeMode.system);
      expect(state.isSystemMode, true);
    });

    test('copyWith should create new instance with updated values', () {
      const original = ThemeState(
        appThemeMode: AppThemeMode.light,
        themeMode: ThemeMode.light,
      );

      final copied = original.copyWith(appThemeMode: AppThemeMode.dark);

      expect(copied.appThemeMode, AppThemeMode.dark);
      expect(original.appThemeMode, AppThemeMode.light);
    });

    test('equality should work correctly', () {
      const state1 = ThemeState(
        appThemeMode: AppThemeMode.dark,
        themeMode: ThemeMode.dark,
      );
      const state2 = ThemeState(
        appThemeMode: AppThemeMode.dark,
        themeMode: ThemeMode.dark,
      );
      const state3 = ThemeState(
        appThemeMode: AppThemeMode.light,
        themeMode: ThemeMode.light,
      );

      expect(state1, state2);
      expect(state1 == state3, false);
    });

    test('isDarkMode should return correct values for explicit modes', () {
      const darkState = ThemeState(
        appThemeMode: AppThemeMode.dark,
        themeMode: ThemeMode.dark,
      );
      const lightState = ThemeState(
        appThemeMode: AppThemeMode.light,
        themeMode: ThemeMode.light,
      );

      expect(darkState.isDarkMode, true);
      expect(darkState.isLightMode, false);
      expect(lightState.isDarkMode, false);
      expect(lightState.isLightMode, true);
    });

    test('isSystemMode should return true only for system mode', () {
      const systemState = ThemeState(appThemeMode: AppThemeMode.system);
      const darkState = ThemeState(appThemeMode: AppThemeMode.dark);
      const lightState = ThemeState(appThemeMode: AppThemeMode.light);

      expect(systemState.isSystemMode, true);
      expect(darkState.isSystemMode, false);
      expect(lightState.isSystemMode, false);
    });
  });

  group('AppThemeMode', () {
    test('should have all expected values', () {
      expect(AppThemeMode.values.length, 3);
      expect(AppThemeMode.values, contains(AppThemeMode.system));
      expect(AppThemeMode.values, contains(AppThemeMode.light));
      expect(AppThemeMode.values, contains(AppThemeMode.dark));
    });

    test('name should return correct string', () {
      expect(AppThemeMode.system.name, 'system');
      expect(AppThemeMode.light.name, 'light');
      expect(AppThemeMode.dark.name, 'dark');
    });
  });

  group('ThemeNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('should start with system mode by default', () async {
      final notifier = ThemeNotifier(prefs);
      
      // Wait for async _loadTheme
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(notifier.state.appThemeMode, AppThemeMode.system);
    });

    test('setLightMode should change to light mode', () async {
      final notifier = ThemeNotifier(prefs);
      
      await notifier.setLightMode();
      
      expect(notifier.state.appThemeMode, AppThemeMode.light);
      expect(notifier.state.themeMode, ThemeMode.light);
    });

    test('setDarkMode should change to dark mode', () async {
      final notifier = ThemeNotifier(prefs);
      
      await notifier.setDarkMode();
      
      expect(notifier.state.appThemeMode, AppThemeMode.dark);
      expect(notifier.state.themeMode, ThemeMode.dark);
    });

    test('setSystemMode should change to system mode', () async {
      final notifier = ThemeNotifier(prefs);
      
      await notifier.setDarkMode();
      await notifier.setSystemMode();
      
      expect(notifier.state.appThemeMode, AppThemeMode.system);
      expect(notifier.state.themeMode, ThemeMode.system);
    });

    test('toggleTheme should switch between light and dark', () async {
      final notifier = ThemeNotifier(prefs);
      
      await notifier.setLightMode();
      expect(notifier.state.appThemeMode, AppThemeMode.light);
      
      await notifier.toggleTheme();
      expect(notifier.state.appThemeMode, AppThemeMode.dark);
      
      await notifier.toggleTheme();
      expect(notifier.state.appThemeMode, AppThemeMode.light);
    });

    test('should persist theme choice', () async {
      final notifier = ThemeNotifier(prefs);
      
      await notifier.setDarkMode();
      
      expect(prefs.getString('theme_mode'), 'dark');
      
      await notifier.setLightMode();
      
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('should load persisted theme on creation', () async {
      await prefs.setString('theme_mode', 'dark');
      
      final notifier = ThemeNotifier(prefs);
      
      // Wait for async _loadTheme
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(notifier.state.appThemeMode, AppThemeMode.dark);
    });

    test('setAppThemeMode should work for all modes', () async {
      final notifier = ThemeNotifier(prefs);
      
      await notifier.setAppThemeMode(AppThemeMode.dark);
      expect(notifier.state.appThemeMode, AppThemeMode.dark);
      
      await notifier.setAppThemeMode(AppThemeMode.light);
      expect(notifier.state.appThemeMode, AppThemeMode.light);
      
      await notifier.setAppThemeMode(AppThemeMode.system);
      expect(notifier.state.appThemeMode, AppThemeMode.system);
    });

    test('legacy setTheme should work correctly', () async {
      final notifier = ThemeNotifier(prefs);
      
      await notifier.setTheme(ThemeMode.dark);
      expect(notifier.state.themeMode, ThemeMode.dark);
      
      await notifier.setTheme(ThemeMode.light);
      expect(notifier.state.themeMode, ThemeMode.light);
      
      await notifier.setTheme(ThemeMode.system);
      expect(notifier.state.themeMode, ThemeMode.system);
    });
  });

  group('Theme Providers', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('themeModeProvider should return correct ThemeMode', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 10));
      
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.system);
      
      await container.read(themeProvider.notifier).setDarkMode();
      final darkMode = container.read(themeModeProvider);
      expect(darkMode, ThemeMode.dark);
      
      container.dispose();
    });

    test('isDarkModeProvider should return correct boolean', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      
      await container.read(themeProvider.notifier).setLightMode();
      expect(container.read(isDarkModeProvider), false);
      
      await container.read(themeProvider.notifier).setDarkMode();
      expect(container.read(isDarkModeProvider), true);
      
      container.dispose();
    });
  });
}
