import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/constants/app_dimensions.dart';

void main() {
  group('AppDimensions', () {
    group('Spacing constants', () {
      test('spaceXS should be 4.0', () {
        expect(AppDimensions.spaceXS, 4.0);
      });

      test('spaceSM should be 8.0', () {
        expect(AppDimensions.spaceSM, 8.0);
      });

      test('spaceMD should be 12.0', () {
        expect(AppDimensions.spaceMD, 12.0);
      });

      test('space should be 16.0', () {
        expect(AppDimensions.space, 16.0);
      });

      test('spaceLG should be 20.0', () {
        expect(AppDimensions.spaceLG, 20.0);
      });

      test('spaceXL should be 24.0', () {
        expect(AppDimensions.spaceXL, 24.0);
      });

      test('space2XL should be 32.0', () {
        expect(AppDimensions.space2XL, 32.0);
      });

      test('space3XL should be 48.0', () {
        expect(AppDimensions.space3XL, 48.0);
      });

      test('spacing values should be in ascending order', () {
        expect(AppDimensions.spaceXS, lessThan(AppDimensions.spaceSM));
        expect(AppDimensions.spaceSM, lessThan(AppDimensions.spaceMD));
        expect(AppDimensions.spaceMD, lessThan(AppDimensions.space));
        expect(AppDimensions.space, lessThan(AppDimensions.spaceLG));
        expect(AppDimensions.spaceLG, lessThan(AppDimensions.spaceXL));
        expect(AppDimensions.spaceXL, lessThan(AppDimensions.space2XL));
        expect(AppDimensions.space2XL, lessThan(AppDimensions.space3XL));
      });
    });

    group('Padding constants', () {
      test('pagePaddingHorizontal should be 20.0', () {
        expect(AppDimensions.pagePaddingHorizontal, 20.0);
      });

      test('pagePaddingVertical should be 16.0', () {
        expect(AppDimensions.pagePaddingVertical, 16.0);
      });

      test('pagePadding should have correct values', () {
        expect(AppDimensions.pagePadding.left, 20.0);
        expect(AppDimensions.pagePadding.right, 20.0);
        expect(AppDimensions.pagePadding.top, 16.0);
        expect(AppDimensions.pagePadding.bottom, 16.0);
      });

      test('cardPadding should be 16.0 on all sides', () {
        expect(AppDimensions.cardPadding.left, 16.0);
        expect(AppDimensions.cardPadding.right, 16.0);
        expect(AppDimensions.cardPadding.top, 16.0);
        expect(AppDimensions.cardPadding.bottom, 16.0);
      });

      test('buttonPadding should have correct values', () {
        expect(AppDimensions.buttonPadding.left, 24.0);
        expect(AppDimensions.buttonPadding.right, 24.0);
        expect(AppDimensions.buttonPadding.top, 16.0);
        expect(AppDimensions.buttonPadding.bottom, 16.0);
      });

      test('inputPadding should have correct values', () {
        expect(AppDimensions.inputPadding.left, 16.0);
        expect(AppDimensions.inputPadding.right, 16.0);
        expect(AppDimensions.inputPadding.top, 14.0);
        expect(AppDimensions.inputPadding.bottom, 14.0);
      });
    });

    group('Border Radius constants', () {
      test('radiusXS should be 4.0', () {
        expect(AppDimensions.radiusXS, 4.0);
      });

      test('radiusSM should be 8.0', () {
        expect(AppDimensions.radiusSM, 8.0);
      });

      test('radius should be 12.0', () {
        expect(AppDimensions.radius, 12.0);
      });

      test('radiusLG should be 16.0', () {
        expect(AppDimensions.radiusLG, 16.0);
      });

      test('radiusXL should be 20.0', () {
        expect(AppDimensions.radiusXL, 20.0);
      });

      test('radius2XL should be 24.0', () {
        expect(AppDimensions.radius2XL, 24.0);
      });

      test('radius values should be in ascending order', () {
        expect(AppDimensions.radiusXS, lessThan(AppDimensions.radiusSM));
        expect(AppDimensions.radiusSM, lessThan(AppDimensions.radius));
        expect(AppDimensions.radius, lessThan(AppDimensions.radiusLG));
        expect(AppDimensions.radiusLG, lessThan(AppDimensions.radiusXL));
        expect(AppDimensions.radiusXL, lessThan(AppDimensions.radius2XL));
      });

      test('cardRadius should be 12.0', () {
        expect(AppDimensions.cardRadius, const BorderRadius.all(Radius.circular(12.0)));
      });

      test('buttonRadius should be 12.0', () {
        expect(AppDimensions.buttonRadius, const BorderRadius.all(Radius.circular(12.0)));
      });

      test('inputRadius should be 12.0', () {
        expect(AppDimensions.inputRadius, const BorderRadius.all(Radius.circular(12.0)));
      });

      test('bottomSheetRadius should have top corners only', () {
        expect(AppDimensions.bottomSheetRadius.topLeft, const Radius.circular(24.0));
        expect(AppDimensions.bottomSheetRadius.topRight, const Radius.circular(24.0));
        expect(AppDimensions.bottomSheetRadius.bottomLeft, Radius.zero);
        expect(AppDimensions.bottomSheetRadius.bottomRight, Radius.zero);
      });
    });

    group('Icon Size constants', () {
      test('iconSM should be 16.0', () {
        expect(AppDimensions.iconSM, 16.0);
      });

      test('iconMD should be 20.0', () {
        expect(AppDimensions.iconMD, 20.0);
      });

      test('icon should be 24.0', () {
        expect(AppDimensions.icon, 24.0);
      });

      test('iconLG should be 32.0', () {
        expect(AppDimensions.iconLG, 32.0);
      });

      test('iconXL should be 48.0', () {
        expect(AppDimensions.iconXL, 48.0);
      });

      test('icon2XL should be 64.0', () {
        expect(AppDimensions.icon2XL, 64.0);
      });

      test('icon sizes should be in ascending order', () {
        expect(AppDimensions.iconSM, lessThan(AppDimensions.iconMD));
        expect(AppDimensions.iconMD, lessThan(AppDimensions.icon));
        expect(AppDimensions.icon, lessThan(AppDimensions.iconLG));
        expect(AppDimensions.iconLG, lessThan(AppDimensions.iconXL));
        expect(AppDimensions.iconXL, lessThan(AppDimensions.icon2XL));
      });
    });

    group('Component Height constants', () {
      test('buttonHeight should be 52.0', () {
        expect(AppDimensions.buttonHeight, 52.0);
      });

      test('inputHeight should be 56.0', () {
        expect(AppDimensions.inputHeight, 56.0);
      });

      test('appBarHeight should be 56.0', () {
        expect(AppDimensions.appBarHeight, 56.0);
      });

      test('bottomNavHeight should be 64.0', () {
        expect(AppDimensions.bottomNavHeight, 64.0);
      });

      test('listItemHeight should be 72.0', () {
        expect(AppDimensions.listItemHeight, 72.0);
      });
    });

    group('Elevation constants', () {
      test('elevationNone should be 0.0', () {
        expect(AppDimensions.elevationNone, 0.0);
      });

      test('elevationSM should be 2.0', () {
        expect(AppDimensions.elevationSM, 2.0);
      });

      test('elevation should be 4.0', () {
        expect(AppDimensions.elevation, 4.0);
      });

      test('elevationLG should be 8.0', () {
        expect(AppDimensions.elevationLG, 8.0);
      });

      test('elevationXL should be 12.0', () {
        expect(AppDimensions.elevationXL, 12.0);
      });

      test('elevation values should be in ascending order', () {
        expect(AppDimensions.elevationNone, lessThan(AppDimensions.elevationSM));
        expect(AppDimensions.elevationSM, lessThan(AppDimensions.elevation));
        expect(AppDimensions.elevation, lessThan(AppDimensions.elevationLG));
        expect(AppDimensions.elevationLG, lessThan(AppDimensions.elevationXL));
      });
    });

    group('Animation Duration constants', () {
      test('animationFast should be 150ms', () {
        expect(AppDimensions.animationFast, const Duration(milliseconds: 150));
      });

      test('animation should be 300ms', () {
        expect(AppDimensions.animation, const Duration(milliseconds: 300));
      });

      test('animationSlow should be 500ms', () {
        expect(AppDimensions.animationSlow, const Duration(milliseconds: 500));
      });

      test('animationVerySlow should be 1000ms', () {
        expect(AppDimensions.animationVerySlow, const Duration(milliseconds: 1000));
      });

      test('animation durations should be in ascending order', () {
        expect(AppDimensions.animationFast, lessThan(AppDimensions.animation));
        expect(AppDimensions.animation, lessThan(AppDimensions.animationSlow));
        expect(AppDimensions.animationSlow, lessThan(AppDimensions.animationVerySlow));
      });
    });

    group('Consistency checks', () {
      test('cardRadius and inputRadius should be equal', () {
        expect(AppDimensions.cardRadius, equals(AppDimensions.inputRadius));
      });

      test('buttonRadius should equal cardRadius', () {
        expect(AppDimensions.buttonRadius, equals(AppDimensions.cardRadius));
      });

      test('standard spacing should be consistent', () {
        expect(AppDimensions.space, equals(AppDimensions.cardPadding.left));
      });
    });
  });
}
