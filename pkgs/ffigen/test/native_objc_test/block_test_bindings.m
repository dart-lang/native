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

@interface _18tji2r_BlockArgs_1cme7zu : NSObject {
  @public
  id block;
  void* context;

}
@end

@implementation _18tji2r_BlockArgs_1cme7zu
@end



void _18tji2r_BlockArgs_1cme7zu_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1cme7zu* args = (__bridge _18tji2r_BlockArgs_1cme7zu*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1cme7zu_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1cme7zu* args = (__bridge _18tji2r_BlockArgs_1cme7zu*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1cme7zu_free, peer);
}

typedef void  (^_ListenerTrampoline)(void);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1cme7zu_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void() {
    _18tji2r_BlockArgs_1cme7zu* args = [[_18tji2r_BlockArgs_1cme7zu alloc] init];
    args->block = block;
    args->context = context;
    
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1cme7zu_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_1cme7zu_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;

}
@end

@implementation _18tji2r_BlockArgs_1cme7zu_blocking
@end



__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1cme7zu_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1cme7zu_blocking* args = (__bridge _18tji2r_BlockArgs_1cme7zu_blocking*)peer;
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

void _18tji2r_BlockArgs_1cme7zu_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1cme7zu_blocking* args = (__bridge _18tji2r_BlockArgs_1cme7zu_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1cme7zu_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline)(void* block);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1cme7zu_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
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
      _18tji2r_BlockArgs_1cme7zu_blocking* args = [[_18tji2r_BlockArgs_1cme7zu_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1cme7zu_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_46g30m : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
}
@end

@implementation _18tji2r_BlockArgs_46g30m
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_46g30m_getArg0(void* peer) {
  void* val = ((__bridge _18tji2r_BlockArgs_46g30m*)peer)->arg0;
  ((__bridge _18tji2r_BlockArgs_46g30m*)peer)->arg0 = NULL;
  return val;
}


void _18tji2r_BlockArgs_46g30m_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_46g30m* args = (__bridge _18tji2r_BlockArgs_46g30m*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_46g30m_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_46g30m* args = (__bridge _18tji2r_BlockArgs_46g30m*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_46g30m_free, peer);
}

typedef void  (^_ListenerTrampoline_1)(id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_46g30m_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    _18tji2r_BlockArgs_46g30m* args = [[_18tji2r_BlockArgs_46g30m alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge_retained void*)arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_46g30m_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_46g30m_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
}
@end

@implementation _18tji2r_BlockArgs_46g30m_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_46g30m_blocking_getArg0(void* peer) {
  void* val = ((__bridge _18tji2r_BlockArgs_46g30m_blocking*)peer)->arg0;
  ((__bridge _18tji2r_BlockArgs_46g30m_blocking*)peer)->arg0 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_46g30m_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_46g30m_blocking* args = (__bridge _18tji2r_BlockArgs_46g30m_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_46g30m_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_46g30m_blocking* args = (__bridge _18tji2r_BlockArgs_46g30m_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_46g30m_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_1)(void* block, id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_46g30m_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_1)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_46g30m_blocking* args = [[_18tji2r_BlockArgs_46g30m_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge_retained void*)arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_46g30m_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_2wxtr2 : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
}
@end

@implementation _18tji2r_BlockArgs_2wxtr2
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _18tji2r_BlockArgs_2wxtr2_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_2wxtr2*)peer)->arg0;
}


void _18tji2r_BlockArgs_2wxtr2_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_2wxtr2* args = (__bridge _18tji2r_BlockArgs_2wxtr2*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_2wxtr2_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_2wxtr2* args = (__bridge _18tji2r_BlockArgs_2wxtr2*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_2wxtr2_free, peer);
}

typedef void  (^_ListenerTrampoline_2)(id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_2wxtr2_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    _18tji2r_BlockArgs_2wxtr2* args = [[_18tji2r_BlockArgs_2wxtr2 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_2wxtr2_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_2wxtr2_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
}
@end

@implementation _18tji2r_BlockArgs_2wxtr2_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _18tji2r_BlockArgs_2wxtr2_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_2wxtr2_blocking*)peer)->arg0;
}


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_2wxtr2_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_2wxtr2_blocking* args = (__bridge _18tji2r_BlockArgs_2wxtr2_blocking*)peer;
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

