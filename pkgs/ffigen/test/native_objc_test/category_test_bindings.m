#include <stdint.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "category_test.h"
#import "category_test.h"

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
  void *arg0;
  void *arg1;
} _l3cf7j_ListenerArgs_pfv6jd;

static void _l3cf7j_ListenerArgs_pfv6jd_dispose(void *p) {
  _l3cf7j_ListenerArgs_pfv6jd *args = (_l3cf7j_ListenerArgs_pfv6jd *)p;
  (void)(__bridge_transfer id)(args->arg0);
  (void)(__bridge_transfer id)(args->arg1);
}

typedef void  (^_ListenerTrampoline)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _l3cf7j_wrapListenerBlock_pfv6jd(
    _ListenerTrampoline block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0, id arg1) {
    _l3cf7j_ListenerArgs_pfv6jd *args = (_l3cf7j_ListenerArgs_pfv6jd *)malloc(sizeof(_l3cf7j_ListenerArgs_pfv6jd));
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    args->arg1 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg1));
    ctx->postListenerInvocation((__bridge void*)block, args, &_l3cf7j_ListenerArgs_pfv6jd_dispose);
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _l3cf7j_wrapBlockingBlock_pfv6jd(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  });
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
