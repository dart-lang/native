#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>

extern uint64_t getBlockRetainCount(void*);
#import "block_test.h"

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


typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _18tji2r_wrapListenerBlock_1pl9qdv(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void() {
    _ListenerTrampoline strongBlock = block;
    strongBlock();
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _18tji2r_wrapBlockingBlock_1pl9qdv(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(), {
    _BlockingTrampoline strongBlock = block;
    strongBlock(nil);
  }, {
    _BlockingTrampoline strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter);
  });
}
@interface _18tji2r_BlockArgs_1cme7zu : NSObject {
  @public
  id block;

}
@end

@implementation _18tji2r_BlockArgs_1cme7zu
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1cme7zu_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1cme7zu*)peer)->block;
}


void _18tji2r_BlockArgs_1cme7zu_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_1cme7zu_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1cme7zu_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1cme7zu_portBlockInvoke(ObjCBlockImpl* block) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1cme7zu* args = [[_18tji2r_BlockArgs_1cme7zu alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1cme7zu_finalize);
}
@interface _18tji2r_BlockArgs_1cme7zu_blocking : NSObject {
  @public
  void* waiter;
  id block;

}
@end

@implementation _18tji2r_BlockArgs_1cme7zu_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1cme7zu_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_1cme7zu_blocking* args = (__bridge _18tji2r_BlockArgs_1cme7zu_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1cme7zu_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1cme7zu_blocking*)peer)->block;
}


void _18tji2r_BlockArgs_1cme7zu_blocking_free(void* peer) {
  _18tji2r_BlockArgs_1cme7zu_blocking* args = (__bridge _18tji2r_BlockArgs_1cme7zu_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_1cme7zu_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1cme7zu_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1cme7zu_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1cme7zu_blocking* args = [[_18tji2r_BlockArgs_1cme7zu_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1cme7zu_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_1)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _18tji2r_wrapListenerBlock_xtuoz7(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    _ListenerTrampoline_1 strongBlock = block;
    strongBlock(arg0);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _18tji2r_wrapBlockingBlock_xtuoz7(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    _BlockingTrampoline_1 strongBlock = block;
    strongBlock(nil, arg0);
  }, {
    _BlockingTrampoline_1 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0);
  });
}
@interface _18tji2r_BlockArgs_46g30m : NSObject {
  @public
  id block;
  id arg0;
}
@end

@implementation _18tji2r_BlockArgs_46g30m
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_46g30m_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_46g30m*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_46g30m_getArg0(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_46g30m*)peer)->arg0;
}


void _18tji2r_BlockArgs_46g30m_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_46g30m_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_46g30m_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_46g30m_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_46g30m* args = [[_18tji2r_BlockArgs_46g30m alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_46g30m_finalize);
}
@interface _18tji2r_BlockArgs_46g30m_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
}
@end

@implementation _18tji2r_BlockArgs_46g30m_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_46g30m_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_46g30m_blocking* args = (__bridge _18tji2r_BlockArgs_46g30m_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_46g30m_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_46g30m_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_46g30m_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_46g30m_blocking*)peer)->arg0;
}


void _18tji2r_BlockArgs_46g30m_blocking_free(void* peer) {
  _18tji2r_BlockArgs_46g30m_blocking* args = (__bridge _18tji2r_BlockArgs_46g30m_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_46g30m_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_46g30m_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_46g30m_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_46g30m_blocking* args = [[_18tji2r_BlockArgs_46g30m_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_46g30m_blocking_finalize);
}
@interface _18tji2r_BlockArgs_2wxtr2 : NSObject {
  @public
  id block;
  id arg0;
}
@end

@implementation _18tji2r_BlockArgs_2wxtr2
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_2wxtr2_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_2wxtr2*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _18tji2r_BlockArgs_2wxtr2_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_2wxtr2*)peer)->arg0;
}


void _18tji2r_BlockArgs_2wxtr2_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_2wxtr2_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_2wxtr2_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_2wxtr2_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_2wxtr2* args = [[_18tji2r_BlockArgs_2wxtr2 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_2wxtr2_finalize);
}
@interface _18tji2r_BlockArgs_2wxtr2_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
}
@end

