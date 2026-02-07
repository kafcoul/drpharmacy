import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/utils/page_transitions.dart';

void main() {
  group('PageTransitions', () {
    testWidgets('SlideRightRoute should animate from left to right', (tester) async {
      final page = Container(key: const Key('test-page'));
      final route = SlideRightRoute(page: page);

      expect(route.transitionDuration, const Duration(milliseconds: 300));
      expect(route.pageBuilder(tester.element(find.byType(Container)), const AlwaysStoppedAnimation(1.0), const AlwaysStoppedAnimation(0.0)), isNotNull);
    });

    testWidgets('SlideUpRoute should animate from bottom to top', (tester) async {
      final page = Container(key: const Key('test-page'));
      final route = SlideUpRoute(page: page);

      expect(route.transitionDuration, const Duration(milliseconds: 400));
    });

    testWidgets('FadeRoute should fade in', (tester) async {
      final page = Container(key: const Key('test-page'));
      final route = FadeRoute(page: page);

      expect(route.transitionDuration, const Duration(milliseconds: 300));
    });

    testWidgets('ScaleRoute should scale and fade in', (tester) async {
      final page = Container(key: const Key('test-page'));
      final route = ScaleRoute(page: page);

      expect(route.transitionDuration, const Duration(milliseconds: 300));
    });

    testWidgets('SlideAndFadeRoute should slide from left by default', (tester) async {
      final page = Container(key: const Key('test-page'));
      final route = SlideAndFadeRoute(page: page);

      expect(route.transitionDuration, const Duration(milliseconds: 350));
      expect(route.direction, AxisDirection.left);
    });

    testWidgets('SlideAndFadeRoute should accept direction parameter', (tester) async {
      final page = Container(key: const Key('test-page'));
      final routeUp = SlideAndFadeRoute(page: page, direction: AxisDirection.up);
      final routeDown = SlideAndFadeRoute(page: page, direction: AxisDirection.down);
      final routeLeft = SlideAndFadeRoute(page: page, direction: AxisDirection.left);
      final routeRight = SlideAndFadeRoute(page: page, direction: AxisDirection.right);

      expect(routeUp.direction, AxisDirection.up);
      expect(routeDown.direction, AxisDirection.down);
      expect(routeLeft.direction, AxisDirection.left);
      expect(routeRight.direction, AxisDirection.right);
    });

    group('SlideRightRoute transitions', () {
      testWidgets('should build page correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  SlideRightRoute(page: const Scaffold(body: Text('Target'))),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Target'), findsOneWidget);
      });
    });

    group('SlideUpRoute transitions', () {
      testWidgets('should build page correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  SlideUpRoute(page: const Scaffold(body: Text('Target'))),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Target'), findsOneWidget);
      });
    });

    group('FadeRoute transitions', () {
      testWidgets('should build page correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  FadeRoute(page: const Scaffold(body: Text('Target'))),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Target'), findsOneWidget);
      });
    });

    group('ScaleRoute transitions', () {
      testWidgets('should build page correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  ScaleRoute(page: const Scaffold(body: Text('Target'))),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Target'), findsOneWidget);
      });
    });

    group('SlideAndFadeRoute transitions', () {
      testWidgets('should build page correctly with default direction', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  SlideAndFadeRoute(page: const Scaffold(body: Text('Target'))),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Target'), findsOneWidget);
      });

      testWidgets('should build page correctly with up direction', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  SlideAndFadeRoute(
                    page: const Scaffold(body: Text('Target')),
                    direction: AxisDirection.up,
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Target'), findsOneWidget);
      });

      testWidgets('should build page correctly with down direction', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  SlideAndFadeRoute(
                    page: const Scaffold(body: Text('Target')),
                    direction: AxisDirection.down,
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Target'), findsOneWidget);
      });

      testWidgets('should build page correctly with right direction', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  SlideAndFadeRoute(
                    page: const Scaffold(body: Text('Target')),
                    direction: AxisDirection.right,
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Target'), findsOneWidget);
      });
    });

    group('NavigatorExtension', () {
      testWidgets('pushSlideRight should navigate with slide right animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.pushSlideRight(
                  const Scaffold(body: Text('SlideRight Target')),
                ),
                child: const Text('Go SlideRight'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go SlideRight'));
        await tester.pumpAndSettle();

        expect(find.text('SlideRight Target'), findsOneWidget);
      });

      testWidgets('pushSlideUp should navigate with slide up animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.pushSlideUp(
                  const Scaffold(body: Text('SlideUp Target')),
                ),
                child: const Text('Go SlideUp'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go SlideUp'));
        await tester.pumpAndSettle();

        expect(find.text('SlideUp Target'), findsOneWidget);
      });

      testWidgets('pushFade should navigate with fade animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.pushFade(
                  const Scaffold(body: Text('Fade Target')),
                ),
                child: const Text('Go Fade'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go Fade'));
        await tester.pumpAndSettle();

        expect(find.text('Fade Target'), findsOneWidget);
      });

      testWidgets('pushScale should navigate with scale animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.pushScale(
                  const Scaffold(body: Text('Scale Target')),
                ),
                child: const Text('Go Scale'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go Scale'));
        await tester.pumpAndSettle();

        expect(find.text('Scale Target'), findsOneWidget);
      });

      testWidgets('pushSlideAndFade should navigate with slide and fade animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => context.pushSlideAndFade(
                  const Scaffold(body: Text('SlideAndFade Target')),
                  direction: AxisDirection.up,
                ),
                child: const Text('Go SlideAndFade'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go SlideAndFade'));
        await tester.pumpAndSettle();

        expect(find.text('SlideAndFade Target'), findsOneWidget);
      });
    });
  });
}
