// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

/// The result of executing the doctor hooks from packages in the dependency
/// graph.
@experimental
final class DoctorResult {
  /// The validation results produced by the doctor hooks, grouped by package
  /// name.
  final Map<String, List<DoctorValidationResult>> packageValidations;

  /// All validation results produced by the doctor hooks.
  List<DoctorValidationResult> get validations => [
    for (final list in packageValidations.values) ...list,
  ];

  /// Creates a [DoctorResult].
  DoctorResult({
    Map<String, List<DoctorValidationResult>>? packageValidations,
  }) : packageValidations = packageValidations ?? const {};
}
