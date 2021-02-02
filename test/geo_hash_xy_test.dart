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
      expect(
          GeoHash.encode(
              latLng: GeoHashLatLng(lat: 29.0, lng: 34.5), codeLength: 5),
          'sv0sc');
    });
    test('Random address', () {
      expect(
          _testDistance(
              GeoHashLatLng(lat: 29.0, lng: 34.5), GeoHash.decode('sv0sc')),
          closeTo(0.0, 0.1));
    });
    test('Random address', () {
      expect(
          GeoHash.encode(
              latLng: GeoHashLatLng(lat: 38.5332370, lng: -121.4347070)),
          '9qcehwvbqhp8');
    });
    test('Random address', () {
      expect(
          _testDistance(GeoHashLatLng(lat: 38.5332370, lng: -121.4347070),
              GeoHash.decode('9qcehwvbqhp8')),
          closeTo(0.0, 1e-6));
    });
    test('Wikipedia example', () {
      expect(
          _testDistance(
              GeoHashLatLng(lat: 42.605, lng: -5.603), GeoHash.decode('ezs42')),
          closeTo(0.0, 1e-4));
    });

    test('To json', () {
      expect(
          GeoHashLatLngBounds(
                  ne: GeoHashLatLng(lat: 1, lng: 2),
                  sw: GeoHashLatLng(lat: -3, lng: -4))
              .toJson(),
          {
            'ne': {'lat': 1, 'lng': 2},
            'sw': {'lat': -3, 'lng': -4}
          });
    });

    test('From json', () {
      expect(
          GeoHashLatLngBounds.fromJson({
            'ne': {'lat': 1, 'lng': 2},
            'sw': {'lat': -3, 'lng': -4}
          }).toJson(),
          {
            'ne': {'lat': 1, 'lng': 2},
            'sw': {'lat': -3, 'lng': -4}
          });
    });
  });
}

/// Computes the "distance" between two points using pythagoras and not
/// accounting for the curvature of the earth.
double _testDistance(GeoHashLatLng latLngA, GeoHashLatLng latLngB) =>
    sqrt(pow(latLngB.lat - latLngA.lat, 2) + pow(latLngB.lng - latLngA.lng, 2));
