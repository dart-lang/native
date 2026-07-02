// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

typedef void (^ObjectListener)(NSObject *);
typedef void (^IntListener)(int32_t);
typedef void (^RangeListener)(NSRange);

// Stores a listener block the way NSURLSession retains its delegates, so
// tests can invoke it after the isolate that created it has shut down.
@interface ListenerLifetimeTester : NSObject

@property (strong) ObjectListener storedListener;

- (void)invokeStoredWithArg:(NSObject *)arg;

// Invokes the stored listener on a new thread, and waits for the invocation
// (not the delivery) to complete.
- (void)invokeStoredOnNewThreadWithArg:(NSObject *)arg;

- (void)clearStored;

// Invokes the block with 0, 1, ..., count - 1, sequentially on a new thread.
+ (void)invoke:(IntListener)block times:(int32_t)count;

+ (void)invokeRange:(RangeListener)block
           location:(uint32_t)location
             length:(uint32_t)length;

@end
