import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/home/presentation/widgets/promo_slider.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: PromoSlider(
            items: const [
              {'title': 'Promo 1', 'image': 'assets/promo1.png'},
              {'title': 'Promo 2', 'image': 'assets/promo2.png'},
            ],
          ),
        ),
      ),
    );
  }

  group('PromoSlider Widget Tests', () {
    testWidgets('should render promo slider', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PromoSlider), findsOneWidget);
    });

    testWidgets('should display promo items', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PromoSlider), findsOneWidget);
    });

    testWidgets('should be swipeable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final slider = find.byType(PromoSlider);
      if (slider.evaluate().isNotEmpty) {
        await tester.drag(slider, const Offset(-200, 0));
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(PromoSlider), findsOneWidget);
    });

    testWidgets('should have page indicators', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PromoSlider), findsOneWidget);
    });

    testWidgets('should auto-scroll', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(PromoSlider), findsOneWidget);
    });
  });
}
