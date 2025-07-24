// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flag_enthusiast_1/flag_enthusiast_1.dart';
import 'package:flag_enthusiast_2/flag_enthusiast_2.dart';

String flagList() => [
  SingleFlag.loadFlag('de'),
  ...MultiFlag.loadFlags(['fr']),
].join(', ');
