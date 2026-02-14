import 'package:flutter/material.dart';

/// Overlay affiché quand le coursier est hors ligne (pas de livraison active)
class OfflineOverlay extends StatelessWidget {
  const OfflineOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.white54),
            SizedBox(height: 20),
            Text(
              'VOUS ÊTES HORS LIGNE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Passez en ligne pour recevoir des commandes',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
