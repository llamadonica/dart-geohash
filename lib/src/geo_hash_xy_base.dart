// Copyright (c) 2015-2018, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library geo_hash_xy.base;

import 'dart:math';

import 'package:meta/meta.dart';

/// A collection of static functions to work with geoHashes, as explained
/// [here](https://en.wikipedia.org/wiki/Geohash)
class GeoHash {
  static const Map<String, int> _base32CharToNumber = const <String, int>{
    '0': 0,
    '1': 1,
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    'b': 10,
    'c': 11,
    'd': 12,
    'e': 13,
    'f': 14,
    'g': 15,
    'h': 16,
    'j': 17,
    'k': 18,
    'm': 19,
    'n': 20,
    'p': 21,
    'q': 22,
    'r': 23,
    's': 24,
    't': 25,
    'u': 26,
    'v': 27,
    'w': 28,
    'x': 29,
    'y': 30,
    'z': 31
  };
  static const List<String> _base32NumberToChar = const <String>[
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'j',
    'k',
    'm',
    'n',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z'
  ];

  /// Encode a [latLng] into a  geoHash string.
  static String encode(
      {@required final GeoHashLatLng latLng, final int codeLength: 12}) {
    if (codeLength > 20 || (identical(1.0, 1) && codeLength > 12)) {
      //Javascript can only handle 32 bit ints reliably.
      throw ArgumentError(
          'latitude and longitude are not precise enough to encode $codeLength characters');
    }

    final latitude = latLng.lat;

    final longitude = latLng.lng;

    final latitudeBase2 = (latitude + 90) * (pow(2.0, 52) / 180);
    final longitudeBase2 = (longitude + 180) * (pow(2.0, 52) / 360);
    final longitudeBits = (codeLength ~/ 2) * 5 + (codeLength % 2) * 3;
    final latitudeBits = codeLength * 5 - longitudeBits;
    var longitudeCode = (identical(1.0, 1)) //Test for javascript.
        ? (longitudeBase2 / (pow(2.0, 52 - longitudeBits))).floor()
        : longitudeBase2.floor() >> (52 - longitudeBits);
    var latitudeCode = (identical(1.0, 1)) //Test for javascript.
        ? (latitudeBase2 / (pow(2.0, 52 - latitudeBits))).floor()
        : latitudeBase2.floor() >> (52 - latitudeBits);

    final stringBuffer = [];
    for (var localCodeLength = codeLength;
        localCodeLength > 0;
        localCodeLength--) {
      int bigEndCode, littleEndCode;
      if (localCodeLength % 2 == 0) {
        //Even slot. Latitude is more significant.
        bigEndCode = latitudeCode;
        littleEndCode = longitudeCode;
        latitudeCode >>= 3;
        longitudeCode >>= 2;
      } else {
        bigEndCode = longitudeCode;
        littleEndCode = latitudeCode;
        latitudeCode >>= 2;
        longitudeCode >>= 3;
      }
      final code = ((bigEndCode & 4) << 2) |
          ((bigEndCode & 2) << 1) |
          (bigEndCode & 1) |
          ((littleEndCode & 2) << 2) |
          ((littleEndCode & 1) << 1);
      stringBuffer.add(_base32NumberToChar[code]);
    }
    final buffer = new StringBuffer()..writeAll(stringBuffer.reversed);
    return buffer.toString();
  }

