#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "block_test.h"

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

typedef struct {
  int64_t version;
  void* (*newWaiter)(void);
  void (*awaitWaiter)(void*);
  void* (*currentIsolate)(void);
  void (*enterIsolate)(void*);
  void (*exitIsolate)(void);
  int64_t (*getMainPortId)(void);
  bool (*getCurrentThreadOwnsIsolate)(int64_t);
  void (*invokeListenerPortBlock)(int64_t port, void*);
  void (*invokeBlockingPortBlock)(int64_t port, void*, void*);
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, TYPE, SIG, INVOKE_DIRECT, INVOKE_LISTENER)    \
  assert(ctx->version >= 1);                                                   \
  void* targetIsolate = ctx->currentIsolate();                                 \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();  \
  __block __weak TYPE weakSelfBlock = nil;                                     \
  TYPE strongSelfBlock = [SIG {                                                \
    void* currentIsolate = ctx->currentIsolate();                              \
    bool mayEnterIsolate =                                                     \
        currentIsolate == NULL &&                                              \
        ctx->getCurrentThreadOwnsIsolate != NULL &&                            \
        ctx->getCurrentThreadOwnsIsolate(targetPort);                          \
    if (currentIsolate == targetIsolate || mayEnterIsolate) {                  \
      if (mayEnterIsolate) {                                                   \
        ctx->enterIsolate(targetIsolate);                                      \
      }                                                                        \
      INVOKE_DIRECT;                                                           \
      if (mayEnterIsolate) {                                                   \
        ctx->exitIsolate();                                                    \
      }                                                                        \
    } else {                                                                   \
      void* waiter = ctx->newWaiter();                                         \
      TYPE selfRetain = [weakSelfBlock copy];                                  \
      INVOKE_LISTENER;                                                         \
      ctx->awaitWaiter(waiter);                                                \
      (void)selfRetain;                                                        \
    }                                                                          \
  } copy];                                                                     \
  weakSelfBlock = strongSelfBlock;                                             \
  return strongSelfBlock;


__attribute__((visibility("default")))
@interface _18tji2r_BlockArgs_h9i570 : NSObject
@property (copy) id block;

