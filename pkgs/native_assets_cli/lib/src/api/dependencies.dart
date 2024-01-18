// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/dependencies.dart' as model;

@Deprecated('Use the methods on BuildOutput.')
abstract class Dependencies {
  /// The dependencies a build relied on.
  List<Uri> get dependencies;

  const factory Dependencies(List<Uri> dependencies) = model.Dependencies;
}
