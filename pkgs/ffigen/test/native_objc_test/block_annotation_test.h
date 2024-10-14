// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSThread.h>

void objc_autoreleasePoolPop(void *pool);
void *objc_autoreleasePoolPush();

@interface EmptyObject : NSObject {}
@end

typedef void (^EmptyBlock)();

// This protocol only exists to generate blocks with retained and consumed
// annotations. See https://github.com/dart-lang/native/issues/1490. Note that
// the generated blocks have an extra void* arg at the start, which we ignore.
@protocol BlockAnnotationTestProtocol<NSObject>
- (EmptyObject*)produceObject;
- (EmptyObject*)produceRetainedObject __attribute__((ns_returns_retained));
- (EmptyBlock)produceBlock;
- (EmptyBlock)produceRetainedBlock __attribute__((ns_returns_retained));
- (EmptyObject*)receiveObject: (EmptyObject*)obj;
- (EmptyObject*)receiveConsumedObject: (EmptyObject*) __attribute__((ns_consumed)) obj;
- (void)listenObject: (EmptyObject*)obj;
- (void)listenConsumedObject: (EmptyObject*) __attribute__((ns_consumed)) obj;
@end

typedef EmptyObject* (^ObjectProducer)(void*);
typedef EmptyObject* (^RetainedObjectProducer)(void*)
    __attribute__((ns_returns_retained));
typedef EmptyBlock (^BlockProducer)(void*);
typedef EmptyBlock (^RetainedBlockProducer)(void*)
    __attribute__((ns_returns_retained));

// Note: ns_consumed can't be applied to block types, so we're only testing
// consumed objects.
typedef EmptyObject* (^ObjectReceiver)(void*, EmptyObject*);
typedef EmptyObject* (^ConsumedObjectReceiver)(
    void*, EmptyObject* __attribute__((ns_consumed)));
typedef void (^ObjectListener)(void*, EmptyObject*);
typedef void (^ConsumedObjectListener)(
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
+ (void) invokeObjectListenerSync: (ObjectListener)block;
+ (void) invokeConsumedObjectListenerSync: (ConsumedObjectListener)block;
+ (NSThread*) invokeObjectListenerAsync: (ObjectListener)block;
+ (NSThread*) invokeConsumedObjectListenerAsync: (ConsumedObjectListener)block;
@end
