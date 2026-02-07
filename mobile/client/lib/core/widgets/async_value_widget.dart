import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget utilitaire pour gérer les états AsyncValue de manière uniforme
/// Simplifie l'affichage loading/error/data dans toute l'application
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;
  final Widget Function()? empty;
  final bool skipLoadingOnRefresh;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
    this.skipLoadingOnRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) {
        // Gérer le cas où la data est null ou liste vide
        if (d == null || (d is List && d.isEmpty)) {
          return empty?.call() ?? _buildDefaultEmpty(context);
        }
        return data(d);
      },
      loading: () => loading?.call() ?? _buildDefaultLoading(context),
      error: (e, st) => error?.call(e, st) ?? _buildDefaultError(context, e),
      skipLoadingOnRefresh: skipLoadingOnRefresh,
    );
  }

  Widget _buildDefaultLoading(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildDefaultError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget Sliver version pour utilisation dans CustomScrollView
class AsyncValueSliverWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;
  final Widget Function()? empty;

  const AsyncValueSliverWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) {
        if (d == null || (d is List && d.isEmpty)) {
          return SliverFillRemaining(
            child: empty?.call() ?? _buildDefaultEmpty(context),
          );
        }
        return data(d);
      },
      loading: () => SliverFillRemaining(
        child: loading?.call() ?? const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => SliverFillRemaining(
        child: error?.call(e, st) ?? _buildDefaultError(context, e),
      ),
    );
  }

  Widget _buildDefaultError(BuildContext context, Object error) {
    return Center(
      child: Text('Erreur: $error'),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    return const Center(
      child: Text('Aucune donnée'),
    );
  }
}

/// Extension pour simplifier l'utilisation dans les widgets
extension AsyncValueUIExtensions<T> on AsyncValue<T> {
  /// Construit un widget basé sur l'état
  Widget buildWidget({
    required Widget Function(T data) data,
    Widget Function()? loading,
    Widget Function(Object error, StackTrace? stack)? error,
  }) {
    return when(
      data: data,
      loading: loading ?? () => const CircularProgressIndicator(),
      error: error ?? (e, _) => Text('Erreur: $e'),
    );
  }

  /// Retourne true si les données sont valides (non null et non vide pour les listes)
  bool get hasData {
    return maybeWhen(
      data: (d) => d != null && (d is! List || d.isNotEmpty),
      orElse: () => false,
    );
  }
}
