// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "util.h"

@implementation DisposableObject
+ (instancetype)newWithIsAlive:(bool*) _isAlive {
  return [[DisposableObject alloc] initWithIsAlive:_isAlive];
}
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
  NSLog(@"[DisposableObject] dealloc isAlive=%p", isAlive);
  if (isAlive) {
    *isAlive = false;
  }
#if !__has_feature(objc_arc)
  [super dealloc];
#endif
}
@end

#import <objc/runtime.h>

static const char DISPOSABLE_KEY;

void setAssociatedDisposableObject(id host, DisposableObject* disposable) {
  objc_setAssociatedObject(
      host, &DISPOSABLE_KEY, disposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
