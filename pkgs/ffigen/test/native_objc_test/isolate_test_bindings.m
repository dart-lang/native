#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "isolate_test.h"

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
  bool (*postCObject)(int64_t, void*, void (*)(void*, void*));
  void (*runOnMainThread)(void (*fn)(void *), void *arg);
  void (*signalWaiter)(void *waiter);
  int64_t (*getBlockPortId)(void* block);
  void* (*getBlockContext)(void* block);
} DOBJC_Context;

id objc_retainBlock(id);
void DOBJC_runOnMainThread(void (*fn)(void *), void *arg);
void DOBJC_signalWaiter(void *waiter);

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

@interface _rdx59v_BlockArgs_1huiwh : NSObject {
  @public
  id block;
  void* context;
  int32_t  arg0;
}
@end

@implementation _rdx59v_BlockArgs_1huiwh
@end

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _rdx59v_BlockArgs_1huiwh_getArg0(void* peer) {
  return ((__bridge _rdx59v_BlockArgs_1huiwh*)peer)->arg0;
}


void _rdx59v_BlockArgs_1huiwh_free(void* peer) {
  @autoreleasepool {
    _rdx59v_BlockArgs_1huiwh* args = (__bridge _rdx59v_BlockArgs_1huiwh*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _rdx59v_BlockArgs_1huiwh_finalize(void* isolate_callback_data, void* peer) {
  _rdx59v_BlockArgs_1huiwh* args = (__bridge _rdx59v_BlockArgs_1huiwh*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_rdx59v_BlockArgs_1huiwh_free, peer);
}

typedef void  (^_ListenerTrampoline)(int32_t arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _rdx59v_1huiwh_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(int32_t arg0) {
    _rdx59v_BlockArgs_1huiwh* args = [[_rdx59v_BlockArgs_1huiwh alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _rdx59v_BlockArgs_1huiwh_finalize);
  } copy]);
}
@interface _rdx59v_BlockArgs_1huiwh_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  int32_t  arg0;
}
@end

@implementation _rdx59v_BlockArgs_1huiwh_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _rdx59v_BlockArgs_1huiwh_blocking_getArg0(void* peer) {
  return ((__bridge _rdx59v_BlockArgs_1huiwh_blocking*)peer)->arg0;
}


__attribute__((visibility("default"))) __attribute__((used))
void _rdx59v_BlockArgs_1huiwh_blocking_free(void* peer) {
  @autoreleasepool {
    _rdx59v_BlockArgs_1huiwh_blocking* args = (__bridge _rdx59v_BlockArgs_1huiwh_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _rdx59v_BlockArgs_1huiwh_blocking_finalize(void* isolate_callback_data, void* peer) {
  _rdx59v_BlockArgs_1huiwh_blocking* args = (__bridge _rdx59v_BlockArgs_1huiwh_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_rdx59v_BlockArgs_1huiwh_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline)(void* block, int32_t arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _rdx59v_1huiwh_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(int32_t arg0) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _rdx59v_BlockArgs_1huiwh_blocking* args = [[_rdx59v_BlockArgs_1huiwh_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _rdx59v_BlockArgs_1huiwh_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