@implementation _18tji2r_BlockArgs_2wxtr2_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_2wxtr2_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_2wxtr2_blocking* args = (__bridge _18tji2r_BlockArgs_2wxtr2_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_2wxtr2_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_2wxtr2_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _18tji2r_BlockArgs_2wxtr2_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_2wxtr2_blocking*)peer)->arg0;
}


void _18tji2r_BlockArgs_2wxtr2_blocking_free(void* peer) {
  _18tji2r_BlockArgs_2wxtr2_blocking* args = (__bridge _18tji2r_BlockArgs_2wxtr2_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_2wxtr2_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_2wxtr2_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_2wxtr2_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_2wxtr2_blocking* args = [[_18tji2r_BlockArgs_2wxtr2_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_2wxtr2_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_2)(int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _18tji2r_wrapListenerBlock_1bqef4y(_ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(int32_t arg0) {
    _ListenerTrampoline_2 strongBlock = block;
    strongBlock(arg0);
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _18tji2r_wrapBlockingBlock_1bqef4y(
    _BlockingTrampoline_2 block, _BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0), {
    _BlockingTrampoline_2 strongBlock = block;
    strongBlock(nil, arg0);
  }, {
    _BlockingTrampoline_2 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0);
  });
}
@interface _18tji2r_BlockArgs_1huiwh : NSObject {
  @public
  id block;
  int32_t arg0;
}
@end

@implementation _18tji2r_BlockArgs_1huiwh
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1huiwh_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1huiwh*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _18tji2r_BlockArgs_1huiwh_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1huiwh*)peer)->arg0;
}


void _18tji2r_BlockArgs_1huiwh_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_1huiwh_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1huiwh_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1huiwh_portBlockInvoke(ObjCBlockImpl* block, int32_t arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1huiwh* args = [[_18tji2r_BlockArgs_1huiwh alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1huiwh_finalize);
}
@interface _18tji2r_BlockArgs_1huiwh_blocking : NSObject {
  @public
  void* waiter;
  id block;
  int32_t arg0;
}
@end

@implementation _18tji2r_BlockArgs_1huiwh_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1huiwh_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_1huiwh_blocking* args = (__bridge _18tji2r_BlockArgs_1huiwh_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1huiwh_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1huiwh_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _18tji2r_BlockArgs_1huiwh_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1huiwh_blocking*)peer)->arg0;
}


void _18tji2r_BlockArgs_1huiwh_blocking_free(void* peer) {
  _18tji2r_BlockArgs_1huiwh_blocking* args = (__bridge _18tji2r_BlockArgs_1huiwh_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_1huiwh_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1huiwh_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1huiwh_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, int32_t arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1huiwh_blocking* args = [[_18tji2r_BlockArgs_1huiwh_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1huiwh_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_3)(int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _18tji2r_wrapListenerBlock_yhkuco(_ListenerTrampoline_3 block) NS_RETURNS_RETAINED {
  return ^void(int32_t * arg0) {
    _ListenerTrampoline_3 strongBlock = block;
    strongBlock(arg0);
  };
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _18tji2r_wrapBlockingBlock_yhkuco(
    _BlockingTrampoline_3 block, _BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t * arg0), {
    _BlockingTrampoline_3 strongBlock = block;
    strongBlock(nil, arg0);
  }, {
    _BlockingTrampoline_3 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0);
  });
}
@interface _18tji2r_BlockArgs_l0gbcx : NSObject {
  @public
  id block;
  int32_t * arg0;
}
@end

@implementation _18tji2r_BlockArgs_l0gbcx
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_l0gbcx_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_l0gbcx*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t *  _18tji2r_BlockArgs_l0gbcx_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_l0gbcx*)peer)->arg0;
}


