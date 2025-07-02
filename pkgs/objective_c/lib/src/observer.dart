// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'objective_c_bindings_generated.dart';

extension Observed on NSObject {
  /// Registers the [Observer] to receive KVO notifications for the key path
  /// relative to `this` [NSObject].
  ///
  /// Returns an [Observation], which must be held onto for as long as KVO
  /// notifications are required. The [Observation] keeps the [Observer] and the
  /// observed [NSObject] alive.
  ///
  /// This method wraps ObjC's `addObserver:forKeyPath:options:context:` method.
  /// However there is no matching `removeObserver` method, as
  /// [Observation.remove] serves that purpose.
  Observation addObserver(
    Observer observer, {
    required NSString forKeyPath,
    NSKeyValueObservingOptions options =
        NSKeyValueObservingOptions.NSKeyValueObservingOptionNew,
    Pointer<Void>? context,
  }) => Observation._(
    DOBJCObservation().initForKeyPath(
      forKeyPath,
      ofObject: this,
      withObserver: observer,
      options: options,
      context: context ?? nullptr,
    ),
  );
}

/// Represents a single KVO observation.
///
/// Created by [Observed.addObserver]. Automatically calls [remove] on itself
/// when it is destroyed.
class Observation {
  final DOBJCObservation _observation;
  Observation._(this._observation);

  /// Stops the [Observer] object from receiving change notifications.
  void remove() => _observation.remove();

  Pointer<Void> get debugObserver => _observation.debugObserver();
}
