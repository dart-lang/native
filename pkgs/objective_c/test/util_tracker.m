// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "util_tracker.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@implementation DisposableTrackerObject
- (instancetype)initWithIsAlive:(bool*) _isAlive {
  if (self = [super init]) {
    isAlive = _isAlive;
    if (isAlive) {
      *isAlive = true;
    }
  }
  return self;
}
- (void)dealloc {
  if (isAlive) {
    *isAlive = false;
  }
#if !__has_feature(objc_arc)
  [super dealloc];
#endif
}
@end

static const char DISPOSABLE_KEY;

void setAssociatedDisposableTrackerObject(id host, DisposableTrackerObject* disposable) {
  objc_setAssociatedObject(
      host, &DISPOSABLE_KEY, disposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

id createDisposableTrackerObject(bool* isAlive) __attribute__((ns_returns_retained)) {
  return [[DisposableTrackerObject alloc] initWithIsAlive:isAlive];
}
