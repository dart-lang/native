#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "block_annotation_test.h"

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
@interface _z0xonr_BlockArgs_1cme7zu : NSObject {
  @public
  id block;
  void* context;

}
@end

@implementation _z0xonr_BlockArgs_1cme7zu
@end



void _z0xonr_BlockArgs_1cme7zu_free(void* peer) {
  @autoreleasepool {
    _z0xonr_BlockArgs_1cme7zu* args = (__bridge _z0xonr_BlockArgs_1cme7zu*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _z0xonr_BlockArgs_1cme7zu_finalize(void* isolate_callback_data, void* peer) {
  _z0xonr_BlockArgs_1cme7zu* args = (__bridge _z0xonr_BlockArgs_1cme7zu*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_z0xonr_BlockArgs_1cme7zu_free, peer);
}

typedef void  (^_ListenerTrampoline)(void);

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_1cme7zu_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void() {
    _z0xonr_BlockArgs_1cme7zu* args = [[_z0xonr_BlockArgs_1cme7zu alloc] init];
    args->block = block;
    args->context = context;
    
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _z0xonr_BlockArgs_1cme7zu_finalize);
  } copy]);
}
@interface _z0xonr_BlockArgs_1cme7zu_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;

}
@end

@implementation _z0xonr_BlockArgs_1cme7zu_blocking
@end



