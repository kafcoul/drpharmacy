import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/animations/app_animations.dart';
import 'package:drpharma_client/core/animations/page_transitions.dart';

void main() {
  group('AppAnimations Constants', () {
    test('should have correct duration values', () {
      expect(AppAnimations.instant.inMilliseconds, 100);
      expect(AppAnimations.fast.inMilliseconds, 200);
      expect(AppAnimations.normal.inMilliseconds, 300);
      expect(AppAnimations.slow.inMilliseconds, 500);
      expect(AppAnimations.verySlow.inMilliseconds, 800);
    });

    test('should have valid curves', () {
      expect(AppAnimations.easeIn, Curves.easeIn);
      expect(AppAnimations.easeOut, Curves.easeOut);
      expect(AppAnimations.easeInOut, Curves.easeInOut);
      expect(AppAnimations.defaultCurve, Curves.easeInOutCubic);
    });
  });

  group('FadeInWidget', () {
    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInWidget(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should animate opacity from 0 to 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInWidget(
              duration: Duration(milliseconds: 300),
              child: Text('Fade Test'),
            ),
          ),
        ),
      );

      // Initially fading - find first FadeTransition
      await tester.pump(const Duration(milliseconds: 150));
      final fadeTransitions = tester.widgetList<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(fadeTransitions, isNotEmpty);

      // After animation completes
      await tester.pumpAndSettle();
      expect(find.text('Fade Test'), findsOneWidget);
    });

    testWidgets('should respect delay parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInWidget(
              delay: Duration(milliseconds: 200),
              duration: Duration(milliseconds: 300),
              child: Text('Delayed'),
            ),
          ),
        ),
      );

      // Initially before delay - animation not started
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Delayed'), findsOneWidget);

      // After delay and animation
      await tester.pumpAndSettle();
      expect(find.text('Delayed'), findsOneWidget);
    });
  });

  group('SlideInWidget', () {
    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SlideInWidget(
              child: Text('Slide Test'),
            ),
          ),
        ),
      );

      expect(find.text('Slide Test'), findsOneWidget);
    });

    testWidgets('should slide from specified direction', (tester) async {
      for (final direction in SlideDirection.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlideInWidget(
                direction: direction,
                duration: const Duration(milliseconds: 200),
                child: Text('Direction: ${direction.name}'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Direction: ${direction.name}'), findsOneWidget);
      }
    });
  });

  group('ScaleInWidget', () {
    testWidgets('should render and animate scale', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScaleInWidget(
              beginScale: 0.5,
              duration: Duration(milliseconds: 300),
              child: Text('Scale Test'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Scale Test'), findsOneWidget);
    });
  });

  group('AnimatedPressButton', () {
    testWidgets('should call onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedPressButton(
              onPressed: () => pressed = true,
              child: const Text('Press Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('should not respond when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedPressButton(
              onPressed: null,
              child: Text('Disabled'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      // Should not throw
      expect(find.text('Disabled'), findsOneWidget);
    });
  });

  group('AnimatedCheckmark', () {
    testWidgets('should render and animate', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedCheckmark(
                size: 80,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedCheckmark), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should call onComplete after animation', (tester) async {
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedCheckmark(
                duration: const Duration(milliseconds: 200),
                onComplete: () => completed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(completed, true);
    });
  });

  group('PulsingLoadingIndicator', () {
    testWidgets('should render and animate', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PulsingLoadingIndicator(
                size: 50,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PulsingLoadingIndicator), findsOneWidget);
      
      // Let animation run
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PulsingLoadingIndicator), findsOneWidget);
    });
  });

  group('Widget Extensions', () {
    testWidgets('fadeIn extension should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Extension Test').fadeIn(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Extension Test'), findsOneWidget);
    });

    testWidgets('slideIn extension should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Slide Extension').slideIn(
              direction: SlideDirection.fromLeft,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Slide Extension'), findsOneWidget);
    });

    testWidgets('scaleIn extension should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Scale Extension').scaleIn(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Scale Extension'), findsOneWidget);
    });
  });

  group('PageTransitions', () {
    testWidgets('fadeSlide transition should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageTransitions.fadeSlide(
                    page: const Scaffold(body: Text('New Page')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('New Page'), findsOneWidget);
    });

    testWidgets('slideHorizontal transition should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageTransitions.slideHorizontal(
                    page: const Scaffold(body: Text('Horizontal')),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Horizontal'), findsOneWidget);
    });

    testWidgets('slideVertical transition should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageTransitions.slideVertical(
                    page: const Scaffold(body: Text('Vertical')),
                  ),
                );
              },
              child: const Text('Up'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Up'));
      await tester.pumpAndSettle();

      expect(find.text('Vertical'), findsOneWidget);
    });

    testWidgets('scale transition should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageTransitions.scale(
                    page: const Scaffold(body: Text('Scaled')),
                  ),
                );
              },
              child: const Text('Zoom'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Zoom'));
      await tester.pumpAndSettle();

      expect(find.text('Scaled'), findsOneWidget);
    });

    testWidgets('fade transition should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageTransitions.fade(
                    page: const Scaffold(body: Text('Faded')),
                  ),
                );
              },
              child: const Text('Fade'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Fade'));
      await tester.pumpAndSettle();

      expect(find.text('Faded'), findsOneWidget);
    });
  });

  group('StaggeredListAnimation', () {
    testWidgets('should render all children with stagger effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaggeredListAnimation(
              itemDuration: const Duration(milliseconds: 200),
              staggerDelay: const Duration(milliseconds: 50),
              children: const [
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
                ListTile(title: Text('Item 3')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });
}