@end
@implementation _18tji2r_BlockArgs_h9i570
@end

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _18tji2r_wrapListenerBlock_h9i570(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline weakSelfBlock = nil;
  _ListenerTrampoline strongSelfBlock = [^void() {
    @autoreleasepool {
      _18tji2r_BlockArgs_h9i570* args = [[_18tji2r_BlockArgs_h9i570 alloc] init];
      args.block = weakSelfBlock;
      
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _18tji2r_wrapBlockingBlock_h9i570(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline, ^void(), {
    @autoreleasepool {
      _18tji2r_BlockArgs_h9i570* args = [[_18tji2r_BlockArgs_h9i570 alloc] init];
      args.block = weakSelfBlock;
      
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _18tji2r_BlockArgs_h9i570* args = [[_18tji2r_BlockArgs_h9i570 alloc] init];
      args.block = weakSelfBlock;
      
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _18tji2r_BlockArgs_1d1siln : NSObject
@property (copy) id block;
@property (strong) id arg0;
@end
@implementation _18tji2r_BlockArgs_1d1siln
@end

typedef void  (^_ListenerTrampoline_1)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _18tji2r_wrapListenerBlock_1d1siln(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_1 weakSelfBlock = nil;
  _ListenerTrampoline_1 strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _18tji2r_BlockArgs_1d1siln* args = [[_18tji2r_BlockArgs_1d1siln alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _18tji2r_wrapBlockingBlock_1d1siln(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_1, ^void(id arg0), {
    @autoreleasepool {
      _18tji2r_BlockArgs_1d1siln* args = [[_18tji2r_BlockArgs_1d1siln alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _18tji2r_BlockArgs_1d1siln* args = [[_18tji2r_BlockArgs_1d1siln alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _18tji2r_BlockArgs_1f6q4sj : NSObject
@property (copy) id block;
@property int32_t arg0;
@end
@implementation _18tji2r_BlockArgs_1f6q4sj
@end

typedef void  (^_ListenerTrampoline_2)(int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _18tji2r_wrapListenerBlock_1f6q4sj(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_2 weakSelfBlock = nil;
  _ListenerTrampoline_2 strongSelfBlock = [^void(int32_t arg0) {
    @autoreleasepool {
      _18tji2r_BlockArgs_1f6q4sj* args = [[_18tji2r_BlockArgs_1f6q4sj alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _18tji2r_wrapBlockingBlock_1f6q4sj(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_2, ^void(int32_t arg0), {
    @autoreleasepool {
      _18tji2r_BlockArgs_1f6q4sj* args = [[_18tji2r_BlockArgs_1f6q4sj alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _18tji2r_BlockArgs_1f6q4sj* args = [[_18tji2r_BlockArgs_1f6q4sj alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _18tji2r_BlockArgs_1vg1ydp : NSObject
@property (copy) id block;
@property int32_t * arg0;
@end
@implementation _18tji2r_BlockArgs_1vg1ydp
@end

typedef void  (^_ListenerTrampoline_3)(int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _18tji2r_wrapListenerBlock_1vg1ydp(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_3 weakSelfBlock = nil;
  _ListenerTrampoline_3 strongSelfBlock = [^void(int32_t * arg0) {
    @autoreleasepool {
      _18tji2r_BlockArgs_1vg1ydp* args = [[_18tji2r_BlockArgs_1vg1ydp alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _18tji2r_wrapBlockingBlock_1vg1ydp(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_3, ^void(int32_t * arg0), {
    @autoreleasepool {
      _18tji2r_BlockArgs_1vg1ydp* args = [[_18tji2r_BlockArgs_1vg1ydp alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _18tji2r_BlockArgs_1vg1ydp* args = [[_18tji2r_BlockArgs_1vg1ydp alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _18tji2r_BlockArgs_1y99z5g : NSObject
@property (copy) id block;
@property int32_t arg0;
@property Vec4 arg1;
@property char * arg2;
@end
@implementation _18tji2r_BlockArgs_1y99z5g
@end

typedef void  (^_ListenerTrampoline_4)(int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _18tji2r_wrapListenerBlock_1y99z5g(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_4 weakSelfBlock = nil;
  _ListenerTrampoline_4 strongSelfBlock = [^void(int32_t arg0, Vec4 arg1, char * arg2) {
    @autoreleasepool {
      _18tji2r_BlockArgs_1y99z5g* args = [[_18tji2r_BlockArgs_1y99z5g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _18tji2r_wrapBlockingBlock_1y99z5g(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_4, ^void(int32_t arg0, Vec4 arg1, char * arg2), {
    @autoreleasepool {
      _18tji2r_BlockArgs_1y99z5g* args = [[_18tji2r_BlockArgs_1y99z5g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _18tji2r_BlockArgs_1y99z5g* args = [[_18tji2r_BlockArgs_1y99z5g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _18tji2r_BlockArgs_wv523k : NSObject
@property (copy) id block;
@property (copy) id arg0;
@end
@implementation _18tji2r_BlockArgs_wv523k
@end

typedef void  (^_ListenerTrampoline_5)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _18tji2r_wrapListenerBlock_wv523k(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_5 weakSelfBlock = nil;
  _ListenerTrampoline_5 strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _18tji2r_BlockArgs_wv523k* args = [[_18tji2r_BlockArgs_wv523k alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _18tji2r_wrapBlockingBlock_wv523k(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_5, ^void(id arg0), {
    @autoreleasepool {
      _18tji2r_BlockArgs_wv523k* args = [[_18tji2r_BlockArgs_wv523k alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _18tji2r_BlockArgs_wv523k* args = [[_18tji2r_BlockArgs_wv523k alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _18tji2r_BlockArgs_mx4mc : NSObject
@property (copy) id block;
@property struct Vec2 arg0;
@property Vec4 arg1;
@property (strong) id arg2;
@end
@implementation _18tji2r_BlockArgs_mx4mc
@end

typedef void  (^_ListenerTrampoline_6)(struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _18tji2r_wrapListenerBlock_mx4mc(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_6 weakSelfBlock = nil;
  _ListenerTrampoline_6 strongSelfBlock = [^void(struct Vec2 arg0, Vec4 arg1, id arg2) {
    @autoreleasepool {
      _18tji2r_BlockArgs_mx4mc* args = [[_18tji2r_BlockArgs_mx4mc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _18tji2r_wrapBlockingBlock_mx4mc(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_6, ^void(struct Vec2 arg0, Vec4 arg1, id arg2), {
    @autoreleasepool {
      _18tji2r_BlockArgs_mx4mc* args = [[_18tji2r_BlockArgs_mx4mc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _18tji2r_BlockArgs_mx4mc* args = [[_18tji2r_BlockArgs_mx4mc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _18tji2r_BlockArgs_j5cnrc : NSObject
@property (copy) id block;
@property struct objc_selector * arg0;
@end
@implementation _18tji2r_BlockArgs_j5cnrc
@end

typedef void  (^_ListenerTrampoline_7)(struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _18tji2r_wrapListenerBlock_j5cnrc(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_7 weakSelfBlock = nil;
  _ListenerTrampoline_7 strongSelfBlock = [^void(struct objc_selector * arg0) {
    @autoreleasepool {
      _18tji2r_BlockArgs_j5cnrc* args = [[_18tji2r_BlockArgs_j5cnrc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _18tji2r_wrapBlockingBlock_j5cnrc(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_7, ^void(struct objc_selector * arg0), {
    @autoreleasepool {
      _18tji2r_BlockArgs_j5cnrc* args = [[_18tji2r_BlockArgs_j5cnrc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _18tji2r_BlockArgs_j5cnrc* args = [[_18tji2r_BlockArgs_j5cnrc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
