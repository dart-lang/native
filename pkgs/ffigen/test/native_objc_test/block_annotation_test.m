// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

#include <stdio.h>
#include "util.h"

void objc_autoreleasePoolPop(void *pool);
void *objc_autoreleasePoolPush();

@interface EmptyObject : NSObject {}
@end
@implementation EmptyObject
@end

typedef void (^EmptyBlock)();

@protocol BlockAnnotationTestProtocol<NSObject>
- (EmptyObject*)produceObject;
- (EmptyObject*)produceRetainedObject __attribute__((ns_returns_retained));
- (EmptyBlock)produceBlock;
- (EmptyBlock)produceRetainedBlock __attribute__((ns_returns_retained));
- (void)receiveObject: (EmptyObject*)obj;
- (void)receiveConsumedObject: (EmptyObject*) __attribute__((ns_consumed)) obj;
@end

typedef EmptyObject* (^ObjectProducer)(void*);
typedef EmptyObject* (^RetainedObjectProducer)(void*)
    __attribute__((ns_returns_retained));
typedef EmptyBlock (^BlockProducer)(void*);
typedef EmptyBlock (^RetainedBlockProducer)(void*)
    __attribute__((ns_returns_retained));
typedef EmptyObject* (^ObjectReceiver)(void*, EmptyObject*);
typedef EmptyObject* (^ConsumedObjectReceiver)(
    void*, EmptyObject* __attribute__((ns_consumed)));

@interface BlockAnnotationTest : NSObject {}
+ (ObjectProducer) newObjectProducer;
+ (RetainedObjectProducer) newRetainedObjectProducer;
+ (BlockProducer) newBlockProducer;
+ (RetainedBlockProducer) newRetainedBlockProducer;
+ (ObjectReceiver) newObjectReceiver;
+ (ConsumedObjectReceiver) newConsumedObjectReceiver;
+ (EmptyObject*) invokeObjectProducer: (ObjectProducer)block;
+ (EmptyObject*) invokeRetainedObjectProducer: (RetainedObjectProducer)block;
+ (EmptyBlock) invokeBlockProducer: (BlockProducer)block;
+ (EmptyBlock) invokeRetainedBlockProducer: (RetainedBlockProducer)block;
+ (EmptyObject*) invokeObjectReceiver: (ObjectReceiver)block;
+ (EmptyObject*) invokeConsumedObjectReceiver: (ConsumedObjectReceiver)block;
@end
@implementation BlockAnnotationTest
+ (ObjectProducer) newObjectProducer {
  return ^EmptyObject*(void* _) {
    return [[EmptyObject alloc] init];
  };
}
+ (RetainedObjectProducer) newRetainedObjectProducer {
  return ^EmptyObject*(void* _) __attribute__((ns_returns_retained)) {
    return [[EmptyObject alloc] init];
  };
}
+ (BlockProducer) newBlockProducer {
  return ^EmptyBlock(void* _) {
    // Capture a local variable to force block to be heap allocated.
    int32_t x = 123;
    return ^void() { printf("%d", x); };
  };
}
+ (RetainedBlockProducer) newRetainedBlockProducer {
  return ^EmptyBlock(void* _) __attribute__((ns_returns_retained)) {
    // Capture a local variable to force block to be heap allocated.
    int32_t x = 123;
    return ^void() { printf("%d", x); };
  };
}
+ (ObjectReceiver) newObjectReceiver {
  return ^EmptyObject*(void* _, EmptyObject* obj) { return obj; };
}
+ (ConsumedObjectReceiver) newConsumedObjectReceiver {
  return ^EmptyObject*(void* _, EmptyObject* __attribute__((ns_consumed)) obj) { return obj; };
}
+ (EmptyObject*) invokeObjectProducer: (ObjectProducer)block {
  return block(nil);
}
+ (EmptyObject*) invokeRetainedObjectProducer: (RetainedObjectProducer)block {
  return block(nil);
}
+ (EmptyBlock) invokeBlockProducer: (BlockProducer)block {
  return block(nil);
}
+ (EmptyBlock) invokeRetainedBlockProducer: (RetainedBlockProducer)block {
  return block(nil);
}
+ (EmptyObject*) invokeObjectReceiver: (ObjectReceiver)block {
  return  block(nil, [[EmptyObject alloc] init]);
}
+ (EmptyObject*) invokeConsumedObjectReceiver: (ConsumedObjectReceiver)block {
  return block(nil, [[EmptyObject alloc] init]);
}
@end
