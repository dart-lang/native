// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "observer.h"

#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

@implementation DOBJCObservation {
  id _object;              // final
  id<Observer> _observer;  // final
  NSString* _keyPath;      // final
  void* _context;          // final
  BOOL _isObserving;       // mutable, guarded by @synchronized(self)
}

- (instancetype)initForKeyPath:(NSString*)keyPath
    ofObject:(id)object
    withObserver:(id<Observer>)observer
    options:(NSKeyValueObservingOptions) options
    context:(void *)context {
  _object = object;
  _observer = observer;
  _keyPath = keyPath;
  _context = context;
  _isObserving = true;
  [object addObserver: observer
      forKeyPath: keyPath
      options: options
      context: context];
  return self;
}

- (void)remove {
  @synchronized(self) {
    if (_isObserving) {
      _isObserving = false;
      [_object removeObserver:_observer forKeyPath:_keyPath context:_context];
    }
  }
}

- (void)dealloc {
  [self remove];
}
@end
