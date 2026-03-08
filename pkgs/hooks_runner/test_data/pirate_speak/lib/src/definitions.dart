// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

// TODO: Use data assets when they are supported.
const Map<String, String> _translations = {
  'Hello': 'Ahoy',
  'Yes': 'Aye',
  'No': 'Nay',
  'Friend': 'Matey',
  'Money': 'Doubloons',
};

// ignore: experimental_member_use
@RecordUse()
String pirateSpeak(String english) => _translations[english] ?? english;
