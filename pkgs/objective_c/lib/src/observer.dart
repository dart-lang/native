// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'objective_c_bindings_generated.dart';

extension Observed on NSObject {
  Observation addObserver(Observer observer,
          {required NSString forKeyPath,
          NSKeyValueObservingOptions options =
              NSKeyValueObservingOptions.NSKeyValueObservingOptionNew,
          Pointer<Void>? context}) =>
      Observation._(DOBJCObservation().initForKeyPath(forKeyPath,
          ofObject: this,
          withObserver: observer,
          options: options,
          context: context ?? nullptr));
}

class Observation {
  final DOBJCObservation _observation;
  Observation._(this._observation);
  void remove() => _observation.remove();
}
