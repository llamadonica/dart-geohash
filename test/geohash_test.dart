// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library geohash.test;

import 'dart:math';

import 'package:geohash/geohash.dart';
import 'package:test/test.dart';

void main() {
  group('Geohashing:', () {
    setUp(() {});

    test('Random address', () {
      expect(Geohash.encode(29.0, 34.5, codeLength: 5), 'sv0sc');
    });
    test('Random address', () {
      expect(
          const Point<double>(29.0, 34.5).distanceTo(Geohash.decode('sv0sc')),
          closeTo(0.0, 0.1));
    });
    test('Random address', () {
      expect(Geohash.encode(38.5332370, -121.4347070), '9qcehwvbqhp8');
    });
    test('Random address', () {
      expect(
          const Point<double>(38.5332370, -121.4347070)
              .distanceTo(Geohash.decode('9qcehwvbqhp8')),
          closeTo(0.0, 1e-6));
    });
  });
}
