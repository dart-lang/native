// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface DisposableObject : NSObject {
  bool* isAlive;
}
+ (instancetype)newWithIsAlive:(bool*) _isAlive;
- (instancetype)initWithIsAlive:(bool*) _isAlive;
@end

void setAssociatedDisposableObject(id host, DisposableObject* disposable);

void objc_autoreleasePoolPop(void *pool);
void *objc_autoreleasePoolPush();
