import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

/// Widget shimmer de base pour les effets de chargement
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Skeleton pour une carte de produit
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            const ShimmerLoading(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(height: 8),
            // Title placeholder
            const ShimmerLoading(
              width: double.infinity,
              height: 16,
            ),
            const SizedBox(height: 4),
            // Description placeholder
            ShimmerLoading(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 12,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price placeholder
                const ShimmerLoading(
                  width: 80,
                  height: 20,
                ),
                // Button placeholder
                ShimmerLoading(
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton pour une liste de produits
class ProductsListSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductsListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }
}

/// Skeleton pour une carte de commande
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order number
                const ShimmerLoading(width: 100, height: 16),
                // Status badge
                ShimmerLoading(
                  width: 80,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date
            const ShimmerLoading(width: 120, height: 12),
            const SizedBox(height: 8),
            // Items count
            const ShimmerLoading(width: 150, height: 12),
            const SizedBox(height: 12),
            // Total
            const ShimmerLoading(width: 100, height: 18),
          ],
        ),
      ),
    );
  }
}

/// Skeleton pour une liste de commandes
class OrdersListSkeleton extends StatelessWidget {
  final int itemCount;

  const OrdersListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const OrderCardSkeleton(),
    );
  }
}

/// Skeleton pour le profil
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: const ShimmerLoading(
                    width: 120,
                    height: 120,
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                const ShimmerLoading(width: 150, height: 24),
                const SizedBox(height: 8),
                // Email
                const ShimmerLoading(width: 200, height: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const ShimmerLoading(width: 120, height: 20),
                const SizedBox(height: 16),
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: ShimmerLoading(
                        width: double.infinity,
                        height: 120,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ShimmerLoading(
                        width: double.infinity,
                        height: 120,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ShimmerLoading(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
