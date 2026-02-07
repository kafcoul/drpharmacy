import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/extensions/extensions.dart';

void main() {
  group('IntExtensions', () {
    group('twoDigits', () {
      test('should pad single digit with zero', () {
        // Act & Assert
        expect(5.twoDigits, '05');
      });

      test('should not pad double digit', () {
        // Act & Assert
        expect(15.twoDigits, '15');
      });

      test('should not pad triple digit', () {
        // Act & Assert
        expect(125.twoDigits, '125');
      });

      test('should pad zero', () {
        // Act & Assert
        expect(0.twoDigits, '00');
      });
    });

    group('formatPrice', () {
      test('should format price without thousand separator for small amounts', () {
        // Act & Assert
        expect(100.formatPrice, contains('100'));
        expect(100.formatPrice, contains('FCFA'));
      });

      test('should format price with thousand separator', () {
        // Act
        final result = 1500.formatPrice;

        // Assert
        expect(result, contains('FCFA'));
        expect(result, contains('1'));
        expect(result, contains('500'));
      });

      test('should format large price correctly', () {
        // Act
        final result = 1500000.formatPrice;

        // Assert
        expect(result, contains('FCFA'));
      });
    });
  });

  group('DoubleExtensions', () {
    group('formatPrice', () {
      test('should format double price', () {
        // Act
        final result = 1500.5.formatPrice;

        // Assert
        expect(result, contains('FCFA'));
      });

      test('should truncate decimals', () {
        // Act
        final result = 99.99.formatPrice;

        // Assert
        expect(result, contains('100')); // Rounded
        expect(result, contains('FCFA'));
      });
    });
  });

  group('StringExtensions', () {
    group('capitalize', () {
      test('should capitalize first letter', () {
        // Act & Assert
        expect('hello'.capitalize, 'Hello');
      });

      test('should lowercase remaining letters', () {
        // Act & Assert
        expect('HELLO'.capitalize, 'Hello');
      });

      test('should handle empty string', () {
        // Act & Assert
        expect(''.capitalize, '');
      });

      test('should handle single character', () {
        // Act & Assert
        expect('a'.capitalize, 'A');
      });
    });

    group('titleCase', () {
      test('should capitalize each word', () {
        // Act & Assert
        expect('hello world'.titleCase, 'Hello World');
      });

      test('should handle uppercase string', () {
        // Act & Assert
        expect('HELLO WORLD'.titleCase, 'Hello World');
      });

      test('should handle mixed case', () {
        // Act & Assert
        expect('hElLo WoRLd'.titleCase, 'Hello World');
      });
    });

    group('truncate', () {
      test('should not truncate short string', () {
        // Act & Assert
        expect('Hello'.truncate(10), 'Hello');
      });

      test('should truncate long string with ellipsis', () {
        // Act & Assert
        expect('Hello World'.truncate(8), 'Hello...');
      });

      test('should handle exact length', () {
        // Act & Assert
        expect('Hello'.truncate(5), 'Hello');
      });
    });

    group('isValidEmail', () {
      test('should validate correct email', () {
        // Act & Assert
        expect('test@example.com'.isValidEmail, isTrue);
      });

      test('should validate email with subdomain', () {
        // Act & Assert
        expect('test@mail.example.com'.isValidEmail, isTrue);
      });

      test('should reject email without @', () {
        // Act & Assert
        expect('testexample.com'.isValidEmail, isFalse);
      });

      test('should reject email without domain', () {
        // Act & Assert
        expect('test@'.isValidEmail, isFalse);
      });

      test('should reject email without TLD', () {
        // Act & Assert
        expect('test@example'.isValidEmail, isFalse);
      });
    });

    group('isValidPhone', () {
      test('should validate 10-digit phone', () {
        // Act & Assert
        expect('0123456789'.isValidPhone, isTrue);
      });

      test('should validate phone with +225 prefix', () {
        // Act & Assert
        expect('+2250123456789'.isValidPhone, isTrue);
      });

      test('should validate phone with spaces', () {
        // Act & Assert
        expect('01 23 45 67 89'.isValidPhone, isTrue);
      });

      test('should reject short phone', () {
        // Act & Assert
        expect('12345'.isValidPhone, isFalse);
      });
    });

    group('formatPhone', () {
      test('should format 10-digit phone', () {
        // Act
        final result = '0123456789'.formatPhone;

        // Assert
        expect(result, '01 23 45 67 89');
      });

      test('should return unchanged if not 10 digits', () {
        // Act & Assert
        expect('12345'.formatPhone, '12345');
      });
    });

    group('toInternationalPhone', () {
      test('should keep already formatted number', () {
        // Act & Assert
        expect('+2250123456789'.toInternationalPhone, '+2250123456789');
      });

      test('should convert 00225 format', () {
        // Act & Assert
        expect('002250123456789'.toInternationalPhone, '+2250123456789');
      });

      test('should convert local 10-digit number', () {
        // Act & Assert
        expect('0123456789'.toInternationalPhone, '+2250123456789');
      });

      test('should remove spaces and dashes', () {
        // Act
        final result = '01 23-45 67 89'.toInternationalPhone;

        // Assert
        expect(result, '+2250123456789');
      });
    });
  });

  group('DateTimeExtensions', () {
    group('formatDate', () {
      test('should format date correctly', () {
        // Arrange
        final date = DateTime(2024, 1, 15);

        // Act & Assert
        expect(date.formatDate, '15/01/2024');
      });

      test('should pad single digit day and month', () {
        // Arrange
        final date = DateTime(2024, 5, 8);

        // Act & Assert
        expect(date.formatDate, '08/05/2024');
      });
    });

    group('formatDateTime', () {
      test('should format date and time correctly', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 14, 30);

        // Act & Assert
        expect(date.formatDateTime, '15/01/2024 14:30');
      });
    });

    group('formatTime', () {
      test('should format time correctly', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 9, 5);

        // Act & Assert
        expect(date.formatTime, '09:05');
      });
    });

    group('isToday', () {
      test('should return true for today', () {
        // Arrange
        final today = DateTime.now();

        // Act & Assert
        expect(today.isToday, isTrue);
      });

      test('should return false for yesterday', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        expect(yesterday.isToday, isFalse);
      });
    });

    group('isYesterday', () {
      test('should return true for yesterday', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act & Assert
        expect(yesterday.isYesterday, isTrue);
      });

      test('should return false for today', () {
        // Arrange
        final today = DateTime.now();

        // Act & Assert
        expect(today.isYesterday, isFalse);
      });
    });

    group('smartFormat', () {
      test('should show "Aujourd\'hui" for today', () {
        // Arrange
        final today = DateTime.now();

        // Act
        final result = today.smartFormat;

        // Assert
        expect(result, contains('Aujourd\'hui'));
      });

      test('should show "Hier" for yesterday', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        // Act
        final result = yesterday.smartFormat;

        // Assert
        expect(result, contains('Hier'));
      });

      test('should show date for older dates', () {
        // Arrange
        final oldDate = DateTime(2023, 5, 15, 10, 30);

        // Act
        final result = oldDate.smartFormat;

        // Assert
        expect(result, contains('15/05/2023'));
      });
    });

    group('timeAgo', () {
      test('should show "À l\'instant" for recent time', () {
        // Arrange
        final now = DateTime.now();

        // Act & Assert
        expect(now.timeAgo, 'À l\'instant');
      });

      test('should show minutes for recent past', () {
        // Arrange
        final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));

        // Act
        final result = fiveMinutesAgo.timeAgo;

        // Assert
        expect(result, contains('min'));
      });

      test('should show hours for hours ago', () {
        // Arrange
        final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));

        // Act
        final result = twoHoursAgo.timeAgo;

        // Assert
        expect(result, contains('h'));
      });

      test('should show days for days ago', () {
        // Arrange
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

        // Act
        final result = threeDaysAgo.timeAgo;

        // Assert
        expect(result, contains('j'));
      });

      test('should show date for old dates', () {
        // Arrange
        final oldDate = DateTime(2020, 1, 1);

        // Act
        final result = oldDate.timeAgo;

        // Assert
        expect(result, contains('/'));
      });
    });
  });

  group('ListExtensions', () {
    group('getOrNull', () {
      test('should return element at valid index', () {
        // Arrange
        final list = [1, 2, 3];

        // Act & Assert
        expect(list.getOrNull(1), 2);
      });

      test('should return null for negative index', () {
        // Arrange
        final list = [1, 2, 3];

        // Act & Assert
        expect(list.getOrNull(-1), isNull);
      });

      test('should return null for out of bounds index', () {
        // Arrange
        final list = [1, 2, 3];

        // Act & Assert
        expect(list.getOrNull(5), isNull);
      });

      test('should return first element at index 0', () {
        // Arrange
        final list = [1, 2, 3];

        // Act & Assert
        expect(list.getOrNull(0), 1);
      });
    });

    group('separatedBy', () {
      test('should separate elements', () {
        // Arrange
        final list = [1, 2, 3];

        // Act
        final result = list.separatedBy(0);

        // Assert
        expect(result, [1, 0, 2, 0, 3]);
      });

      test('should return empty for empty list', () {
        // Arrange
        final list = <int>[];

        // Act
        final result = list.separatedBy(0);

        // Assert
        expect(result, isEmpty);
      });

      test('should return single element without separator', () {
        // Arrange
        final list = [1];

        // Act
        final result = list.separatedBy(0);

        // Assert
        expect(result, [1]);
      });
    });
  });

  group('WidgetExtensions', () {
    testWidgets('withPadding should add padding', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = child.withPadding(const EdgeInsets.all(16));

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('withSymmetricPadding should add symmetric padding', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = child.withSymmetricPadding(horizontal: 16, vertical: 8);

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('withMargin should add margin', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = child.withMargin(const EdgeInsets.all(16));

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('centered should center widget', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = child.centered();

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('onTap should make widget tappable', (tester) async {
      // Arrange
      var tapped = false;
      const child = Text('Test');
      final widget = child.onTap(() => tapped = true);

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));
      await tester.tap(find.byType(GestureDetector));

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('visible should control visibility', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = child.visible(false);

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(Visibility), findsOneWidget);
    });

    testWidgets('opacity should apply opacity', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = child.opacity(0.5);

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(Opacity), findsOneWidget);
    });

    testWidgets('expanded should wrap in Expanded', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = Row(children: [child.expanded()]);

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('flexible should wrap in Flexible', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = Row(children: [child.flexible()]);

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(Flexible), findsOneWidget);
    });

    testWidgets('safeArea should wrap in SafeArea', (tester) async {
      // Arrange
      const child = Text('Test');
      final widget = child.safeArea();

      // Act
      await tester.pumpWidget(MaterialApp(home: widget));

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });

  group('BuildContextExtensions', () {
    testWidgets('theme should return ThemeData', (tester) async {
      // Arrange
      late ThemeData capturedTheme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedTheme = context.theme;
              return const Text('Test');
            },
          ),
        ),
      );

      // Assert
      expect(capturedTheme, isA<ThemeData>());
    });

    testWidgets('textTheme should return TextTheme', (tester) async {
      // Arrange
      late TextTheme capturedTextTheme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedTextTheme = context.textTheme;
              return const Text('Test');
            },
          ),
        ),
      );

      // Assert
      expect(capturedTextTheme, isA<TextTheme>());
    });

    testWidgets('colorScheme should return ColorScheme', (tester) async {
      // Arrange
      late ColorScheme capturedColorScheme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedColorScheme = context.colorScheme;
              return const Text('Test');
            },
          ),
        ),
      );

      // Assert
      expect(capturedColorScheme, isA<ColorScheme>());
    });

    testWidgets('isDarkMode should return false for light theme', (tester) async {
      // Arrange
      late bool isDark;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              isDark = context.isDarkMode;
              return const Text('Test');
            },
          ),
        ),
      );

      // Assert
      expect(isDark, isFalse);
    });

    testWidgets('isDarkMode should return true for dark theme', (tester) async {
      // Arrange
      late bool isDark;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              isDark = context.isDarkMode;
              return const Text('Test');
            },
          ),
        ),
      );

      // Assert
      expect(isDark, isTrue);
    });

    testWidgets('screenWidth should return screen width', (tester) async {
      // Arrange
      late double width;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              width = context.screenWidth;
              return const Text('Test');
            },
          ),
        ),
      );

      // Assert
      expect(width, greaterThan(0));
    });

    testWidgets('screenHeight should return screen height', (tester) async {
      // Arrange
      late double height;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              height = context.screenHeight;
              return const Text('Test');
            },
          ),
        ),
      );

      // Assert
      expect(height, greaterThan(0));
    });
  });
}
