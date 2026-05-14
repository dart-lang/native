// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#include <stdbool.h>

@interface DisposableTrackerObject : NSObject {
  bool* isAlive;
}
- (instancetype)initWithIsAlive:(bool*) _isAlive;
@end

void setAssociatedDisposableTrackerObject(id host, DisposableTrackerObject* disposable);
id createDisposableTrackerObject(bool* isAlive) __attribute__((ns_returns_retained));