__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_BlockArgs_1cme7zu_blocking_free(void* peer) {
  @autoreleasepool {
    _z0xonr_BlockArgs_1cme7zu_blocking* args = (__bridge _z0xonr_BlockArgs_1cme7zu_blocking*)peer;
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

void _z0xonr_BlockArgs_1cme7zu_blocking_finalize(void* isolate_callback_data, void* peer) {
  _z0xonr_BlockArgs_1cme7zu_blocking* args = (__bridge _z0xonr_BlockArgs_1cme7zu_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_z0xonr_BlockArgs_1cme7zu_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline)(void* block);

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_1cme7zu_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void() {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline)block)((__bridge void*)block);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _z0xonr_BlockArgs_1cme7zu_blocking* args = [[_z0xonr_BlockArgs_1cme7zu_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _z0xonr_BlockArgs_1cme7zu_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _z0xonr_BlockArgs_1iiqbf5 : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _z0xonr_BlockArgs_1iiqbf5
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _z0xonr_BlockArgs_1iiqbf5_getArg0(void* peer) {
  return ((__bridge _z0xonr_BlockArgs_1iiqbf5*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_1iiqbf5_getArg1(void* peer) {
  void* val = ((__bridge _z0xonr_BlockArgs_1iiqbf5*)peer)->arg1;
  ((__bridge _z0xonr_BlockArgs_1iiqbf5*)peer)->arg1 = NULL;
  return val;
}


void _z0xonr_BlockArgs_1iiqbf5_free(void* peer) {
  @autoreleasepool {
    _z0xonr_BlockArgs_1iiqbf5* args = (__bridge _z0xonr_BlockArgs_1iiqbf5*)peer;
    if (args->arg1 != NULL) {
      id relObj = (__bridge_transfer id)args->arg1;
    }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _z0xonr_BlockArgs_1iiqbf5_finalize(void* isolate_callback_data, void* peer) {
  _z0xonr_BlockArgs_1iiqbf5* args = (__bridge _z0xonr_BlockArgs_1iiqbf5*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_z0xonr_BlockArgs_1iiqbf5_free, peer);
}

typedef void  (^_ListenerTrampoline_1)(void * arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_1iiqbf5_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1) {
    _z0xonr_BlockArgs_1iiqbf5* args = [[_z0xonr_BlockArgs_1iiqbf5 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _z0xonr_BlockArgs_1iiqbf5_finalize);
  } copy]);
}
@interface _z0xonr_BlockArgs_1iiqbf5_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _z0xonr_BlockArgs_1iiqbf5_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _z0xonr_BlockArgs_1iiqbf5_blocking_getArg0(void* peer) {
  return ((__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_1iiqbf5_blocking_getArg1(void* peer) {
  void* val = ((__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer)->arg1;
  ((__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer)->arg1 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_BlockArgs_1iiqbf5_blocking_free(void* peer) {
  @autoreleasepool {
    _z0xonr_BlockArgs_1iiqbf5_blocking* args = (__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg1 != NULL) {
      id relObj = (__bridge_transfer id)args->arg1;
    }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _z0xonr_BlockArgs_1iiqbf5_blocking_finalize(void* isolate_callback_data, void* peer) {
  _z0xonr_BlockArgs_1iiqbf5_blocking* args = (__bridge _z0xonr_BlockArgs_1iiqbf5_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_z0xonr_BlockArgs_1iiqbf5_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_1)(void* block, void * arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_1iiqbf5_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_1)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _z0xonr_BlockArgs_1iiqbf5_blocking* args = [[_z0xonr_BlockArgs_1iiqbf5_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _z0xonr_BlockArgs_1iiqbf5_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_4)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _z0xonr_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
@interface _z0xonr_BlockArgs_10ofcgx : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _z0xonr_BlockArgs_10ofcgx
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _z0xonr_BlockArgs_10ofcgx_getArg0(void* peer) {
  return ((__bridge _z0xonr_BlockArgs_10ofcgx*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_10ofcgx_takeArg1(void* peer) {
  void* val = ((__bridge _z0xonr_BlockArgs_10ofcgx*)peer)->arg1;
  ((__bridge _z0xonr_BlockArgs_10ofcgx*)peer)->arg1 = NULL;
  return val;
}


void _z0xonr_BlockArgs_10ofcgx_free(void* peer) {
  @autoreleasepool {
    _z0xonr_BlockArgs_10ofcgx* args = (__bridge _z0xonr_BlockArgs_10ofcgx*)peer;
    if (args->arg1 != NULL) {
      id relObj = (__bridge_transfer id)args->arg1;
    }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _z0xonr_BlockArgs_10ofcgx_finalize(void* isolate_callback_data, void* peer) {
  _z0xonr_BlockArgs_10ofcgx* args = (__bridge _z0xonr_BlockArgs_10ofcgx*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_z0xonr_BlockArgs_10ofcgx_free, peer);
}

typedef void  (^_ListenerTrampoline_2)(void * arg0, id arg1 __attribute__((ns_consumed)));

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_10ofcgx_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1 __attribute__((ns_consumed))) {
    _z0xonr_BlockArgs_10ofcgx* args = [[_z0xonr_BlockArgs_10ofcgx alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _z0xonr_BlockArgs_10ofcgx_finalize);
  } copy]);
}
@interface _z0xonr_BlockArgs_10ofcgx_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _z0xonr_BlockArgs_10ofcgx_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _z0xonr_BlockArgs_10ofcgx_blocking_getArg0(void* peer) {
  return ((__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_BlockArgs_10ofcgx_blocking_takeArg1(void* peer) {
  void* val = ((__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer)->arg1;
  ((__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer)->arg1 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _z0xonr_BlockArgs_10ofcgx_blocking_free(void* peer) {
  @autoreleasepool {
    _z0xonr_BlockArgs_10ofcgx_blocking* args = (__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg1 != NULL) {
      id relObj = (__bridge_transfer id)args->arg1;
    }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _z0xonr_BlockArgs_10ofcgx_blocking_finalize(void* isolate_callback_data, void* peer) {
  _z0xonr_BlockArgs_10ofcgx_blocking* args = (__bridge _z0xonr_BlockArgs_10ofcgx_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_z0xonr_BlockArgs_10ofcgx_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_2)(void* block, void * arg0, id arg1 __attribute__((ns_consumed)));

__attribute__((visibility("default"))) __attribute__((used))
void* _z0xonr_10ofcgx_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1 __attribute__((ns_consumed))) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_2)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _z0xonr_BlockArgs_10ofcgx_blocking* args = [[_z0xonr_BlockArgs_10ofcgx_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _z0xonr_BlockArgs_10ofcgx_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_5)(void * sel, id arg1 __attribute__((ns_consumed)));
__attribute__((visibility("default"))) __attribute__((used))
void  _z0xonr_protocolTrampoline_6yc3kd(id target, void * sel, id arg1 __attribute__((ns_consumed))) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