void _18tji2r_BlockArgs_l0gbcx_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_l0gbcx_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_l0gbcx_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_l0gbcx_portBlockInvoke(ObjCBlockImpl* block, int32_t * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_l0gbcx* args = [[_18tji2r_BlockArgs_l0gbcx alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_l0gbcx_finalize);
}
@interface _18tji2r_BlockArgs_l0gbcx_blocking : NSObject {
  @public
  void* waiter;
  id block;
  int32_t * arg0;
}
@end

@implementation _18tji2r_BlockArgs_l0gbcx_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_l0gbcx_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_l0gbcx_blocking* args = (__bridge _18tji2r_BlockArgs_l0gbcx_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_l0gbcx_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_l0gbcx_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t *  _18tji2r_BlockArgs_l0gbcx_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_l0gbcx_blocking*)peer)->arg0;
}


void _18tji2r_BlockArgs_l0gbcx_blocking_free(void* peer) {
  _18tji2r_BlockArgs_l0gbcx_blocking* args = (__bridge _18tji2r_BlockArgs_l0gbcx_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_l0gbcx_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_l0gbcx_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_l0gbcx_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, int32_t * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_l0gbcx_blocking* args = [[_18tji2r_BlockArgs_l0gbcx_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_l0gbcx_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_4)(int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _18tji2r_wrapListenerBlock_li50va(_ListenerTrampoline_4 block) NS_RETURNS_RETAINED {
  return ^void(int32_t arg0, Vec4 arg1, char * arg2) {
    _ListenerTrampoline_4 strongBlock = block;
    strongBlock(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _18tji2r_wrapBlockingBlock_li50va(
    _BlockingTrampoline_4 block, _BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0, Vec4 arg1, char * arg2), {
    _BlockingTrampoline_4 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2);
  }, {
    _BlockingTrampoline_4 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2);
  });
}
@interface _18tji2r_BlockArgs_1kn896c : NSObject {
  @public
  id block;
  int32_t arg0;
  Vec4 arg1;
  char * arg2;
}
@end

@implementation _18tji2r_BlockArgs_1kn896c
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1kn896c_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1kn896c*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _18tji2r_BlockArgs_1kn896c_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1kn896c*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
Vec4  _18tji2r_BlockArgs_1kn896c_getArg1(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1kn896c*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
char *  _18tji2r_BlockArgs_1kn896c_getArg2(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1kn896c*)peer)->arg2;
}


void _18tji2r_BlockArgs_1kn896c_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_1kn896c_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1kn896c_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1kn896c_portBlockInvoke(ObjCBlockImpl* block, int32_t arg0, Vec4 arg1, char * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1kn896c* args = [[_18tji2r_BlockArgs_1kn896c alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1kn896c_finalize);
}
@interface _18tji2r_BlockArgs_1kn896c_blocking : NSObject {
  @public
  void* waiter;
  id block;
  int32_t arg0;
  Vec4 arg1;
  char * arg2;
}
@end

@implementation _18tji2r_BlockArgs_1kn896c_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1kn896c_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_1kn896c_blocking* args = (__bridge _18tji2r_BlockArgs_1kn896c_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1kn896c_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1kn896c_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _18tji2r_BlockArgs_1kn896c_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1kn896c_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
Vec4  _18tji2r_BlockArgs_1kn896c_blocking_getArg1(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1kn896c_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
char *  _18tji2r_BlockArgs_1kn896c_blocking_getArg2(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1kn896c_blocking*)peer)->arg2;
}


void _18tji2r_BlockArgs_1kn896c_blocking_free(void* peer) {
  _18tji2r_BlockArgs_1kn896c_blocking* args = (__bridge _18tji2r_BlockArgs_1kn896c_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_1kn896c_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1kn896c_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1kn896c_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, int32_t arg0, Vec4 arg1, char * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1kn896c_blocking* args = [[_18tji2r_BlockArgs_1kn896c_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1kn896c_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_5)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _18tji2r_wrapListenerBlock_f167m6(_ListenerTrampoline_5 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    _ListenerTrampoline_5 strongBlock = block;
    strongBlock(arg0);
  };
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _18tji2r_wrapBlockingBlock_f167m6(
    _BlockingTrampoline_5 block, _BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    _BlockingTrampoline_5 strongBlock = block;
    strongBlock(nil, arg0);
  }, {
    _BlockingTrampoline_5 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0);
  });
}
@interface _18tji2r_BlockArgs_1xjdmo1 : NSObject {
  @public
  id block;
  id arg0;
}
@end

@implementation _18tji2r_BlockArgs_1xjdmo1
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1xjdmo1_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1xjdmo1*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1xjdmo1_getArg0(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1xjdmo1*)peer)->arg0;
}


void _18tji2r_BlockArgs_1xjdmo1_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_1xjdmo1_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1xjdmo1_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1xjdmo1_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1xjdmo1* args = [[_18tji2r_BlockArgs_1xjdmo1 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = (__bridge_transfer id)(__bridge void*)objc_retainBlock(arg0);

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1xjdmo1_finalize);
}
@interface _18tji2r_BlockArgs_1xjdmo1_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
}
@end

