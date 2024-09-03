// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

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
@end

typedef EmptyObject* (^ObjectProducer)(void*);
typedef EmptyObject* (^RetainedObjectProducer)(void*)
    __attribute__((ns_returns_retained));
typedef EmptyBlock (^BlockProducer)(void*);
typedef EmptyBlock (^RetainedBlockProducer)(void*)
    __attribute__((ns_returns_retained));

@interface BlockAnnotationTest : NSObject {}
+ (ObjectProducer) newObjectProducer;
+ (RetainedObjectProducer) newRetainedObjectProducer;
+ (BlockProducer) newBlockProducer;
+ (RetainedBlockProducer) newRetainedBlockProducer;
+ (EmptyObject*) invokeObjectProducer: (ObjectProducer)block;
+ (EmptyObject*) invokeRetainedObjectProducer: (RetainedObjectProducer)block;
+ (EmptyBlock) invokeBlockProducer: (BlockProducer)block;
+ (EmptyBlock) invokeRetainedBlockProducer: (RetainedBlockProducer)block;
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
    return ^void() {};
  };
}
+ (RetainedBlockProducer) newRetainedBlockProducer {
  return ^EmptyBlock(void* _) __attribute__((ns_returns_retained)) {
    return ^void() {};
  };
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
@end
