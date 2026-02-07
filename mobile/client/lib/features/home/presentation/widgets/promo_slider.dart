import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/models/promo_item.dart';

/// Widget du slider promotionnel
class PromoSlider extends StatelessWidget {
  final PageController controller;
  final List<PromoItem> items;
  final int currentIndex;
  final ValueChanged<int>? onPageChanged;
  final bool isDark;

  const PromoSlider({
    super.key,
    required this.controller,
    required this.items,
    required this.currentIndex,
    this.onPageChanged,
    this.isDark = false,
  });

  void _handlePromoTap(BuildContext context, PromoItem promo) {
    switch (promo.actionType) {
      case 'onDuty':
        context.goToOnDutyPharmacies();
        break;
      case 'prescription':
        context.goToPrescriptionUpload();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final promo = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _PromoCard(
                  promo: promo,
                  isDark: isDark,
                  onTap: promo.actionType != null
                      ? () => _handlePromoTap(context, promo)
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _PageIndicators(
          itemCount: items.length,
          currentIndex: currentIndex,
          activeColor: AppColors.primary,
          inactiveColor: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ],
    );
  }
}

/// Carte promotionnelle individuelle
class _PromoCard extends StatelessWidget {
  final PromoItem promo;
  final bool isDark;
  final VoidCallback? onTap;

  const _PromoCard({
    required this.promo,
    required this.isDark,
    this.onTap,
  });

  /// Convertit les valeurs int en Color (dans la couche Presentation)
  List<Color> get _gradientColors =>
      promo.gradientColorValues.map((v) => Color(v)).toList();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Cercles décoratifs
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            promo.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          promo.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promo.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (promo.actionType != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        promo.actionType == 'onDuty'
                            ? Icons.map_outlined
                            : Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicateurs de page (dots)
class _PageIndicators extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const _PageIndicators({
    required this.itemCount,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
