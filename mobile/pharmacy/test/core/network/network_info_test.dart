import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_flutter/core/network/network_info.dart';

void main() {
  group('NetworkInfo', () {
    group('NetworkInfoImpl', () {
      late NetworkInfoImpl networkInfo;

      setUp(() {
        networkInfo = NetworkInfoImpl();
      });

      test('should return true when checking connectivity', () async {
        // act
        final result = await networkInfo.isConnected;

        // assert
        expect(result, isTrue);
      });

      test('should always return connected for local development', () async {
        // act
        final result1 = await networkInfo.isConnected;
        final result2 = await networkInfo.isConnected;

        // assert
        expect(result1, isTrue);
        expect(result2, isTrue);
      });
    });

    group('NetworkInfo abstract class', () {
      test('NetworkInfoImpl should implement NetworkInfo', () {
        // arrange
        final networkInfo = NetworkInfoImpl();

        // assert
        expect(networkInfo, isA<NetworkInfo>());
      });
    });
  });
}
