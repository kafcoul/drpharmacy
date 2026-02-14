import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:courier_flutter/data/models/courier_profile.dart';
import 'package:courier_flutter/data/models/wallet_data.dart';
import 'package:courier_flutter/presentation/widgets/home/home_status_bar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  final testProfile = CourierProfile(
    id: 1,
    name: 'Jean Dupont',
    email: 'jean@test.com',
    status: 'active',
    vehicleType: 'moto',
    plateNumber: 'AB-1234',
    rating: 4.8,
    completedDeliveries: 150,
    earnings: 75000,
  );

  final testWallet = WalletData(
    balance: 12500,
    currency: 'XOF',
    transactions: [],
  );

  Widget buildWidget({
    AsyncValue<CourierProfile>? profileAsync,
    FutureOr<WalletData?> Function(Ref)? walletBuilder,
  }) {
    return ProviderScope(
      overrides: [
        if (walletBuilder != null)
          homeWalletProvider.overrideWith((ref) => walletBuilder(ref)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              HomeStatusBar(
                profileAsync: profileAsync ?? AsyncValue.data(testProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('HomeStatusBar - wallet pill', () {
    testWidgets('displays formatted balance with FCFA', (tester) async {
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => Future.value(testWallet),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('FCFA'), findsOneWidget);
      expect(find.textContaining('12'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays monetization icon', (tester) async {
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => Future.value(testWallet),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
    });

    testWidgets('displays loading indicator when wallet loading', (tester) async {
      final completer = Completer<WalletData?>();
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => completer.future,
      ));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays --- FCFA on wallet error', (tester) async {
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => Future<WalletData?>.error('error'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('--- FCFA'), findsOneWidget);
    });

    testWidgets('displays 0 FCFA when wallet is null', (tester) async {
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => Future.value(null),
      ));
      await tester.pumpAndSettle();

      expect(find.text('0 FCFA'), findsOneWidget);
    });
  });

  group('HomeStatusBar - profile info', () {
    testWidgets('displays first name from profile', (tester) async {
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => Future.value(testWallet),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Jean'), findsOneWidget);
    });

    testWidgets('displays person icon avatar', (tester) async {
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => Future.value(testWallet),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays loading when profile is loading', (tester) async {
      final completer = Completer<WalletData?>();
      await tester.pumpWidget(buildWidget(
        profileAsync: const AsyncLoading<CourierProfile>(),
        walletBuilder: (_) => completer.future,
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error icon when profile errors', (tester) async {
      await tester.pumpWidget(buildWidget(
        profileAsync: AsyncError<CourierProfile>('error', StackTrace.current),
        walletBuilder: (_) => Future.value(testWallet),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('HomeStatusBar - layout', () {
    testWidgets('renders Card widget', (tester) async {
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => Future.value(testWallet),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders as Positioned widget', (tester) async {
      await tester.pumpWidget(buildWidget(
        walletBuilder: (_) => Future.value(testWallet),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Positioned), findsOneWidget);
    });
  });
}
