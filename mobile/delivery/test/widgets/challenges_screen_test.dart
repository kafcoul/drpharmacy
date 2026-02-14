import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:courier_flutter/presentation/screens/challenges_screen.dart';

Widget buildTestWidget({required Map<String, dynamic> data}) {
  return ProviderScope(
    overrides: [
      challengesProvider.overrideWith((ref) => Future.value(data)),
    ],
    child: const MaterialApp(home: ChallengesScreen()),
  );
}

Map<String, dynamic> _makeData({
  List<Map<String, dynamic>> inProgress = const [],
  List<Map<String, dynamic>> completed = const [],
  List<Map<String, dynamic>> rewarded = const [],
  List<Map<String, dynamic>> activeBonuses = const [],
  Map<String, dynamic> stats = const {},
}) {
  return {
    'challenges': {
      'in_progress': inProgress,
      'completed': completed,
      'rewarded': rewarded,
    },
    'active_bonuses': activeBonuses,
    'stats': stats,
  };
}

Map<String, dynamic> _challenge({
  int id = 1,
  String title = 'Défi Test',
  String description = 'Description test',
  int progressPercent = 50,
  int currentProgress = 5,
  int targetValue = 10,
  int rewardAmount = 1000,
  String color = 'amber',
  String? icon,
}) {
  return {
    'id': id,
    'title': title,
    'description': description,
    'progress_percent': progressPercent,
    'current_progress': currentProgress,
    'target_value': targetValue,
    'reward_amount': rewardAmount,
    'color': color,
    'icon': icon,
  };
}

void main() {
  group('ChallengesScreen', () {
    testWidgets('shows header title', (tester) async {
      await tester.pumpWidget(buildTestWidget(data: _makeData()));
      await tester.pumpAndSettle();
      expect(find.text('Défis & Bonus'), findsOneWidget);
    });

    testWidgets('shows stats badges', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: _makeData(stats: {
          'in_progress_count': 3,
          'can_claim_count': 1,
          'rewarded_count': 5,
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget); // in progress
      expect(find.text('1'), findsOneWidget); // can claim
      expect(find.text('5'), findsOneWidget); // rewarded
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('À réclamer'), findsOneWidget);
    });

    testWidgets('shows empty state when no challenges', (tester) async {
      await tester.pumpWidget(buildTestWidget(data: _makeData()));
      await tester.pumpAndSettle();
      expect(find.text('Aucun défi disponible'), findsOneWidget);
    });

    testWidgets('shows in progress challenges', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: _makeData(
          inProgress: [
            _challenge(title: 'Livrer 10 colis', currentProgress: 5, targetValue: 10),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('⏳ En Cours'), findsOneWidget);
      expect(find.text('Livrer 10 colis'), findsOneWidget);
      expect(find.text('5 / 10'), findsOneWidget);
    });

    testWidgets('shows completed challenges with claim button', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: _makeData(
          completed: [
            _challenge(title: 'Défi complété', rewardAmount: 2000),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('🎉 À Réclamer !'), findsOneWidget);
      expect(find.text('Défi complété'), findsOneWidget);
      expect(find.text('Réclamer'), findsOneWidget);
    });

    testWidgets('shows rewarded challenges', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: _makeData(
          rewarded: [
            _challenge(title: 'Défi récompensé'),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('✅ Complétés'), findsOneWidget);
      expect(find.text('Défi récompensé'), findsOneWidget);
      expect(find.text('Réclamé'), findsOneWidget);
    });

    testWidgets('shows active bonuses', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: _makeData(
          activeBonuses: [
            {'name': 'Bonus Weekend', 'description': 'x2 sur les gains'},
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('🔥 Bonus Actifs'), findsOneWidget);
      expect(find.text('Bonus Weekend'), findsOneWidget);
    });

    testWidgets('shows reward amount on challenge card', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: _makeData(
          inProgress: [
            _challenge(title: 'Test', rewardAmount: 5000),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      // NumberFormat uses non-breaking space in fr_FR
      expect(find.textContaining('5'), findsAtLeastNWidgets(1));
      expect(find.textContaining('F'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows progress bar for in-progress challenge', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        data: _makeData(
          inProgress: [
            _challenge(progressPercent: 75),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('loading state shows indicator', (tester) async {
      late Future<Map<String, dynamic>> completer;
      completer = Future(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return <String, dynamic>{};
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengesProvider.overrideWith((ref) => completer),
          ],
          child: const MaterialApp(home: ChallengesScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
      await tester.pumpAndSettle();
    });
  });
}
