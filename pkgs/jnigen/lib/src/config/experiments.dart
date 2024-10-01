// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../logging/logging.dart';

class Experiment {
  static const _available = [
    // ignore: deprecated_member_use_from_same_package
    interfaceImplementation,
  ];

  @Deprecated('The experiment is enabled by default')
  static const interfaceImplementation = Experiment(
    name: 'interface_implementation',
    description: 'Enables generation of machinery for '
        'implementing Java interfaces in Dart.',
    expired: 'The experiment is enabled by default',
  );

  final String name;
  final String description;
  final String? expired;

  const Experiment({
    required this.name,
    required this.description,
    required this.expired,
  });

  factory Experiment.fromString(String s) {
    final search = _available.where((element) => element.name == s);
    if (search.isEmpty) {
      log.fatal('The experiment $s is not available in this version.');
    }
    final result = search.single;
    if (result.expired != null) {
      log.fatal('The experiment $s can no longer be used in this version: '
          '${result.expired}.');
    }
    return result;
  }
}