void _18tji2r_BlockArgs_2wxtr2_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_2wxtr2_blocking* args = (__bridge _18tji2r_BlockArgs_2wxtr2_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_2wxtr2_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_2)(void* block, id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_2wxtr2_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_2)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_2wxtr2_blocking* args = [[_18tji2r_BlockArgs_2wxtr2_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_2wxtr2_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_1huiwh : NSObject {
  @public
  id block;
  void* context;
  int32_t  arg0;
}
@end

@implementation _18tji2r_BlockArgs_1huiwh
@end

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _18tji2r_BlockArgs_1huiwh_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1huiwh*)peer)->arg0;
}


void _18tji2r_BlockArgs_1huiwh_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1huiwh* args = (__bridge _18tji2r_BlockArgs_1huiwh*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1huiwh_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1huiwh* args = (__bridge _18tji2r_BlockArgs_1huiwh*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1huiwh_free, peer);
}

typedef void  (^_ListenerTrampoline_3)(int32_t arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1huiwh_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(int32_t arg0) {
    _18tji2r_BlockArgs_1huiwh* args = [[_18tji2r_BlockArgs_1huiwh alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1huiwh_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_1huiwh_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  int32_t  arg0;
}
@end

@implementation _18tji2r_BlockArgs_1huiwh_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
int32_t  _18tji2r_BlockArgs_1huiwh_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_1huiwh_blocking*)peer)->arg0;
}


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1huiwh_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1huiwh_blocking* args = (__bridge _18tji2r_BlockArgs_1huiwh_blocking*)peer;
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

