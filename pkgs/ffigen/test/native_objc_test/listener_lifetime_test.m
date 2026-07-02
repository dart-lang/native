// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "listener_lifetime_test.h"

@implementation ListenerLifetimeTester

- (void)invokeStoredWithArg:(NSObject *)arg {
  self.storedListener(arg);
}

- (void)invokeStoredOnNewThreadWithArg:(NSObject *)arg {
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  ObjectListener block = self.storedListener;
  [NSThread detachNewThreadWithBlock:^{
    block(arg);
    dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)clearStored {
  self.storedListener = nil;
}

+ (void)invoke:(IntListener)block times:(int32_t)count {
  [NSThread detachNewThreadWithBlock:^{
    for (int32_t i = 0; i < count; ++i) {
      block(i);
    }
  }];
}

+ (void)invokeRange:(RangeListener)block
           location:(uint32_t)location
             length:(uint32_t)length {
  block(NSMakeRange(location, length));
}

@end
