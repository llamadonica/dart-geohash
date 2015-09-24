# geohash

[![Build Status](https://travis-ci.org/llamadonica/dart-geohash.svg)](https://travis-ci.org/llamadonica/dart-geohash)
[![Coverage Status](https://coveralls.io/repos/llamadonica/dart-geohash/badge.svg?branch=master&service=github)](https://coveralls.io/github/llamadonica/dart-geohash?branch=master)

A library for geohashing. This is used by elasticsearch and others for geo-queries.

## Usage

A simple usage example:

    import 'package:geohash/geohash.dart';

    main() {
      var encoded = Geohash.encode(40,-120);
      var latLng = Geohash.decode(encoded);
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/llamadonica/dart-geohash/issues
