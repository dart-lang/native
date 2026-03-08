// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

// TODO: Use data assets when they are supported.
const Map<String, Map<String, num>> _technologies = {
  'Cannon': {'range': 100, 'damage': 50},
  'Compass': {'accuracy': 0.9},
  'Telescope': {'zoom': 10},
  'PegLeg': {'comfort': 2},
};

// ignore: experimental_member_use
@RecordUse()
void useCannon() {
  final damage = _technologies['Cannon']!['damage'];
  print('Boom! (Damage: $damage)');
}

// ignore: experimental_member_use
@RecordUse()
void useCompass() {
  final accuracy = _technologies['Compass']!['accuracy'];
  print('North! (Accuracy: $accuracy)');
}

// ignore: experimental_member_use
@RecordUse()
void useTelescope() {
  final zoom = _technologies['Telescope']!['zoom'];
  print('I see you! (Zoom: x$zoom)');
}

// ignore: experimental_member_use
@RecordUse()
void usePegLeg() {
  final comfort = _technologies['PegLeg']!['comfort'];
  print('Clunk! (Comfort: $comfort)');
}
