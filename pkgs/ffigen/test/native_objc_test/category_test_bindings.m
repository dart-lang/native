#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>

extern uint64_t getBlockRetainCount(void*);
#import "category_test.h"
#import "category_test.h"

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


typedef void  (^_ListenerTrampoline)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _l3cf7j_wrapListenerBlock_pfv6jd(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    _ListenerTrampoline strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _l3cf7j_wrapBlockingBlock_pfv6jd(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    _BlockingTrampoline strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _l3cf7j_BlockArgs_1ilrkog : NSObject {
  @public
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _l3cf7j_BlockArgs_1ilrkog
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _l3cf7j_BlockArgs_1ilrkog_getBlock(void* peer) {
  return (__bridge void*)((__bridge _l3cf7j_BlockArgs_1ilrkog*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _l3cf7j_BlockArgs_1ilrkog_getArg0(void* peer) {
  return ((__bridge _l3cf7j_BlockArgs_1ilrkog*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _l3cf7j_BlockArgs_1ilrkog_getArg1(void* peer) {
  return ((__bridge _l3cf7j_BlockArgs_1ilrkog*)peer)->arg1;
}


void _l3cf7j_BlockArgs_1ilrkog_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _l3cf7j_BlockArgs_1ilrkog_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_l3cf7j_BlockArgs_1ilrkog_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _l3cf7j_1ilrkog_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _l3cf7j_BlockArgs_1ilrkog* args = [[_l3cf7j_BlockArgs_1ilrkog alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _l3cf7j_BlockArgs_1ilrkog_finalize);
}
@interface _l3cf7j_BlockArgs_1ilrkog_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _l3cf7j_BlockArgs_1ilrkog_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _l3cf7j_BlockArgs_1ilrkog_blocking_signalWaiter(void* peer) {
  _l3cf7j_BlockArgs_1ilrkog_blocking* args = (__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _l3cf7j_BlockArgs_1ilrkog_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _l3cf7j_BlockArgs_1ilrkog_blocking_getArg0(void* peer) {
  return ((__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _l3cf7j_BlockArgs_1ilrkog_blocking_getArg1(void* peer) {
  return ((__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer)->arg1;
}


void _l3cf7j_BlockArgs_1ilrkog_blocking_free(void* peer) {
  _l3cf7j_BlockArgs_1ilrkog_blocking* args = (__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _l3cf7j_BlockArgs_1ilrkog_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_l3cf7j_BlockArgs_1ilrkog_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _l3cf7j_1ilrkog_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _l3cf7j_BlockArgs_1ilrkog_blocking* args = [[_l3cf7j_BlockArgs_1ilrkog_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _l3cf7j_BlockArgs_1ilrkog_blocking_finalize);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
