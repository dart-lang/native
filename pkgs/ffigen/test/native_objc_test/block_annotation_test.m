// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <stdio.h>

#include "block_annotation_test.h"

@implementation EmptyObject
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
+ (void) invokeObjectListenerSync: (ObjectListener)block {
  block(nil, [[EmptyObject alloc] init]);
}
+ (void) invokeConsumedObjectListenerSync: (ConsumedObjectListener)block {
  block(nil, [[EmptyObject alloc] init]);
}
+ (NSThread*) invokeObjectListenerAsync: (ObjectListener)block {
  return [[NSThread alloc] initWithTarget:[BlockAnnotationTest class]
                                 selector:@selector(invokeObjectListenerSync:)
                                   object:block];
}
+ (NSThread*) invokeConsumedObjectListenerAsync: (ConsumedObjectListener)block {
  return [[NSThread alloc] initWithTarget:[BlockAnnotationTest class]
                                 selector:@selector(invokeConsumedObjectListenerSync:)
                                   object:block];
}
@end
