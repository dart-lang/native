// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

import 'field.dart';

class Instance extends Equatable {
  final List<Field> fields;

  Instance({required this.fields});

  @override
  List<Object?> get props => [fields];
}
