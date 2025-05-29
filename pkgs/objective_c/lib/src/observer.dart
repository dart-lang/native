// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

typedef Observer = void Function(
    NSObject observed, ObjCObjectBase oldValue, ObjCObjectBase newValue);

extension Observed on NSObject {
  Observation addObserver(String key, DOBJCObserverBlock block) =>
      Observation._(DOBJCObserver()
          .initForKeyPath(key.toNSString(), ofObject: this, withBlock: block));

  Observation addObserverListener(String key, Observer observer,
          {bool keepIsolateAlive = false}) =>
      addObserver(
          key,
          DOBJCObserverBlock.listener(observer,
              keepIsolateAlive: keepIsolateAlive));
}

class Observation {
  DOBJCObserver _observer;
  Observation._(this._observer);
  void remove() => _observer.remove();
}
