#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>

extern uint64_t getBlockRetainCount(void*);
#import "isolate_test.h"

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

typedef struct {
  void* isa;
  int flags;
  int reserved;
  void* invoke;
  void* descriptor;
  void* target;
  int64_t dispose_port;
} ObjCBlockImpl;

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
  void (*finalizeObject)(void*, void*);
} DOBJC_Context;

typedef struct {
  int64_t port_id;
  DOBJC_Context* ctx;
} PortBlockTarget;

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


typedef void  (^_ListenerTrampoline)(int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _rdx59v_wrapListenerBlock_1bqef4y(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void(int32_t arg0) {
    _ListenerTrampoline strongBlock = block;
    strongBlock(arg0);
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter, int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _rdx59v_wrapBlockingBlock_1bqef4y(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0), {
    _BlockingTrampoline strongBlock = block;
    strongBlock(nil, arg0);
  }, {
    _BlockingTrampoline strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0);
  });
}
@interface _rdx59v_BlockArgs_1huiwh : NSObject {
  @public
  id block;
  int32_t arg0;
}
@end

@implementation _rdx59v_BlockArgs_1huiwh
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _rdx59v_BlockArgs_1huiwh_getBlock(void* peer) {
  return (__bridge void*)((__bridge _rdx59v_BlockArgs_1huiwh*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _rdx59v_BlockArgs_1huiwh_getArg0(void* peer) {
  return ((__bridge _rdx59v_BlockArgs_1huiwh*)peer)->arg0;
}


void _rdx59v_BlockArgs_1huiwh_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _rdx59v_BlockArgs_1huiwh_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_rdx59v_BlockArgs_1huiwh_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _rdx59v_1huiwh_portBlockInvoke(ObjCBlockImpl* block, int32_t arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _rdx59v_BlockArgs_1huiwh* args = [[_rdx59v_BlockArgs_1huiwh alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _rdx59v_BlockArgs_1huiwh_finalize);
}
@interface _rdx59v_BlockArgs_1huiwh_blocking : NSObject {
  @public
  void* waiter;
  id block;
  int32_t arg0;
}
@end

@implementation _rdx59v_BlockArgs_1huiwh_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _rdx59v_BlockArgs_1huiwh_blocking_signalWaiter(void* peer) {
  _rdx59v_BlockArgs_1huiwh_blocking* args = (__bridge _rdx59v_BlockArgs_1huiwh_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _rdx59v_BlockArgs_1huiwh_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _rdx59v_BlockArgs_1huiwh_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _rdx59v_BlockArgs_1huiwh_blocking_getArg0(void* peer) {
  return ((__bridge _rdx59v_BlockArgs_1huiwh_blocking*)peer)->arg0;
}


void _rdx59v_BlockArgs_1huiwh_blocking_free(void* peer) {
  _rdx59v_BlockArgs_1huiwh_blocking* args = (__bridge _rdx59v_BlockArgs_1huiwh_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _rdx59v_BlockArgs_1huiwh_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_rdx59v_BlockArgs_1huiwh_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _rdx59v_1huiwh_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, int32_t arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _rdx59v_BlockArgs_1huiwh_blocking* args = [[_rdx59v_BlockArgs_1huiwh_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _rdx59v_BlockArgs_1huiwh_blocking_finalize);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
