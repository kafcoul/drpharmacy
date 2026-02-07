import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';

/// Widget de sélection du mode de thème
class ThemeModeSelector extends ConsumerWidget {
  final bool showLabels;
  final bool isCompact;

  const ThemeModeSelector({
    super.key,
    this.showLabels = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final currentMode = themeState.appThemeMode;

    if (isCompact) {
      return _buildCompactSelector(context, ref, currentMode);
    }

    return _buildFullSelector(context, ref, currentMode);
  }

  Widget _buildCompactSelector(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    return SegmentedButton<AppThemeMode>(
      segments: const [
        ButtonSegment(
          value: AppThemeMode.light,
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: AppThemeMode.system,
          icon: Icon(Icons.brightness_auto),
        ),
        ButtonSegment(
          value: AppThemeMode.dark,
          icon: Icon(Icons.dark_mode),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (Set<AppThemeMode> selection) {
        ref.read(themeProvider.notifier).setAppThemeMode(selection.first);
      },
    );
  }

  Widget _buildFullSelector(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels) ...[
          Text(
            'Thème',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
        ],
        _ThemeOption(
          icon: Icons.brightness_auto,
          title: 'Système',
          subtitle: 'Suit le thème de l\'appareil',
          isSelected: currentMode == AppThemeMode.system,
          onTap: () =>
              ref.read(themeProvider.notifier).setAppThemeMode(AppThemeMode.system),
        ),
        const SizedBox(height: 8),
        _ThemeOption(
          icon: Icons.light_mode,
          title: 'Clair',
          subtitle: 'Toujours utiliser le thème clair',
          isSelected: currentMode == AppThemeMode.light,
          onTap: () =>
              ref.read(themeProvider.notifier).setAppThemeMode(AppThemeMode.light),
        ),
        const SizedBox(height: 8),
        _ThemeOption(
          icon: Icons.dark_mode,
          title: 'Sombre',
          subtitle: 'Toujours utiliser le thème sombre',
          isSelected: currentMode == AppThemeMode.dark,
          onTap: () =>
              ref.read(themeProvider.notifier).setAppThemeMode(AppThemeMode.dark),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : null,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton simple pour basculer le thème (toggle)
class ThemeToggleButton extends ConsumerWidget {
  final double? iconSize;

  const ThemeToggleButton({super.key, this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return IconButton(
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween(begin: 0.5, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          size: iconSize,
        ),
      ),
      tooltip: isDark ? 'Passer en mode clair' : 'Passer en mode sombre',
    );
  }
}

/// ListTile pour les paramètres avec toggle de thème
class ThemeSettingsTile extends ConsumerWidget {
  const ThemeSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    String getModeLabel() {
      switch (themeState.appThemeMode) {
        case AppThemeMode.system:
          return 'Système';
        case AppThemeMode.light:
          return 'Clair';
        case AppThemeMode.dark:
          return 'Sombre';
      }
    }

    return ListTile(
      leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
      title: const Text('Thème'),
      subtitle: Text(getModeLabel()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const ThemeModeSelector(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Widget de preview des thèmes
class ThemePreviewCard extends StatelessWidget {
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          children: [
            // Header simulé
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
            ),
            // Content simulé
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simulated card
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Simulated text lines
                    Container(
                      height: 8,
                      width: 80,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 8,
                      width: 60,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    // Simulated button
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