  /// Get the [GeoHashLatLngBounds] for the [geoHash].
  static GeoHashLatLngBounds getExtents(String geoHash) {
    final codeLength = geoHash.length;
    if (codeLength > 20 || (identical(1.0, 1) && codeLength > 12)) {
      //Javascript can only handle 32 bit ints reliably.
      throw ArgumentError(
          'latitude and longitude are not precise enough to encode $codeLength characters');
    }
    var latitudeInt = 0;
    var longitudeInt = 0;
    var longitudeFirst = true;
    for (var character
        in geoHash.codeUnits.map((r) => new String.fromCharCode(r))) {
      int thisSequence;
      try {
        thisSequence = _base32CharToNumber[character];
      } on Exception catch (_) {
        throw ArgumentError('$geoHash was not a geoHash string');
      }
      final bigBits = ((thisSequence & 16) >> 2) |
          ((thisSequence & 4) >> 1) |
          (thisSequence & 1);
      final smallBits = ((thisSequence & 8) >> 2) | ((thisSequence & 2) >> 1);
      if (longitudeFirst) {
        longitudeInt = (longitudeInt << 3) | bigBits;
        latitudeInt = (latitudeInt << 2) | smallBits;
      } else {
        longitudeInt = (longitudeInt << 2) | smallBits;
        latitudeInt = (latitudeInt << 3) | bigBits;
      }
      longitudeFirst = !longitudeFirst;
    }
    final longitudeBits = (codeLength ~/ 2) * 5 + (codeLength % 2) * 3;
    final latitudeBits = codeLength * 5 - longitudeBits;
    if (identical(1.0, 1)) {
      // Some of our intermediate numbers are STILL too big for javascript,
      // so  we use floating point math...
      final longitudeDiff = pow(2.0, 52 - longitudeBits);
      final latitudeDiff = pow(2.0, 52 - latitudeBits);
      final latitudeFloat = latitudeInt.toDouble() * latitudeDiff;
      final longitudeFloat = longitudeInt.toDouble() * longitudeDiff;
      final southWestLatitude = latitudeFloat * (180 / pow(2.0, 52)) - 90;
      final southWestLongitude = longitudeFloat * (360 / pow(2.0, 52)) - 180;
      final height = latitudeDiff * (180 / pow(2.0, 52));
      final width = longitudeDiff * (360 / pow(2.0, 52));

      final southWest =
          GeoHashLatLng(lat: southWestLatitude, lng: southWestLongitude);
      final northEast = GeoHashLatLng(
          lat: southWestLatitude + height.toDouble(),
          lng: southWestLongitude + width.toDouble());

      return GeoHashLatLngBounds(sw: southWest, ne: northEast);
    }

    longitudeInt = longitudeInt << (52 - longitudeBits);
    latitudeInt = latitudeInt << (52 - latitudeBits);
    final longitudeDiff = 1 << (52 - longitudeBits);
    final latitudeDiff = 1 << (52 - latitudeBits);
    final southWestLatitude =
        latitudeInt.toDouble() * (180 / pow(2.0, 52)) - 90;
    final southWestLongitude =
        longitudeInt.toDouble() * (360 / pow(2.0, 52)) - 180;
    final height = latitudeDiff.toDouble() * (180 / pow(2.0, 52));
    final width = longitudeDiff.toDouble() * (360 / pow(2.0, 52));

    final southWest =
        GeoHashLatLng(lat: southWestLatitude, lng: southWestLongitude);
    final northEast = GeoHashLatLng(
        lat: southWestLatitude + height, lng: southWestLongitude + width);

    return GeoHashLatLngBounds(sw: southWest, ne: northEast);
  }

  /// Get the [GeoHashLatLng] center of a specific [geoHash] rectangle.
  static GeoHashLatLng decode(String geoHash) => getExtents(geoHash).center;
}

/// Holds a coordinate point.
class GeoHashLatLng {
  /// Create a new instance of [GeoHashLatLng].
  GeoHashLatLng({@required this.lat, @required this.lng});

  /// Creates an instance from json.
  factory GeoHashLatLng.fromJson(Map<String, dynamic> json) => GeoHashLatLng(
      // ignore: avoid_as
      lat: (json['lat'] as num)?.toDouble(),
      // ignore: avoid_as
      lng: (json['lng'] as num)?.toDouble());

  /// Latitude of the point.
  final double lat;

  /// Longitude of the point.
  final double lng;

  /// Returns the json form of the object.
  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

/// Holds a coordinate bounds.
class GeoHashLatLngBounds {
  /// Create a new instance of [GeoHashLatLngBounds].
  GeoHashLatLngBounds({@required this.sw, @required this.ne});

  /// Creates an instance from json.
  factory GeoHashLatLngBounds.fromJson(Map<String, dynamic> json) =>
      GeoHashLatLngBounds(
          // ignore: avoid_as
          sw: GeoHashLatLng.fromJson(json['sw'] as Map<String, dynamic>),
          // ignore: avoid_as
          ne: GeoHashLatLng.fromJson(json['ne'] as Map<String, dynamic>));

  /// SouthWest corner of the bounds.
  final GeoHashLatLng sw;

  /// NorthEast corner of the bounds.
  final GeoHashLatLng ne;

  /// Width of the bounds.
  double get width => ne.lng - sw.lng;

  /// Height of the bounds
  double get height => ne.lat - sw.lat;

  /// Center of the bounds
  GeoHashLatLng get center =>
      GeoHashLatLng(lat: sw.lat + height / 2, lng: sw.lng + width / 2);

  /// Returns the json form of the object.
  Map<String, dynamic> toJson() => {'sw': sw.toJson(), 'ne': ne.toJson()};
}