@implementation _18tji2r_BlockArgs_1xjdmo1_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1xjdmo1_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_1xjdmo1_blocking* args = (__bridge _18tji2r_BlockArgs_1xjdmo1_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1xjdmo1_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1xjdmo1_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1xjdmo1_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1xjdmo1_blocking*)peer)->arg0;
}


void _18tji2r_BlockArgs_1xjdmo1_blocking_free(void* peer) {
  _18tji2r_BlockArgs_1xjdmo1_blocking* args = (__bridge _18tji2r_BlockArgs_1xjdmo1_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_1xjdmo1_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1xjdmo1_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1xjdmo1_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1xjdmo1_blocking* args = [[_18tji2r_BlockArgs_1xjdmo1_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = (__bridge_transfer id)(__bridge void*)objc_retainBlock(arg0);

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1xjdmo1_blocking_finalize);
}
@interface _18tji2r_BlockArgs_1nfopnd : NSObject {
  @public
  id block;
  id arg0;
}
@end

@implementation _18tji2r_BlockArgs_1nfopnd
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1nfopnd_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1nfopnd*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1nfopnd_getArg0(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1nfopnd*)peer)->arg0;
}


void _18tji2r_BlockArgs_1nfopnd_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_1nfopnd_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1nfopnd_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1nfopnd_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1nfopnd* args = [[_18tji2r_BlockArgs_1nfopnd alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1nfopnd_finalize);
}
@interface _18tji2r_BlockArgs_1nfopnd_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
}
@end

@implementation _18tji2r_BlockArgs_1nfopnd_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1nfopnd_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_1nfopnd_blocking* args = (__bridge _18tji2r_BlockArgs_1nfopnd_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1nfopnd_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1nfopnd_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1nfopnd_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1nfopnd_blocking*)peer)->arg0;
}


