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
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, BLOCK_SIG, INVOKE_DIRECT, INVOKE_LISTENER)    \
  assert(ctx->version >= 1);                                                   \
  void* targetIsolate = ctx->currentIsolate();                                 \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();  \
  return BLOCK_SIG {                                                           \
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
      INVOKE_LISTENER;                                                         \
      ctx->awaitWaiter(waiter);                                                \
    }                                                                          \
  };


typedef void  (^ListenerTrampoline)();
typedef void  (^BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline _BlockTestObjCLibrary_wrapBlockingBlock_1pl9qdv(
    BlockingTrampoline block, BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(), {
    objc_retainBlock(block);
    block(nil);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter);
  });
}

typedef id  (^ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _BlockTestObjCLibrary_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^ListenerTrampoline_1)(struct objc_selector * arg0);
typedef void  (^BlockingTrampoline_1)(void * waiter, struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_1 _BlockTestObjCLibrary_wrapBlockingBlock_1d9e4oe(
    BlockingTrampoline_1 block, BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct objc_selector * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^ListenerTrampoline_2)(id arg0);
typedef void  (^BlockingTrampoline_2)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_2 _BlockTestObjCLibrary_wrapBlockingBlock_f167m6(
    BlockingTrampoline_2 block, BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0));
  });
}

typedef void  (^ListenerTrampoline_3)(id arg0);
typedef void  (^BlockingTrampoline_3)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_3 _BlockTestObjCLibrary_wrapBlockingBlock_xtuoz7(
    BlockingTrampoline_3 block, BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0));
  });
}

typedef void  (^ListenerTrampoline_4)(struct Vec2 arg0, Vec4 arg1, id arg2);
typedef void  (^BlockingTrampoline_4)(void * waiter, struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_4 _BlockTestObjCLibrary_wrapBlockingBlock_ru30ue(
    BlockingTrampoline_4 block, BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct Vec2 arg0, Vec4 arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^ListenerTrampoline_5)(int32_t arg0, Vec4 arg1, char * arg2);
typedef void  (^BlockingTrampoline_5)(void * waiter, int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_5 _BlockTestObjCLibrary_wrapBlockingBlock_li50va(
    BlockingTrampoline_5 block, BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0, Vec4 arg1, char * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ListenerTrampoline_6)(int32_t * arg0);
typedef void  (^BlockingTrampoline_6)(void * waiter, int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_6 _BlockTestObjCLibrary_wrapBlockingBlock_yhkuco(
    BlockingTrampoline_6 block, BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^ListenerTrampoline_7)(int32_t arg0);
typedef void  (^BlockingTrampoline_7)(void * waiter, int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_7 _BlockTestObjCLibrary_wrapBlockingBlock_1bqef4y(
    BlockingTrampoline_7 block, BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
