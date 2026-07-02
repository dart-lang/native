#include <stdint.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "listener_lifetime_test.h"

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
  // Version 2 additions:
  void (*postListenerInvocation)(void*, void*, void (*)(void*));
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


typedef struct {
  int32_t arg0;
} _1i0nyva_ListenerArgs_1bqef4y;

typedef void  (^_ListenerTrampoline)(int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1i0nyva_wrapListenerBlock_1bqef4y(
    _ListenerTrampoline block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(int32_t arg0) {
    _1i0nyva_ListenerArgs_1bqef4y *args = (_1i0nyva_ListenerArgs_1bqef4y *)malloc(sizeof(_1i0nyva_ListenerArgs_1bqef4y));
    args->arg0 = arg0;
    ctx->postListenerInvocation((__bridge void*)block, args, NULL);
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter, int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1i0nyva_wrapBlockingBlock_1bqef4y(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef struct {
  void *arg0;
} _1i0nyva_ListenerArgs_xtuoz7;

static void _1i0nyva_ListenerArgs_xtuoz7_dispose(void *p) {
  _1i0nyva_ListenerArgs_xtuoz7 *args = (_1i0nyva_ListenerArgs_xtuoz7 *)p;
  (void)(__bridge_transfer id)(args->arg0);
}

typedef void  (^_ListenerTrampoline_1)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1i0nyva_wrapListenerBlock_xtuoz7(
    _ListenerTrampoline_1 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0) {
    _1i0nyva_ListenerArgs_xtuoz7 *args = (_1i0nyva_ListenerArgs_xtuoz7 *)malloc(sizeof(_1i0nyva_ListenerArgs_xtuoz7));
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    ctx->postListenerInvocation((__bridge void*)block, args, &_1i0nyva_ListenerArgs_xtuoz7_dispose);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1i0nyva_wrapBlockingBlock_xtuoz7(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0));
  });
}

typedef struct {
  struct _NSRange arg0;
} _1i0nyva_ListenerArgs_1e3pm0z;

typedef void  (^_ListenerTrampoline_2)(struct _NSRange arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1i0nyva_wrapListenerBlock_1e3pm0z(
    _ListenerTrampoline_2 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(struct _NSRange arg0) {
    _1i0nyva_ListenerArgs_1e3pm0z *args = (_1i0nyva_ListenerArgs_1e3pm0z *)malloc(sizeof(_1i0nyva_ListenerArgs_1e3pm0z));
    args->arg0 = arg0;
    ctx->postListenerInvocation((__bridge void*)block, args, NULL);
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, struct _NSRange arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1i0nyva_wrapBlockingBlock_1e3pm0z(
    _BlockingTrampoline_2 block, _BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct _NSRange arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
