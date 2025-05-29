// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "observer.h"

#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

void setAssociatedObject(id from, id key, id value) {
  if (from != nil) {
    objc_setAssociatedObject(
        from, (__bridge void*)key, value, OBJC_ASSOCIATION_RETAIN);
  }
}

void addStrongRef(id from, id to) { setAssociatedObject(from, to, to); }
void removeStrongRef(id from, id to) { setAssociatedObject(from, to, nil); }

@implementation DOBJCObserver {
  DOBJCObserverBlock _block;  // final
  NSString* _keyPath;         // final
  __weak id _observed;        // final, except becomes nil if observed dies
  BOOL _isObserving;          // mutable, guarded by @synchronized(self)
}

- (instancetype)initForKeyPath:(NSString*)keyPath
    ofObject:(id)observer
    withBlock:(DOBJCObserverBlock)block {
  _block = block;
  _keyPath = keyPath;
  _observed = observer;
  _isObserving = true;
  [observer addObserver: self
      forKeyPath: keyPath
      options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
      context: nil];
  addStrongRef(observer, self);
  return self;
}

- (void)observeValueForKeyPath:(NSString*)keyPath
    ofObject:(id)observer
    change:(NSDictionary<NSKeyValueChangeKey, id>*)change
    context:(void*)context {
  _block(
      observer, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
}

- (void)remove {
  @synchronized(self) {
    if (_isObserving) {
      _isObserving = false;
      [_observed removeObserver:self forKeyPath:_keyPath context:nil];
      removeStrongRef(_observed, self);
    }
  }
}

- (void)dealloc {
  [self remove];
}
@end