void _18tji2r_BlockArgs_1huiwh_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1huiwh_blocking* args = (__bridge _18tji2r_BlockArgs_1huiwh_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1huiwh_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_3)(void* block, int32_t arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1huiwh_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
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
      ((_BlockingTrampoline_3)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_1huiwh_blocking* args = [[_18tji2r_BlockArgs_1huiwh_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1huiwh_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_l0gbcx : NSObject {
  @public
  id block;
  void* context;
  int32_t *  arg0;
}
@end

@implementation _18tji2r_BlockArgs_l0gbcx
@end

__attribute__((visibility("default"))) __attribute__((used))
int32_t *  _18tji2r_BlockArgs_l0gbcx_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_l0gbcx*)peer)->arg0;
}


void _18tji2r_BlockArgs_l0gbcx_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_l0gbcx* args = (__bridge _18tji2r_BlockArgs_l0gbcx*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_l0gbcx_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_l0gbcx* args = (__bridge _18tji2r_BlockArgs_l0gbcx*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_l0gbcx_free, peer);
}

typedef void  (^_ListenerTrampoline_4)(int32_t * arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_l0gbcx_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(int32_t * arg0) {
    _18tji2r_BlockArgs_l0gbcx* args = [[_18tji2r_BlockArgs_l0gbcx alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_l0gbcx_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_l0gbcx_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  int32_t *  arg0;
}
@end

@implementation _18tji2r_BlockArgs_l0gbcx_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
int32_t *  _18tji2r_BlockArgs_l0gbcx_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_l0gbcx_blocking*)peer)->arg0;
}


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_l0gbcx_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_l0gbcx_blocking* args = (__bridge _18tji2r_BlockArgs_l0gbcx_blocking*)peer;
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

void _18tji2r_BlockArgs_l0gbcx_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_l0gbcx_blocking* args = (__bridge _18tji2r_BlockArgs_l0gbcx_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_l0gbcx_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_4)(void* block, int32_t * arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_l0gbcx_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(int32_t * arg0) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_4)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_l0gbcx_blocking* args = [[_18tji2r_BlockArgs_l0gbcx_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_l0gbcx_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_1kn896c : NSObject {
  @public
  id block;
  void* context;
  int32_t  arg0;
  Vec4  arg1;
  char *  arg2;
}
@end

@implementation _18tji2r_BlockArgs_1kn896c
@end

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
  @autoreleasepool {
    _18tji2r_BlockArgs_1kn896c* args = (__bridge _18tji2r_BlockArgs_1kn896c*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1kn896c_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1kn896c* args = (__bridge _18tji2r_BlockArgs_1kn896c*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1kn896c_free, peer);
}

typedef void  (^_ListenerTrampoline_5)(int32_t arg0, Vec4 arg1, char * arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1kn896c_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(int32_t arg0, Vec4 arg1, char * arg2) {
    _18tji2r_BlockArgs_1kn896c* args = [[_18tji2r_BlockArgs_1kn896c alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1kn896c_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_1kn896c_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  int32_t  arg0;
  Vec4  arg1;
  char *  arg2;
}
@end

@implementation _18tji2r_BlockArgs_1kn896c_blocking
@end

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


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1kn896c_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1kn896c_blocking* args = (__bridge _18tji2r_BlockArgs_1kn896c_blocking*)peer;
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

void _18tji2r_BlockArgs_1kn896c_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1kn896c_blocking* args = (__bridge _18tji2r_BlockArgs_1kn896c_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1kn896c_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_5)(void* block, int32_t arg0, Vec4 arg1, char * arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1kn896c_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(int32_t arg0, Vec4 arg1, char * arg2) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_5)block)((__bridge void*)block, arg0, arg1, arg2);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_1kn896c_blocking* args = [[_18tji2r_BlockArgs_1kn896c_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      args->arg2 = arg2;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1kn896c_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_1xjdmo1 : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
}
@end

@implementation _18tji2r_BlockArgs_1xjdmo1
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1xjdmo1_getArg0(void* peer) {
  void* val = ((__bridge _18tji2r_BlockArgs_1xjdmo1*)peer)->arg0;
  ((__bridge _18tji2r_BlockArgs_1xjdmo1*)peer)->arg0 = NULL;
  return val;
}


void _18tji2r_BlockArgs_1xjdmo1_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1xjdmo1* args = (__bridge _18tji2r_BlockArgs_1xjdmo1*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1xjdmo1_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1xjdmo1* args = (__bridge _18tji2r_BlockArgs_1xjdmo1*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1xjdmo1_free, peer);
}

typedef void  (^_ListenerTrampoline_6)(id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1xjdmo1_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    _18tji2r_BlockArgs_1xjdmo1* args = [[_18tji2r_BlockArgs_1xjdmo1 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge void*)objc_retainBlock(arg0);
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1xjdmo1_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_1xjdmo1_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
}
@end

@implementation _18tji2r_BlockArgs_1xjdmo1_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1xjdmo1_blocking_getArg0(void* peer) {
  void* val = ((__bridge _18tji2r_BlockArgs_1xjdmo1_blocking*)peer)->arg0;
  ((__bridge _18tji2r_BlockArgs_1xjdmo1_blocking*)peer)->arg0 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1xjdmo1_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1xjdmo1_blocking* args = (__bridge _18tji2r_BlockArgs_1xjdmo1_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1xjdmo1_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1xjdmo1_blocking* args = (__bridge _18tji2r_BlockArgs_1xjdmo1_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1xjdmo1_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_6)(void* block, id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1xjdmo1_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_6)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_1xjdmo1_blocking* args = [[_18tji2r_BlockArgs_1xjdmo1_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge void*)objc_retainBlock(arg0);
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1xjdmo1_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_1nfopnd : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
}
@end

@implementation _18tji2r_BlockArgs_1nfopnd
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1nfopnd_getArg0(void* peer) {
  void* val = ((__bridge _18tji2r_BlockArgs_1nfopnd*)peer)->arg0;
  ((__bridge _18tji2r_BlockArgs_1nfopnd*)peer)->arg0 = NULL;
  return val;
}


void _18tji2r_BlockArgs_1nfopnd_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1nfopnd* args = (__bridge _18tji2r_BlockArgs_1nfopnd*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1nfopnd_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1nfopnd* args = (__bridge _18tji2r_BlockArgs_1nfopnd*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1nfopnd_free, peer);
}

typedef void  (^_ListenerTrampoline_7)(id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1nfopnd_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    _18tji2r_BlockArgs_1nfopnd* args = [[_18tji2r_BlockArgs_1nfopnd alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge_retained void*)arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1nfopnd_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_1nfopnd_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
}
@end

@implementation _18tji2r_BlockArgs_1nfopnd_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_BlockArgs_1nfopnd_blocking_getArg0(void* peer) {
  void* val = ((__bridge _18tji2r_BlockArgs_1nfopnd_blocking*)peer)->arg0;
  ((__bridge _18tji2r_BlockArgs_1nfopnd_blocking*)peer)->arg0 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1nfopnd_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1nfopnd_blocking* args = (__bridge _18tji2r_BlockArgs_1nfopnd_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1nfopnd_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1nfopnd_blocking* args = (__bridge _18tji2r_BlockArgs_1nfopnd_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1nfopnd_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_7)(void* block, id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1nfopnd_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_7)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_1nfopnd_blocking* args = [[_18tji2r_BlockArgs_1nfopnd_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge_retained void*)arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1nfopnd_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_1uznk83 : NSObject {
  @public
  id block;
  void* context;
  struct Vec2  arg0;
  Vec4  arg1;
  void* arg2;
}
@end

@implementation _18tji2r_BlockArgs_1uznk83
@end

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
  void* val = ((__bridge _18tji2r_BlockArgs_1uznk83*)peer)->arg2;
  ((__bridge _18tji2r_BlockArgs_1uznk83*)peer)->arg2 = NULL;
  return val;
}


void _18tji2r_BlockArgs_1uznk83_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1uznk83* args = (__bridge _18tji2r_BlockArgs_1uznk83*)peer;
    if (args->arg2 != NULL) { id relObj = (__bridge_transfer id)args->arg2; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1uznk83_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1uznk83* args = (__bridge _18tji2r_BlockArgs_1uznk83*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1uznk83_free, peer);
}

typedef void  (^_ListenerTrampoline_8)(struct Vec2 arg0, Vec4 arg1, id arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1uznk83_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(struct Vec2 arg0, Vec4 arg1, id arg2) {
    _18tji2r_BlockArgs_1uznk83* args = [[_18tji2r_BlockArgs_1uznk83 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = (__bridge_retained void*)arg2;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1uznk83_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_1uznk83_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  struct Vec2  arg0;
  Vec4  arg1;
  void* arg2;
}
@end

@implementation _18tji2r_BlockArgs_1uznk83_blocking
@end

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
  void* val = ((__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer)->arg2;
  ((__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer)->arg2 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_1uznk83_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_1uznk83_blocking* args = (__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg2 != NULL) { id relObj = (__bridge_transfer id)args->arg2; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_1uznk83_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_1uznk83_blocking* args = (__bridge _18tji2r_BlockArgs_1uznk83_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_1uznk83_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_8)(void* block, struct Vec2 arg0, Vec4 arg1, id arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_1uznk83_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(struct Vec2 arg0, Vec4 arg1, id arg2) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_8)block)((__bridge void*)block, arg0, arg1, arg2);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_1uznk83_blocking* args = [[_18tji2r_BlockArgs_1uznk83_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      args->arg2 = (__bridge_retained void*)arg2;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_1uznk83_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _18tji2r_BlockArgs_124zeca : NSObject {
  @public
  id block;
  void* context;
  struct objc_selector *  arg0;
}
@end

@implementation _18tji2r_BlockArgs_124zeca
@end

__attribute__((visibility("default"))) __attribute__((used))
struct objc_selector *  _18tji2r_BlockArgs_124zeca_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_124zeca*)peer)->arg0;
}


void _18tji2r_BlockArgs_124zeca_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_124zeca* args = (__bridge _18tji2r_BlockArgs_124zeca*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _18tji2r_BlockArgs_124zeca_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_124zeca* args = (__bridge _18tji2r_BlockArgs_124zeca*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_124zeca_free, peer);
}

typedef void  (^_ListenerTrampoline_9)(struct objc_selector * arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_124zeca_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(struct objc_selector * arg0) {
    _18tji2r_BlockArgs_124zeca* args = [[_18tji2r_BlockArgs_124zeca alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_124zeca_finalize);
  } copy]);
}
@interface _18tji2r_BlockArgs_124zeca_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  struct objc_selector *  arg0;
}
@end

@implementation _18tji2r_BlockArgs_124zeca_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
struct objc_selector *  _18tji2r_BlockArgs_124zeca_blocking_getArg0(void* peer) {
  return ((__bridge _18tji2r_BlockArgs_124zeca_blocking*)peer)->arg0;
}


__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_BlockArgs_124zeca_blocking_free(void* peer) {
  @autoreleasepool {
    _18tji2r_BlockArgs_124zeca_blocking* args = (__bridge _18tji2r_BlockArgs_124zeca_blocking*)peer;
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

void _18tji2r_BlockArgs_124zeca_blocking_finalize(void* isolate_callback_data, void* peer) {
  _18tji2r_BlockArgs_124zeca_blocking* args = (__bridge _18tji2r_BlockArgs_124zeca_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_18tji2r_BlockArgs_124zeca_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_9)(void* block, struct objc_selector * arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _18tji2r_124zeca_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(struct objc_selector * arg0) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_9)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _18tji2r_BlockArgs_124zeca_blocking* args = [[_18tji2r_BlockArgs_124zeca_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _18tji2r_BlockArgs_124zeca_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
