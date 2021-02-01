# geo_hash

A library for geohashing. This is used by elasticsearch and others for geo-queries.

This is a direct fork of geohash (https://pub.dev/packages/geohash) with some bug fixes as the project appears abandoned.

## Usage

A simple usage example:

    import 'package:geohash/geohash.dart';

    main() {
      var encoded = Geohash.encode(40,-120);
      var latLng = Geohash.decode(encoded);
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/BMEC/dart-geo_hash/issues
