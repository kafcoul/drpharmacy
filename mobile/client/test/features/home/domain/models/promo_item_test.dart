import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/home/domain/models/promo_item.dart';

void main() {
  group('PromoItem', () {
    group('creation', () {
      test('should create with all required fields', () {
        const promo = PromoItem(
          badge: 'Nouveau',
          title: 'Test Title',
          subtitle: 'Test Subtitle',
          gradientColorValues: [0xFF00A86B, 0xFF008556],
        );

        expect(promo.badge, equals('Nouveau'));
        expect(promo.title, equals('Test Title'));
        expect(promo.subtitle, equals('Test Subtitle'));
        expect(promo.gradientColorValues, equals([0xFF00A86B, 0xFF008556]));
        expect(promo.actionType, isNull);
      });

      test('should create with actionType', () {
        const promo = PromoItem(
          badge: 'Pharmacie de garde',
          title: 'Service 24h/24',
          subtitle: 'Trouvez une pharmacie ouverte',
          gradientColorValues: [0xFFFF5722, 0xFFE64A19],
          actionType: 'onDuty',
        );

        expect(promo.actionType, equals('onDuty'));
      });

      test('should create with prescription actionType', () {
        const promo = PromoItem(
          badge: 'Ordonnance',
          title: 'Envoyez votre ordonnance',
          subtitle: 'Recevez vos médicaments',
          gradientColorValues: [0xFF9C27B0, 0xFF7B1FA2],
          actionType: 'prescription',
        );

        expect(promo.actionType, equals('prescription'));
      });

      test('should handle empty badge', () {
        const promo = PromoItem(
          badge: '',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF000000],
        );

        expect(promo.badge, isEmpty);
      });

      test('should handle single gradient color', () {
        const promo = PromoItem(
          badge: 'Test',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF000000],
        );

        expect(promo.gradientColorValues.length, equals(1));
      });

      test('should handle multiple gradient colors', () {
        const promo = PromoItem(
          badge: 'Test',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF000000, 0xFF111111, 0xFF222222],
        );

        expect(promo.gradientColorValues.length, equals(3));
      });
    });

    group('gradient colors', () {
      test('should store hex color values correctly', () {
        const promo = PromoItem(
          badge: 'Test',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF00A86B, 0xFF008556],
        );

        expect(promo.gradientColorValues[0], equals(0xFF00A86B));
        expect(promo.gradientColorValues[1], equals(0xFF008556));
      });

      test('should store different color schemes', () {
        const greenPromo = PromoItem(
          badge: 'Green',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF00A86B, 0xFF008556],
        );

        const bluePromo = PromoItem(
          badge: 'Blue',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF00BCD4, 0xFF0097A7],
        );

        const orangePromo = PromoItem(
          badge: 'Orange',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFFFF5722, 0xFFE64A19],
        );

        const purplePromo = PromoItem(
          badge: 'Purple',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF9C27B0, 0xFF7B1FA2],
        );

        expect(greenPromo.gradientColorValues, isNot(equals(bluePromo.gradientColorValues)));
        expect(orangePromo.gradientColorValues, isNot(equals(purplePromo.gradientColorValues)));
      });
    });

    group('action types', () {
      test('should handle null actionType', () {
        const promo = PromoItem(
          badge: 'Test',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF000000],
          actionType: null,
        );

        expect(promo.actionType, isNull);
      });

      test('should store onDuty actionType', () {
        const promo = PromoItem(
          badge: 'Test',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF000000],
          actionType: 'onDuty',
        );

        expect(promo.actionType, equals('onDuty'));
      });

      test('should store prescription actionType', () {
        const promo = PromoItem(
          badge: 'Test',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF000000],
          actionType: 'prescription',
        );

        expect(promo.actionType, equals('prescription'));
      });

      test('should store custom actionType', () {
        const promo = PromoItem(
          badge: 'Test',
          title: 'Title',
          subtitle: 'Subtitle',
          gradientColorValues: [0xFF000000],
          actionType: 'customAction',
        );

        expect(promo.actionType, equals('customAction'));
      });
    });
  });

  group('PromoData', () {
    test('defaultPromos should not be empty', () {
      expect(PromoData.defaultPromos, isNotEmpty);
    });

    test('defaultPromos should contain 4 items', () {
      expect(PromoData.defaultPromos.length, equals(4));
    });

    test('first promo should be Livraison Gratuite', () {
      final firstPromo = PromoData.defaultPromos[0];
      expect(firstPromo.badge, equals('Nouveau'));
      expect(firstPromo.title, equals('Livraison Gratuite'));
      expect(firstPromo.subtitle, equals('Sur votre première commande'));
      expect(firstPromo.actionType, isNull);
    });

    test('second promo should be Vitamines & Compléments', () {
      final secondPromo = PromoData.defaultPromos[1];
      expect(secondPromo.badge, equals('-20%'));
      expect(secondPromo.title, equals('Vitamines & Compléments'));
      expect(secondPromo.subtitle, equals('Profitez des promotions santé'));
      expect(secondPromo.actionType, isNull);
    });

    test('third promo should have onDuty action', () {
      final thirdPromo = PromoData.defaultPromos[2];
      expect(thirdPromo.badge, equals('Pharmacie de garde'));
      expect(thirdPromo.title, equals('Service 24h/24'));
      expect(thirdPromo.actionType, equals('onDuty'));
    });

    test('fourth promo should have prescription action', () {
      final fourthPromo = PromoData.defaultPromos[3];
      expect(fourthPromo.badge, equals('Ordonnance'));
      expect(fourthPromo.title, equals('Envoyez votre ordonnance'));
      expect(fourthPromo.actionType, equals('prescription'));
    });

    test('all promos should have gradient colors', () {
      for (final promo in PromoData.defaultPromos) {
        expect(promo.gradientColorValues, isNotEmpty);
        expect(promo.gradientColorValues.length, greaterThanOrEqualTo(1));
      }
    });

    test('all promos should have non-empty titles', () {
      for (final promo in PromoData.defaultPromos) {
        expect(promo.title, isNotEmpty);
      }
    });

    test('all promos should have non-empty subtitles', () {
      for (final promo in PromoData.defaultPromos) {
        expect(promo.subtitle, isNotEmpty);
      }
    });

    test('all promos should have non-empty badges', () {
      for (final promo in PromoData.defaultPromos) {
        expect(promo.badge, isNotEmpty);
      }
    });
  });
}
