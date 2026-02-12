// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use, unreachable_from_main

import 'package:meta/meta.dart' show RecordUse;

// snippet-start#usage
void main() {
  PirateTranslator.speak('Hello');
  print(const PirateShip('Black Pearl', 50));
}

// snippet-start#static-call
abstract class PirateTranslator {
  @RecordUse()
  static String speak(String english) => 'Ahoy $english';
}
// snippet-end#static-call

// snippet-start#const-instance
@RecordUse()
class PirateShip {
  final String name;
  final int cannons;

  const PirateShip(this.name, this.cannons);
}

// snippet-end#const-instance
// snippet-end#usage
