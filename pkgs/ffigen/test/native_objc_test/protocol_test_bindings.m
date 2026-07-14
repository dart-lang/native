#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "protocol_test.h"

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
Protocol* _13hhotk_EmptyProtocol(void) { return @protocol(EmptyProtocol); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _13hhotk_MyProtocol(void) { return @protocol(MyProtocol); }

typedef int32_t  (^_ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
int32_t  _13hhotk_protocolTrampoline_1d4mjzg(id target, void * sel) {
  return ((_ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef int32_t  (^_ProtocolTrampoline_1)(void * sel, int32_t arg1, int32_t arg2, int32_t arg3, int32_t arg4);
__attribute__((visibility("default"))) __attribute__((used))
int32_t  _13hhotk_protocolTrampoline_ct0ie0(id target, void * sel, int32_t arg1, int32_t arg2, int32_t arg3, int32_t arg4) {
  return ((_ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef int32_t  (^_ProtocolTrampoline_2)(void * sel, SomeStruct arg1);
__attribute__((visibility("default"))) __attribute__((used))
int32_t  _13hhotk_protocolTrampoline_1pfwxcz(id target, void * sel, SomeStruct arg1) {
  return ((_ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_3)(void * sel, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _13hhotk_protocolTrampoline_1s2pox8(id target, void * sel, id arg1, double arg2) {
  return ((_ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}
@interface _13hhotk_BlockArgs_176zksz : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  int32_t  arg1;
}
@end

@implementation _13hhotk_BlockArgs_176zksz
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _13hhotk_BlockArgs_176zksz_getArg0(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_176zksz*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _13hhotk_BlockArgs_176zksz_getArg1(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_176zksz*)peer)->arg1;
}


void _13hhotk_BlockArgs_176zksz_free(void* peer) {
  @autoreleasepool {
    _13hhotk_BlockArgs_176zksz* args = (__bridge _13hhotk_BlockArgs_176zksz*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _13hhotk_BlockArgs_176zksz_finalize(void* isolate_callback_data, void* peer) {
  _13hhotk_BlockArgs_176zksz* args = (__bridge _13hhotk_BlockArgs_176zksz*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_13hhotk_BlockArgs_176zksz_free, peer);
}

typedef void  (^_ListenerTrampoline)(void * arg0, int32_t arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _13hhotk_176zksz_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, int32_t arg1) {
    _13hhotk_BlockArgs_176zksz* args = [[_13hhotk_BlockArgs_176zksz alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _13hhotk_BlockArgs_176zksz_finalize);
  } copy]);
}
@interface _13hhotk_BlockArgs_176zksz_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  int32_t  arg1;
}
@end

@implementation _13hhotk_BlockArgs_176zksz_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _13hhotk_BlockArgs_176zksz_blocking_getArg0(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_176zksz_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _13hhotk_BlockArgs_176zksz_blocking_getArg1(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_176zksz_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _13hhotk_BlockArgs_176zksz_blocking_free(void* peer) {
  @autoreleasepool {
    _13hhotk_BlockArgs_176zksz_blocking* args = (__bridge _13hhotk_BlockArgs_176zksz_blocking*)peer;
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

void _13hhotk_BlockArgs_176zksz_blocking_finalize(void* isolate_callback_data, void* peer) {
  _13hhotk_BlockArgs_176zksz_blocking* args = (__bridge _13hhotk_BlockArgs_176zksz_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_13hhotk_BlockArgs_176zksz_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline)(void* block, void * arg0, int32_t arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _13hhotk_176zksz_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0, int32_t arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _13hhotk_BlockArgs_176zksz_blocking* args = [[_13hhotk_BlockArgs_176zksz_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _13hhotk_BlockArgs_176zksz_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_4)(void * sel, int32_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _13hhotk_protocolTrampoline_1pbq496(id target, void * sel, int32_t arg1) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
@interface _13hhotk_BlockArgs_1a8p1u7 : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  int32_t *  arg1;
}
@end

@implementation _13hhotk_BlockArgs_1a8p1u7
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _13hhotk_BlockArgs_1a8p1u7_getArg0(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_1a8p1u7*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t *  _13hhotk_BlockArgs_1a8p1u7_getArg1(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_1a8p1u7*)peer)->arg1;
}


void _13hhotk_BlockArgs_1a8p1u7_free(void* peer) {
  @autoreleasepool {
    _13hhotk_BlockArgs_1a8p1u7* args = (__bridge _13hhotk_BlockArgs_1a8p1u7*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _13hhotk_BlockArgs_1a8p1u7_finalize(void* isolate_callback_data, void* peer) {
  _13hhotk_BlockArgs_1a8p1u7* args = (__bridge _13hhotk_BlockArgs_1a8p1u7*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_13hhotk_BlockArgs_1a8p1u7_free, peer);
}

typedef void  (^_ListenerTrampoline_1)(void * arg0, int32_t * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _13hhotk_1a8p1u7_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, int32_t * arg1) {
    _13hhotk_BlockArgs_1a8p1u7* args = [[_13hhotk_BlockArgs_1a8p1u7 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _13hhotk_BlockArgs_1a8p1u7_finalize);
  } copy]);
}
@interface _13hhotk_BlockArgs_1a8p1u7_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  int32_t *  arg1;
}
@end

@implementation _13hhotk_BlockArgs_1a8p1u7_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _13hhotk_BlockArgs_1a8p1u7_blocking_getArg0(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_1a8p1u7_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
int32_t *  _13hhotk_BlockArgs_1a8p1u7_blocking_getArg1(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_1a8p1u7_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _13hhotk_BlockArgs_1a8p1u7_blocking_free(void* peer) {
  @autoreleasepool {
    _13hhotk_BlockArgs_1a8p1u7_blocking* args = (__bridge _13hhotk_BlockArgs_1a8p1u7_blocking*)peer;
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

void _13hhotk_BlockArgs_1a8p1u7_blocking_finalize(void* isolate_callback_data, void* peer) {
  _13hhotk_BlockArgs_1a8p1u7_blocking* args = (__bridge _13hhotk_BlockArgs_1a8p1u7_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_13hhotk_BlockArgs_1a8p1u7_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_1)(void* block, void * arg0, int32_t * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _13hhotk_1a8p1u7_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0, int32_t * arg1) {
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
      _13hhotk_BlockArgs_1a8p1u7_blocking* args = [[_13hhotk_BlockArgs_1a8p1u7_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _13hhotk_BlockArgs_1a8p1u7_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_5)(void * sel, int32_t * arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _13hhotk_protocolTrampoline_8r9qkg(id target, void * sel, int32_t * arg1) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
@interface _13hhotk_BlockArgs_o4v3e9 : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _13hhotk_BlockArgs_o4v3e9
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _13hhotk_BlockArgs_o4v3e9_getArg0(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_o4v3e9*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _13hhotk_BlockArgs_o4v3e9_getArg1(void* peer) {
  void* val = ((__bridge _13hhotk_BlockArgs_o4v3e9*)peer)->arg1;
  ((__bridge _13hhotk_BlockArgs_o4v3e9*)peer)->arg1 = NULL;
  return val;
}


void _13hhotk_BlockArgs_o4v3e9_free(void* peer) {
  @autoreleasepool {
    _13hhotk_BlockArgs_o4v3e9* args = (__bridge _13hhotk_BlockArgs_o4v3e9*)peer;
    if (args->arg1 != NULL) {
      id relObj = (__bridge_transfer id)args->arg1;
    }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _13hhotk_BlockArgs_o4v3e9_finalize(void* isolate_callback_data, void* peer) {
  _13hhotk_BlockArgs_o4v3e9* args = (__bridge _13hhotk_BlockArgs_o4v3e9*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_13hhotk_BlockArgs_o4v3e9_free, peer);
}

typedef void  (^_ListenerTrampoline_2)(void * arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _13hhotk_o4v3e9_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1) {
    _13hhotk_BlockArgs_o4v3e9* args = [[_13hhotk_BlockArgs_o4v3e9 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _13hhotk_BlockArgs_o4v3e9_finalize);
  } copy]);
}
@interface _13hhotk_BlockArgs_o4v3e9_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _13hhotk_BlockArgs_o4v3e9_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _13hhotk_BlockArgs_o4v3e9_blocking_getArg0(void* peer) {
  return ((__bridge _13hhotk_BlockArgs_o4v3e9_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _13hhotk_BlockArgs_o4v3e9_blocking_getArg1(void* peer) {
  void* val = ((__bridge _13hhotk_BlockArgs_o4v3e9_blocking*)peer)->arg1;
  ((__bridge _13hhotk_BlockArgs_o4v3e9_blocking*)peer)->arg1 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _13hhotk_BlockArgs_o4v3e9_blocking_free(void* peer) {
  @autoreleasepool {
    _13hhotk_BlockArgs_o4v3e9_blocking* args = (__bridge _13hhotk_BlockArgs_o4v3e9_blocking*)peer;
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

void _13hhotk_BlockArgs_o4v3e9_blocking_finalize(void* isolate_callback_data, void* peer) {
  _13hhotk_BlockArgs_o4v3e9_blocking* args = (__bridge _13hhotk_BlockArgs_o4v3e9_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_13hhotk_BlockArgs_o4v3e9_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_2)(void* block, void * arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _13hhotk_o4v3e9_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
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
      ((_BlockingTrampoline_2)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _13hhotk_BlockArgs_o4v3e9_blocking* args = [[_13hhotk_BlockArgs_o4v3e9_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _13hhotk_BlockArgs_o4v3e9_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_6)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _13hhotk_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_7)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _13hhotk_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((_ProtocolTrampoline_7)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _13hhotk_SecondaryProtocol(void) { return @protocol(SecondaryProtocol); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _13hhotk_UnusedProtocol(void) { return @protocol(UnusedProtocol); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
