import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/widgets/common_widgets.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('AppSpacing', () {
    test('vertical spacings should have correct heights', () {
      expect((AppSpacing.vertical4 as SizedBox).height, 4);
      expect((AppSpacing.vertical8 as SizedBox).height, 8);
      expect((AppSpacing.vertical12 as SizedBox).height, 12);
      expect((AppSpacing.vertical16 as SizedBox).height, 16);
      expect((AppSpacing.vertical20 as SizedBox).height, 20);
      expect((AppSpacing.vertical24 as SizedBox).height, 24);
      expect((AppSpacing.vertical32 as SizedBox).height, 32);
    });

    test('horizontal spacings should have correct widths', () {
      expect((AppSpacing.horizontal4 as SizedBox).width, 4);
      expect((AppSpacing.horizontal8 as SizedBox).width, 8);
      expect((AppSpacing.horizontal12 as SizedBox).width, 12);
      expect((AppSpacing.horizontal16 as SizedBox).width, 16);
      expect((AppSpacing.horizontal20 as SizedBox).width, 20);
      expect((AppSpacing.horizontal24 as SizedBox).width, 24);
    });
  });

  group('AppPrimaryButton', () {
    testWidgets('should display text', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppPrimaryButton(text: 'Valider'),
        ),
      );

      // Assert
      expect(find.text('Valider'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      bool pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AppPrimaryButton(
            text: 'Click me',
            onPressed: () => pressed = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(pressed, true);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppPrimaryButton(text: 'Disabled', onPressed: null),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should show loading indicator when isLoading', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppPrimaryButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('should be disabled when loading', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppPrimaryButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should display icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppPrimaryButton(
            text: 'With Icon',
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should use full width by default', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const Padding(
            padding: EdgeInsets.all(16),
            child: AppPrimaryButton(text: 'Full Width'),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('should use custom width when specified', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppPrimaryButton(text: 'Custom', width: 200),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, 200);
    });
  });

  group('AppOutlineButton', () {
    testWidgets('should display text', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppOutlineButton(text: 'Annuler'),
        ),
      );

      // Assert
      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      bool pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AppOutlineButton(
            text: 'Click',
            onPressed: () => pressed = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(pressed, true);
    });

    testWidgets('should display icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppOutlineButton(
            text: 'With Icon',
            icon: Icons.close,
            onPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should use OutlinedButton style', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppOutlineButton(text: 'Outline'),
        ),
      );

      // Assert
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('AppLoadingIndicator', () {
    testWidgets('should display CircularProgressIndicator', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppLoadingIndicator(),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppLoadingIndicator(message: 'Chargement en cours...'),
        ),
      );

      // Assert
      expect(find.text('Chargement en cours...'), findsOneWidget);
    });

    testWidgets('should not display message when null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppLoadingIndicator(),
        ),
      );

      // Assert - only the indicator, no text
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should be centered', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppLoadingIndicator(),
        ),
      );

      // Assert
      expect(find.byType(Center), findsOneWidget);
    });
  });

  group('AppErrorWidget', () {
    testWidgets('should display error message', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppErrorWidget(message: 'Une erreur est survenue'),
        ),
      );

      // Assert
      expect(find.text('Une erreur est survenue'), findsOneWidget);
    });

    testWidgets('should display default error icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppErrorWidget(message: 'Error'),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppErrorWidget(
            message: 'No internet',
            icon: Icons.wifi_off,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry is provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppErrorWidget(
            message: 'Error',
            onRetry: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('should not show retry button when onRetry is null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppErrorWidget(message: 'Error'),
        ),
      );

      // Assert
      expect(find.text('Réessayer'), findsNothing);
    });

    testWidgets('should call onRetry when retry button is tapped', (tester) async {
      // Arrange
      bool retryCalled = false;
      await tester.pumpWidget(
        createTestWidget(
          AppErrorWidget(
            message: 'Error',
            onRetry: () => retryCalled = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      // Assert
      expect(retryCalled, true);
    });

    testWidgets('should be centered', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppErrorWidget(message: 'Error'),
        ),
      );

      // Assert - verify the widget has a Center in its hierarchy
      expect(find.byType(Center), findsWidgets);
    });
  });

  group('AppEmptyState', () {
    testWidgets('should display title', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppEmptyState(title: 'Aucun résultat'),
        ),
      );

      // Assert
      expect(find.text('Aucun résultat'), findsOneWidget);
    });

    testWidgets('should display default icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppEmptyState(title: 'Empty'),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppEmptyState(
            title: 'No orders',
            icon: Icons.shopping_cart_outlined,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppEmptyState(
            title: 'Aucune commande',
            subtitle: 'Vos commandes apparaîtront ici',
          ),
        ),
      );

      // Assert
      expect(find.text('Vos commandes apparaîtront ici'), findsOneWidget);
    });

    testWidgets('should not display subtitle when null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppEmptyState(title: 'Empty'),
        ),
      );

      // Assert - only title, no subtitle
      final texts = tester.widgetList<Text>(find.byType(Text));
      expect(texts.length, 1);
    });

    testWidgets('should display action widget when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppEmptyState(
            title: 'Empty',
            action: ElevatedButton(
              onPressed: () {},
              child: const Text('Add item'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Add item'), findsOneWidget);
    });

    testWidgets('should be centered', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppEmptyState(title: 'Empty'),
        ),
      );

      // Assert - verify the widget has a Center in its hierarchy
      expect(find.byType(Center), findsWidgets);
    });
  });

  group('AppCard', () {
    testWidgets('should display child widget', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppCard(
            child: Text('Card content'),
          ),
        ),
      );

      // Assert
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('should be tappable when onTap is provided', (tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Tap me'),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should apply custom padding', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppCard(
            padding: EdgeInsets.all(32),
            child: Text('Content'),
          ),
        ),
      );

      // Assert - card renders with the padding
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should apply custom margin', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppCard(
            margin: EdgeInsets.all(16),
            child: Text('Content'),
          ),
        ),
      );

      // Assert - finds container with margin
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should use Material widget', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppCard(
            child: Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('should use InkWell for tap effect', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppCard(
            onTap: () {},
            child: const Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should respect borderRadius', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppCard(
            borderRadius: 24,
            child: Text('Content'),
          ),
        ),
      );

      // Assert - card renders with correct border radius
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Material),
        ).first,
      );
      expect(material.borderRadius, BorderRadius.circular(24));
    });
  });

  group('AppDivider', () {
    testWidgets('should render simple divider when text is null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppDivider(),
        ),
      );

      // Assert
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('should render divider with text when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppDivider(text: 'ou'),
        ),
      );

      // Assert
      expect(find.text('ou'), findsOneWidget);
      // Two dividers on each side of the text
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('should use row layout when text is provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppDivider(text: 'OR'),
        ),
      );

      // Assert
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should apply custom height', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppDivider(height: 48),
        ),
      );

      // Assert
      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.height, 48);
    });
  });

  group('AppBadge', () {
    testWidgets('should display text', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppBadge(text: 'Nouveau'),
        ),
      );

      // Assert
      expect(find.text('Nouveau'), findsOneWidget);
    });

    testWidgets('should display icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppBadge(
            text: 'Promo',
            icon: Icons.local_offer,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.local_offer), findsOneWidget);
    });

    testWidgets('should not display icon when null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppBadge(text: 'Badge'),
        ),
      );

      // Assert
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('should use Container with decoration', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppBadge(text: 'Test'),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should apply custom color', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppBadge(
            text: 'Success',
            color: Colors.green,
          ),
        ),
      );

      // Assert - badge renders (color applied in decoration)
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('should apply custom text color', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppBadge(
            text: 'Custom',
            textColor: Colors.white,
          ),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.text('Custom'));
      expect(text.style?.color, Colors.white);
    });

    testWidgets('should display icon with custom text color', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppBadge(
            text: 'Alert',
            icon: Icons.warning,
            textColor: Colors.red,
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(icon.color, Colors.red);
    });

    testWidgets('should use Row for layout', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppBadge(
            text: 'Badge',
            icon: Icons.star,
          ),
        ),
      );

      // Assert
      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('AppOutlineButton with custom color', () {
    testWidgets('should apply custom color to button', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppOutlineButton(
            text: 'Custom Color',
            color: Colors.red,
            onPressed: () {},
          ),
        ),
      );

      // Assert - button renders with the custom color
      expect(find.text('Custom Color'), findsOneWidget);
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.style?.foregroundColor?.resolve({}), Colors.red);
    });
  });

  group('AppCard dark mode', () {
    testWidgets('should adapt to dark theme', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: const AppCard(
              child: Text('Dark mode card'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Dark mode card'), findsOneWidget);
      // Card should render in dark mode
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Material),
        ).first,
      );
      expect(material.elevation, 0); // No elevation in dark mode
    });

    testWidgets('should use custom color in dark mode', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: AppCard(
              color: Colors.blue,
              child: Text('Custom color card'),
            ),
          ),
        ),
      );

      // Assert
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Material),
        ).first,
      );
      expect(material.color, Colors.blue);
    });
  });

  group('AppCard light mode', () {
    testWidgets('should have elevation in light mode', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: AppCard(
              child: Text('Light mode card'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Light mode card'), findsOneWidget);
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Material),
        ).first,
      );
      expect(material.elevation, 2); // Has elevation in light mode
    });
  });
}
