#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>

extern uint64_t getBlockRetainCount(void*);
#import "block_annotation_test.h"

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


__attribute__((visibility("default"))) __attribute__((used))
Protocol* _z0xonr_BlockAnnotationTestProtocol(void) { return @protocol(BlockAnnotationTestProtocol); }

typedef id  (^_ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _z0xonr_protocolTrampoline_zb0vvk(id target, void * sel) {
  return ((_ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_1)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _z0xonr_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((_ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_2)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _z0xonr_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_3)(void * sel, id arg1 __attribute__((ns_consumed)));
__attribute__((visibility("default"))) __attribute__((used))
id  _z0xonr_protocolTrampoline_cww6wh(id target, void * sel, id arg1 __attribute__((ns_consumed))) {
  return ((_ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _z0xonr_wrapListenerBlock_1pl9qdv(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void() {
    _ListenerTrampoline strongBlock = block;
    strongBlock();
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _z0xonr_wrapBlockingBlock_1pl9qdv(
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
@interface _z0xonr_BlockArgs_1cme7zu : NSObject {
  @public
  id block;

}
@end

@implementation _z0xonr_BlockArgs_1cme7zu
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_1cme7zu_getBlock(void* peer) {
  return (__bridge void*)((__bridge _z0xonr_BlockArgs_1cme7zu*)peer)->block;
}


void _z0xonr_BlockArgs_1cme7zu_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _z0xonr_BlockArgs_1cme7zu_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_z0xonr_BlockArgs_1cme7zu_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_1cme7zu_portBlockInvoke(ObjCBlockImpl* block) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _z0xonr_BlockArgs_1cme7zu* args = [[_z0xonr_BlockArgs_1cme7zu alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _z0xonr_BlockArgs_1cme7zu_finalize);
}
@interface _z0xonr_BlockArgs_1cme7zu_blocking : NSObject {
  @public
  void* waiter;
  id block;

}
@end

@implementation _z0xonr_BlockArgs_1cme7zu_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_BlockArgs_1cme7zu_blocking_signalWaiter(void* peer) {
  _z0xonr_BlockArgs_1cme7zu_blocking* args = (__bridge _z0xonr_BlockArgs_1cme7zu_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_1cme7zu_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _z0xonr_BlockArgs_1cme7zu_blocking*)peer)->block;
}


void _z0xonr_BlockArgs_1cme7zu_blocking_free(void* peer) {
  _z0xonr_BlockArgs_1cme7zu_blocking* args = (__bridge _z0xonr_BlockArgs_1cme7zu_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _z0xonr_BlockArgs_1cme7zu_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_z0xonr_BlockArgs_1cme7zu_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_1cme7zu_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _z0xonr_BlockArgs_1cme7zu_blocking* args = [[_z0xonr_BlockArgs_1cme7zu_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _z0xonr_BlockArgs_1cme7zu_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_1)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _z0xonr_wrapListenerBlock_18v1jvf(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    _ListenerTrampoline_1 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _z0xonr_wrapBlockingBlock_18v1jvf(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    _BlockingTrampoline_1 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_1 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _z0xonr_BlockArgs_1iiqbf5 : NSObject {
  @public
  id block;
  void * arg0;
  id arg1;
}
@end

@implementation _z0xonr_BlockArgs_1iiqbf5
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_1iiqbf5_getBlock(void* peer) {
  return (__bridge void*)((__bridge _z0xonr_BlockArgs_1iiqbf5*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _z0xonr_BlockArgs_1iiqbf5_getArg0(void* peer) {
  return ((__bridge _z0xonr_BlockArgs_1iiqbf5*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_1iiqbf5_getArg1(void* peer) {
  return (__bridge void*)((__bridge _z0xonr_BlockArgs_1iiqbf5*)peer)->arg1;
}


void _z0xonr_BlockArgs_1iiqbf5_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _z0xonr_BlockArgs_1iiqbf5_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_z0xonr_BlockArgs_1iiqbf5_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_1iiqbf5_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _z0xonr_BlockArgs_1iiqbf5* args = [[_z0xonr_BlockArgs_1iiqbf5 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _z0xonr_BlockArgs_1iiqbf5_finalize);
}
@interface _z0xonr_BlockArgs_1iiqbf5_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
  id arg1;
}
@end

@implementation _z0xonr_BlockArgs_1iiqbf5_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_BlockArgs_1iiqbf5_blocking_signalWaiter(void* peer) {
  _z0xonr_BlockArgs_1iiqbf5_blocking* args = (__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_1iiqbf5_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _z0xonr_BlockArgs_1iiqbf5_blocking_getArg0(void* peer) {
  return ((__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_1iiqbf5_blocking_getArg1(void* peer) {
  return (__bridge void*)((__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer)->arg1;
}


void _z0xonr_BlockArgs_1iiqbf5_blocking_free(void* peer) {
  _z0xonr_BlockArgs_1iiqbf5_blocking* args = (__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _z0xonr_BlockArgs_1iiqbf5_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_z0xonr_BlockArgs_1iiqbf5_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_1iiqbf5_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _z0xonr_BlockArgs_1iiqbf5_blocking* args = [[_z0xonr_BlockArgs_1iiqbf5_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _z0xonr_BlockArgs_1iiqbf5_blocking_finalize);
}

typedef void  (^_ProtocolTrampoline_4)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _z0xonr_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_2)(void * arg0, id arg1 __attribute__((ns_consumed)));
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _z0xonr_wrapListenerBlock_6yc3kd(_ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1 __attribute__((ns_consumed))) {
    _ListenerTrampoline_2 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, void * arg0, id arg1 __attribute__((ns_consumed)));
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _z0xonr_wrapBlockingBlock_6yc3kd(
    _BlockingTrampoline_2 block, _BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1 __attribute__((ns_consumed))), {
    _BlockingTrampoline_2 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_2 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _z0xonr_BlockArgs_10ofcgx : NSObject {
  @public
  id block;
  void * arg0;
  id arg1;
}
@end

@implementation _z0xonr_BlockArgs_10ofcgx
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_10ofcgx_getBlock(void* peer) {
  return (__bridge void*)((__bridge _z0xonr_BlockArgs_10ofcgx*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _z0xonr_BlockArgs_10ofcgx_getArg0(void* peer) {
  return ((__bridge _z0xonr_BlockArgs_10ofcgx*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_10ofcgx_takeArg1(void* peer) {
  _z0xonr_BlockArgs_10ofcgx* args = (__bridge _z0xonr_BlockArgs_10ofcgx*)peer;
  void* val = (__bridge_retained void*)args->arg1;
  args->arg1 = nil;
  return val;
}


void _z0xonr_BlockArgs_10ofcgx_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _z0xonr_BlockArgs_10ofcgx_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_z0xonr_BlockArgs_10ofcgx_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_10ofcgx_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _z0xonr_BlockArgs_10ofcgx* args = [[_z0xonr_BlockArgs_10ofcgx alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _z0xonr_BlockArgs_10ofcgx_finalize);
}
@interface _z0xonr_BlockArgs_10ofcgx_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
  id arg1;
}
@end

@implementation _z0xonr_BlockArgs_10ofcgx_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_BlockArgs_10ofcgx_blocking_signalWaiter(void* peer) {
  _z0xonr_BlockArgs_10ofcgx_blocking* args = (__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_10ofcgx_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _z0xonr_BlockArgs_10ofcgx_blocking_getArg0(void* peer) {
  return ((__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_10ofcgx_blocking_takeArg1(void* peer) {
  _z0xonr_BlockArgs_10ofcgx_blocking* args = (__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer;
  void* val = (__bridge_retained void*)args->arg1;
  args->arg1 = nil;
  return val;
}


void _z0xonr_BlockArgs_10ofcgx_blocking_free(void* peer) {
  _z0xonr_BlockArgs_10ofcgx_blocking* args = (__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _z0xonr_BlockArgs_10ofcgx_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_z0xonr_BlockArgs_10ofcgx_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_10ofcgx_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _z0xonr_BlockArgs_10ofcgx_blocking* args = [[_z0xonr_BlockArgs_10ofcgx_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _z0xonr_BlockArgs_10ofcgx_blocking_finalize);
}

typedef void  (^_ProtocolTrampoline_5)(void * sel, id arg1 __attribute__((ns_consumed)));
__attribute__((visibility("default"))) __attribute__((used))
void  _z0xonr_protocolTrampoline_6yc3kd(id target, void * sel, id arg1 __attribute__((ns_consumed))) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