void _18tji2r_BlockArgs_1nfopnd_blocking_free(void* peer) {
  _18tji2r_BlockArgs_1nfopnd_blocking* args = (__bridge _18tji2r_BlockArgs_1nfopnd_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_1nfopnd_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1nfopnd_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1nfopnd_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1nfopnd_blocking* args = [[_18tji2r_BlockArgs_1nfopnd_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1nfopnd_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_6)(struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _18tji2r_wrapListenerBlock_ru30ue(_ListenerTrampoline_6 block) NS_RETURNS_RETAINED {
  return ^void(struct Vec2 arg0, Vec4 arg1, id arg2) {
    _ListenerTrampoline_6 strongBlock = block;
    strongBlock(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _18tji2r_wrapBlockingBlock_ru30ue(
    _BlockingTrampoline_6 block, _BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct Vec2 arg0, Vec4 arg1, id arg2), {
    _BlockingTrampoline_6 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2);
  }, {
    _BlockingTrampoline_6 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2);
  });
}
@interface _18tji2r_BlockArgs_1uznk83 : NSObject {
  @public
  id block;
  struct Vec2 arg0;
  Vec4 arg1;
  id arg2;
}
@end

@implementation _18tji2r_BlockArgs_1uznk83
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1uznk83_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1uznk83*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
struct Vec2  _18tji2r_BlockArgs_1uznk83_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1uznk83*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
Vec4  _18tji2r_BlockArgs_1uznk83_getArg1(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1uznk83*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1uznk83_getArg2(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1uznk83*)peer)->arg2;
}


void _18tji2r_BlockArgs_1uznk83_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_1uznk83_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1uznk83_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1uznk83_portBlockInvoke(ObjCBlockImpl* block, struct Vec2 arg0, Vec4 arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1uznk83* args = [[_18tji2r_BlockArgs_1uznk83 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1uznk83_finalize);
}
@interface _18tji2r_BlockArgs_1uznk83_blocking : NSObject {
  @public
  void* waiter;
  id block;
  struct Vec2 arg0;
  Vec4 arg1;
  id arg2;
}
@end

@implementation _18tji2r_BlockArgs_1uznk83_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1uznk83_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_1uznk83_blocking* args = (__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1uznk83_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
struct Vec2  _18tji2r_BlockArgs_1uznk83_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
Vec4  _18tji2r_BlockArgs_1uznk83_blocking_getArg1(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1uznk83_blocking_getArg2(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer)->arg2;
}


void _18tji2r_BlockArgs_1uznk83_blocking_free(void* peer) {
  _18tji2r_BlockArgs_1uznk83_blocking* args = (__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_1uznk83_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_1uznk83_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_1uznk83_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, struct Vec2 arg0, Vec4 arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_1uznk83_blocking* args = [[_18tji2r_BlockArgs_1uznk83_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1uznk83_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_7)(struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _18tji2r_wrapListenerBlock_1d9e4oe(_ListenerTrampoline_7 block) NS_RETURNS_RETAINED {
  return ^void(struct objc_selector * arg0) {
    _ListenerTrampoline_7 strongBlock = block;
    strongBlock(arg0);
  };
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _18tji2r_wrapBlockingBlock_1d9e4oe(
    _BlockingTrampoline_7 block, _BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct objc_selector * arg0), {
    _BlockingTrampoline_7 strongBlock = block;
    strongBlock(nil, arg0);
  }, {
    _BlockingTrampoline_7 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0);
  });
}
@interface _18tji2r_BlockArgs_124zeca : NSObject {
  @public
  id block;
  struct objc_selector * arg0;
}
@end

@implementation _18tji2r_BlockArgs_124zeca
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_124zeca_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_124zeca*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
struct objc_selector *  _18tji2r_BlockArgs_124zeca_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_124zeca*)peer)->arg0;
}


void _18tji2r_BlockArgs_124zeca_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _18tji2r_BlockArgs_124zeca_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_124zeca_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_124zeca_portBlockInvoke(ObjCBlockImpl* block, struct objc_selector * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_124zeca* args = [[_18tji2r_BlockArgs_124zeca alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_124zeca_finalize);
}
@interface _18tji2r_BlockArgs_124zeca_blocking : NSObject {
  @public
  void* waiter;
  id block;
  struct objc_selector * arg0;
}
@end

@implementation _18tji2r_BlockArgs_124zeca_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_124zeca_blocking_signalWaiter(void* peer) {
  _18tji2r_BlockArgs_124zeca_blocking* args = (__bridge _18tji2r_BlockArgs_124zeca_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_124zeca_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _18tji2r_BlockArgs_124zeca_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
struct objc_selector *  _18tji2r_BlockArgs_124zeca_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_124zeca_blocking*)peer)->arg0;
}


void _18tji2r_BlockArgs_124zeca_blocking_free(void* peer) {
  _18tji2r_BlockArgs_124zeca_blocking* args = (__bridge _18tji2r_BlockArgs_124zeca_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _18tji2r_BlockArgs_124zeca_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_BlockArgs_124zeca_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_124zeca_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, struct objc_selector * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_124zeca_blocking* args = [[_18tji2r_BlockArgs_124zeca_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _18tji2r_BlockArgs_124zeca_blocking_finalize);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
