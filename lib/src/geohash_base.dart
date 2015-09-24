// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// TODO: Put public facing types in this file.

library geohash.base;

import 'dart:math';

/// Checks if you are awesome. Spoiler: you are.
class Geohash {
  static const Map<String, int> base32CharToNumber = const <String, int>{
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
  static const List<String> base32NumberToChar = const <String>[
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
  static String encode(double latitude, double longitude,
      {int codeLength: 12}) {
    if (codeLength > 20) {
      throw new ArgumentError(
          'latitude and longitude are not precise enough to encode $codeLength characters');
    }
    latitude = (latitude + 90) * (pow(2.0, 52) / 180);
    longitude = (longitude + 180) * (pow(2.0, 52) / 360);
    int latitudeInt = latitude.floor();
    int longitudeInt = longitude.floor();
    int longitudeBits = (codeLength ~/ 2) * 5 + (codeLength % 2) * 3;
    int latitudeBits = codeLength * 5 - longitudeBits;
    int longitudeCode = longitudeInt >> (52 - longitudeBits);
    int latitudeCode = latitudeInt >> (52 - latitudeBits);
    var stringBuffer = new List();
    while (codeLength > 0) {
      int code = 0;
      int bigEndCode, littleEndCode;
      if (codeLength % 2 == 0) {
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
      code = ((bigEndCode & 4) << 2) |
          ((bigEndCode & 2) << 1) |
          (bigEndCode & 1) |
          ((littleEndCode & 2) << 2) |
          ((littleEndCode & 1) << 1);
      stringBuffer.add(base32NumberToChar[code]);
      codeLength--;
    }
    var buffer = new StringBuffer()
      ..writeAll(stringBuffer.reversed);
    return buffer.toString();
  }

  static Rectangle getExtents(String geohash) {}
  static Point decode(String geohash) {}
}
