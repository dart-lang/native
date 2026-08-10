// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "reference_tracker.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

@interface ReferenceTracker : NSObject {
  bool* isAlive;
}
- (instancetype)initWithIsAlive:(bool*) _isAlive;
@end

@implementation ReferenceTracker
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
}
@end

static const char DISPOSABLE_KEY;

void attachReferenceTracker(id host, bool* isAlive) {
  ReferenceTracker* tracker =
      [[ReferenceTracker alloc] initWithIsAlive:isAlive];
  objc_setAssociatedObject(
      host, &DISPOSABLE_KEY, tracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
