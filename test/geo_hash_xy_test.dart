// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library geo_hash_xy.test;

import 'dart:math';

import 'package:geo_hash_xy/geo_hash_xy.dart';
import 'package:test/test.dart';

void main() {
  group('Geohashing:', () {
    setUp(() {});

    test('Random address', () {
      expect(Geohash.encode(29.0, 34.5, codeLength: 5), 'sv0sc');
    });
    test('Random address', () {
      expect(
          const Point<double>(34.5, 29.0).distanceTo(Geohash.decode('sv0sc')),
          closeTo(0.0, 0.1));
    });
    test('Random address', () {
      expect(Geohash.encode(38.5332370, -121.4347070), '9qcehwvbqhp8');
    });
    test('Random address', () {
      expect(
          const Point<double>(-121.4347070, 38.5332370)
              .distanceTo(Geohash.decode('9qcehwvbqhp8')),
          closeTo(0.0, 1e-6));
    });
    test('Wikipedia example', () {
      final decodedCoordinates = Geohash.decode('ezs42');
      final expectedResult = const Point<double>(-5.603, 42.605);
      expect(decodedCoordinates.distanceTo(expectedResult), closeTo(0.0, 1e-4));
    });
  });
}
