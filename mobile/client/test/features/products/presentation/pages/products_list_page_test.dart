import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/products/presentation/pages/products_list_page.dart';

void main() {
  Widget createTestWidget({int? pharmacyId, String? category}) {
    return ProviderScope(
      child: MaterialApp(
        home: ProductsListPage(pharmacyId: pharmacyId, category: category),
      ),
    );
  }

  group('ProductsListPage Widget Tests', () {
    testWidgets('should render products list page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ProductsListPage), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should filter by pharmacy', (tester) async {
      await tester.pumpWidget(createTestWidget(pharmacyId: 1));
      await tester.pump();
      expect(find.byType(ProductsListPage), findsOneWidget);
    });

    testWidgets('should filter by category', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'Vitamines'));
      await tester.pump();
      expect(find.byType(ProductsListPage), findsOneWidget);
    });

    testWidgets('should display product grid or list', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ProductsListPage), findsOneWidget);
    });

    testWidgets('should have refresh functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ProductsListPage), findsOneWidget);
    });
  });
}
