import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/products/presentation/widgets/category_chip.dart';
import 'package:drpharma_client/core/constants/app_colors.dart';

void main() {
  group('CategoryChip', () {
    testWidgets('should render with given name and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Test Category',
              icon: Icons.category,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Category'), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('should have primary color when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Selected Category',
              icon: Icons.star,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CategoryChip),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    testWidgets('should have white background when not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Unselected Category',
              icon: Icons.star,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CategoryChip),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Tap Me',
              icon: Icons.touch_app,
              isSelected: false,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('should have white icon when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Selected',
              icon: Icons.check,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(icon.color, Colors.white);
    });

    testWidgets('should have primary icon when not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Not Selected',
              icon: Icons.close,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.close));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('should have bold text when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Bold Category',
              icon: Icons.category,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Bold Category'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should have normal font weight when not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Normal Category',
              icon: Icons.category,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Normal Category'));
      expect(text.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('should have shadow when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Shadow Category',
              icon: Icons.category,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CategoryChip),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, isTrue);
    });

    testWidgets('should have no shadow when not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'No Shadow Category',
              icon: Icons.category,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CategoryChip),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });

    testWidgets('should have rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              name: 'Rounded Category',
              icon: Icons.category,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CategoryChip),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
    });
  });
}
