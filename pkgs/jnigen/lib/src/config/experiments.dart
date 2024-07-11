// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../logging/logging.dart';

class Experiment {
  static const available = [
    interfaceImplementation,
  ];

  static const interfaceImplementation = Experiment(
    name: 'interface_implementation',
    description: 'Enables generation of machinery for '
        'implementing Java interfaces in Dart.',
    isExpired: false,
  );

  final String name;
  final String description;
  final bool isExpired;

  const Experiment({
    required this.name,
    required this.description,
    required this.isExpired,
  });

  factory Experiment.fromString(String s) {
    final search = available.where((element) => element.name == s);
    if (search.isEmpty) {
      log.fatal('The experiment $s is not available in this version.');
    }
    final result = search.single;
    if (result.isExpired) {
      log.fatal('The experiment $s can no longer be used in this version.');
    }
    return result;
  }
}
