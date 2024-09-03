// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

class Instance extends Equatable {
  final String className;
  final Map<String, Object?> fields;

  Instance({required this.className, required this.fields});

  @override
  List<Object?> get props => [fields];
}
