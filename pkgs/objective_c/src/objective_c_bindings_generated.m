#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "foundation.h"
#import "input_stream_adapter.h"
#import "ns_number.h"
#import "observer.h"
#import "protocol.h"

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
Protocol* _1wx624s_NSCoding(void) { return @protocol(NSCoding); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSCopying(void) { return @protocol(NSCopying); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSFastEnumeration(void) { return @protocol(NSFastEnumeration); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSItemProviderReading(void) { return @protocol(NSItemProviderReading); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSItemProviderWriting(void) { return @protocol(NSItemProviderWriting); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSMutableCopying(void) { return @protocol(NSMutableCopying); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSObject(void) { return @protocol(NSObject); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSPortDelegate(void) { return @protocol(NSPortDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSSecureCoding(void) { return @protocol(NSSecureCoding); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_NSStreamDelegate(void) { return @protocol(NSStreamDelegate); }

typedef id  (^_ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((_ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef NSItemProviderRepresentationVisibility  (^_ProtocolTrampoline_1)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
NSItemProviderRepresentationVisibility  _1wx624s_protocolTrampoline_1ldqghh(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_2)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_1q0i84(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef unsigned long  (^_ProtocolTrampoline_3)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_protocolTrampoline_1ckyi24(id target, void * sel) {
  return ((_ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef unsigned long  (^_ProtocolTrampoline_4)(void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_protocolTrampoline_17ap02x(id target, void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef struct _NSZone *  (^_ProtocolTrampoline_5)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct _NSZone *  _1wx624s_protocolTrampoline_1a8cl66(id target, void * sel) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_6)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx624s_protocolTrampoline_e3qsqz(id target, void * sel) {
  return ((_ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_7)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx624s_protocolTrampoline_3su7tt(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_7)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^_ProtocolTrampoline_8)(void * sel, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx624s_protocolTrampoline_w1e3k0(id target, void * sel, struct objc_selector * arg1) {
  return ((_ProtocolTrampoline_8)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
@interface _1wx624s_BlockArgs_1cme7zu : NSObject {
  @public
  id block;
  void* context;

}
@end

@implementation _1wx624s_BlockArgs_1cme7zu
@end



void _1wx624s_BlockArgs_1cme7zu_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1cme7zu* args = (__bridge _1wx624s_BlockArgs_1cme7zu*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1cme7zu_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1cme7zu* args = (__bridge _1wx624s_BlockArgs_1cme7zu*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1cme7zu_free, peer);
}

typedef void  (^_ListenerTrampoline)(void);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1cme7zu_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void() {
    _1wx624s_BlockArgs_1cme7zu* args = [[_1wx624s_BlockArgs_1cme7zu alloc] init];
    args->block = block;
    args->context = context;
    
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1cme7zu_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1cme7zu_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;

}
@end

@implementation _1wx624s_BlockArgs_1cme7zu_blocking
@end



__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1cme7zu_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1cme7zu_blocking* args = (__bridge _1wx624s_BlockArgs_1cme7zu_blocking*)peer;
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

void _1wx624s_BlockArgs_1cme7zu_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1cme7zu_blocking* args = (__bridge _1wx624s_BlockArgs_1cme7zu_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1cme7zu_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline)(void* block);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1cme7zu_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
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
      _1wx624s_BlockArgs_1cme7zu_blocking* args = [[_1wx624s_BlockArgs_1cme7zu_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1cme7zu_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_tbq8wd : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
  void* arg1;
  BOOL *  arg2;
}
@end

@implementation _1wx624s_BlockArgs_tbq8wd
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->arg1 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_tbq8wd_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->arg2;
}


void _1wx624s_BlockArgs_tbq8wd_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_tbq8wd* args = (__bridge _1wx624s_BlockArgs_tbq8wd*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_tbq8wd_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_tbq8wd* args = (__bridge _1wx624s_BlockArgs_tbq8wd*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_tbq8wd_free, peer);
}

typedef void  (^_ListenerTrampoline_1)(id arg0, id arg1, BOOL * arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_tbq8wd_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1, BOOL * arg2) {
    _1wx624s_BlockArgs_tbq8wd* args = [[_1wx624s_BlockArgs_tbq8wd alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge_retained void*)arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    args->arg2 = arg2;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_tbq8wd_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_tbq8wd_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
  void* arg1;
  BOOL *  arg2;
}
@end

@implementation _1wx624s_BlockArgs_tbq8wd_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_blocking_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_blocking_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->arg1 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_tbq8wd_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->arg2;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_tbq8wd_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_tbq8wd_blocking* args = (__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_tbq8wd_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_tbq8wd_blocking* args = (__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_tbq8wd_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_1)(void* block, id arg0, id arg1, BOOL * arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_tbq8wd_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1, BOOL * arg2) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_1)block)((__bridge void*)block, arg0, arg1, arg2);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_tbq8wd_blocking* args = [[_1wx624s_BlockArgs_tbq8wd_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge_retained void*)arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      args->arg2 = arg2;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_tbq8wd_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_1ilrkog : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1ilrkog
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1ilrkog_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1ilrkog*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1ilrkog_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1ilrkog*)peer)->arg1;
}


void _1wx624s_BlockArgs_1ilrkog_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1ilrkog* args = (__bridge _1wx624s_BlockArgs_1ilrkog*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1ilrkog_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1ilrkog* args = (__bridge _1wx624s_BlockArgs_1ilrkog*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1ilrkog_free, peer);
}

typedef void  (^_ListenerTrampoline_2)(id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1ilrkog_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    _1wx624s_BlockArgs_1ilrkog* args = [[_1wx624s_BlockArgs_1ilrkog alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1ilrkog_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1ilrkog_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1ilrkog_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1ilrkog_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1ilrkog_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1ilrkog_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1ilrkog_blocking* args = (__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer;
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

void _1wx624s_BlockArgs_1ilrkog_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1ilrkog_blocking* args = (__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1ilrkog_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_2)(void* block, id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1ilrkog_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
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
      _1wx624s_BlockArgs_1ilrkog_blocking* args = [[_1wx624s_BlockArgs_1ilrkog_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1ilrkog_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_dgl1yu : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
  void* arg1;
  void* arg2;
}
@end

@implementation _1wx624s_BlockArgs_dgl1yu
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg1 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_getArg2(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg2;
  ((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg2 = NULL;
  return val;
}


void _1wx624s_BlockArgs_dgl1yu_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_dgl1yu* args = (__bridge _1wx624s_BlockArgs_dgl1yu*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    if (args->arg2 != NULL) { id relObj = (__bridge_transfer id)args->arg2; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_dgl1yu_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_dgl1yu* args = (__bridge _1wx624s_BlockArgs_dgl1yu*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_dgl1yu_free, peer);
}

typedef void  (^_ListenerTrampoline_3)(id arg0, id arg1, id arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_dgl1yu_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1, id arg2) {
    _1wx624s_BlockArgs_dgl1yu* args = [[_1wx624s_BlockArgs_dgl1yu alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge void*)objc_retainBlock(arg0);
    args->arg1 = (__bridge_retained void*)arg1;
    args->arg2 = (__bridge_retained void*)arg2;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_dgl1yu_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_dgl1yu_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
  void* arg1;
  void* arg2;
}
@end

@implementation _1wx624s_BlockArgs_dgl1yu_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_blocking_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_blocking_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg1 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_blocking_getArg2(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg2;
  ((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg2 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_dgl1yu_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_dgl1yu_blocking* args = (__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    if (args->arg2 != NULL) { id relObj = (__bridge_transfer id)args->arg2; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_dgl1yu_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_dgl1yu_blocking* args = (__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_dgl1yu_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_3)(void* block, id arg0, id arg1, id arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_dgl1yu_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1, id arg2) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_3)block)((__bridge void*)block, arg0, arg1, arg2);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_dgl1yu_blocking* args = [[_1wx624s_BlockArgs_dgl1yu_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge void*)objc_retainBlock(arg0);
      args->arg1 = (__bridge_retained void*)arg1;
      args->arg2 = (__bridge_retained void*)arg2;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_dgl1yu_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_meh2de : NSObject {
  @public
  id block;
  void* context;
  struct _NSRange  arg0;
  BOOL *  arg1;
}
@end

@implementation _1wx624s_BlockArgs_meh2de
@end

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_meh2de_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_meh2de*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_meh2de_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_meh2de*)peer)->arg1;
}


void _1wx624s_BlockArgs_meh2de_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_meh2de* args = (__bridge _1wx624s_BlockArgs_meh2de*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_meh2de_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_meh2de* args = (__bridge _1wx624s_BlockArgs_meh2de*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_meh2de_free, peer);
}

typedef void  (^_ListenerTrampoline_4)(struct _NSRange arg0, BOOL * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_meh2de_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(struct _NSRange arg0, BOOL * arg1) {
    _1wx624s_BlockArgs_meh2de* args = [[_1wx624s_BlockArgs_meh2de alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_meh2de_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_meh2de_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  struct _NSRange  arg0;
  BOOL *  arg1;
}
@end

@implementation _1wx624s_BlockArgs_meh2de_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_meh2de_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_meh2de_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_meh2de_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_meh2de_blocking* args = (__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer;
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

void _1wx624s_BlockArgs_meh2de_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_meh2de_blocking* args = (__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_meh2de_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_4)(void* block, struct _NSRange arg0, BOOL * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_meh2de_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(struct _NSRange arg0, BOOL * arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_4)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_meh2de_blocking* args = [[_1wx624s_BlockArgs_meh2de_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_meh2de_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_1r0pv4q : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
  struct _NSRange  arg1;
  struct _NSRange  arg2;
  BOOL *  arg3;
}
@end

@implementation _1wx624s_BlockArgs_1r0pv4q
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1r0pv4q_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1r0pv4q*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_1r0pv4q_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1r0pv4q*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_1r0pv4q_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1r0pv4q*)peer)->arg2;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_1r0pv4q_getArg3(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1r0pv4q*)peer)->arg3;
}


void _1wx624s_BlockArgs_1r0pv4q_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1r0pv4q* args = (__bridge _1wx624s_BlockArgs_1r0pv4q*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1r0pv4q_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1r0pv4q* args = (__bridge _1wx624s_BlockArgs_1r0pv4q*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1r0pv4q_free, peer);
}

typedef void  (^_ListenerTrampoline_5)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1r0pv4q_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    _1wx624s_BlockArgs_1r0pv4q* args = [[_1wx624s_BlockArgs_1r0pv4q alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    args->arg3 = arg3;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1r0pv4q_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1r0pv4q_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
  struct _NSRange  arg1;
  struct _NSRange  arg2;
  BOOL *  arg3;
}
@end

@implementation _1wx624s_BlockArgs_1r0pv4q_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1r0pv4q_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_1r0pv4q_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_1r0pv4q_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer)->arg2;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_1r0pv4q_blocking_getArg3(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer)->arg3;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1r0pv4q_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1r0pv4q_blocking* args = (__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer;
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

void _1wx624s_BlockArgs_1r0pv4q_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1r0pv4q_blocking* args = (__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1r0pv4q_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_5)(void* block, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1r0pv4q_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_5)block)((__bridge void*)block, arg0, arg1, arg2, arg3);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1r0pv4q_blocking* args = [[_1wx624s_BlockArgs_1r0pv4q_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      args->arg2 = arg2;
      args->arg3 = arg3;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1r0pv4q_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_v348wu : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
  BOOL *  arg1;
}
@end

@implementation _1wx624s_BlockArgs_v348wu
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_v348wu_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_v348wu*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_v348wu*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_v348wu_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_v348wu*)peer)->arg1;
}


void _1wx624s_BlockArgs_v348wu_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_v348wu* args = (__bridge _1wx624s_BlockArgs_v348wu*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_v348wu_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_v348wu* args = (__bridge _1wx624s_BlockArgs_v348wu*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_v348wu_free, peer);
}

typedef void  (^_ListenerTrampoline_6)(id arg0, BOOL * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_v348wu_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, BOOL * arg1) {
    _1wx624s_BlockArgs_v348wu* args = [[_1wx624s_BlockArgs_v348wu alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge_retained void*)arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_v348wu_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_v348wu_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
  BOOL *  arg1;
}
@end

@implementation _1wx624s_BlockArgs_v348wu_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_v348wu_blocking_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_v348wu_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_v348wu_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_v348wu_blocking* args = (__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer;
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

void _1wx624s_BlockArgs_v348wu_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_v348wu_blocking* args = (__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_v348wu_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_6)(void* block, id arg0, BOOL * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_v348wu_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, BOOL * arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_6)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_v348wu_blocking* args = [[_1wx624s_BlockArgs_v348wu_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge_retained void*)arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_v348wu_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_1yuig1 : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
}
@end

@implementation _1wx624s_BlockArgs_1yuig1
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1yuig1_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_1yuig1*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_1yuig1*)peer)->arg0 = NULL;
  return val;
}


void _1wx624s_BlockArgs_1yuig1_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1yuig1* args = (__bridge _1wx624s_BlockArgs_1yuig1*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1yuig1_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1yuig1* args = (__bridge _1wx624s_BlockArgs_1yuig1*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1yuig1_free, peer);
}

typedef void  (^_ListenerTrampoline_7)(id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1yuig1_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0) {
    _1wx624s_BlockArgs_1yuig1* args = [[_1wx624s_BlockArgs_1yuig1 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge_retained void*)arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1yuig1_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1yuig1_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
}
@end

@implementation _1wx624s_BlockArgs_1yuig1_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1yuig1_blocking_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_1yuig1_blocking*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_1yuig1_blocking*)peer)->arg0 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1yuig1_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1yuig1_blocking* args = (__bridge _1wx624s_BlockArgs_1yuig1_blocking*)peer;
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

void _1wx624s_BlockArgs_1yuig1_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1yuig1_blocking* args = (__bridge _1wx624s_BlockArgs_1yuig1_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1yuig1_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_7)(void* block, id arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1yuig1_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
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
      _1wx624s_BlockArgs_1yuig1_blocking* args = [[_1wx624s_BlockArgs_1yuig1_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge_retained void*)arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1yuig1_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_1dzsfqo : NSObject {
  @public
  id block;
  void* context;
  unsigned long  arg0;
  BOOL *  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1dzsfqo
@end

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_1dzsfqo_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1dzsfqo*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_1dzsfqo_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1dzsfqo*)peer)->arg1;
}


void _1wx624s_BlockArgs_1dzsfqo_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1dzsfqo* args = (__bridge _1wx624s_BlockArgs_1dzsfqo*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1dzsfqo_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1dzsfqo* args = (__bridge _1wx624s_BlockArgs_1dzsfqo*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1dzsfqo_free, peer);
}

typedef void  (^_ListenerTrampoline_8)(unsigned long arg0, BOOL * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1dzsfqo_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(unsigned long arg0, BOOL * arg1) {
    _1wx624s_BlockArgs_1dzsfqo* args = [[_1wx624s_BlockArgs_1dzsfqo alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1dzsfqo_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1dzsfqo_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  unsigned long  arg0;
  BOOL *  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1dzsfqo_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_1dzsfqo_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_1dzsfqo_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1dzsfqo_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1dzsfqo_blocking* args = (__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer;
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

void _1wx624s_BlockArgs_1dzsfqo_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1dzsfqo_blocking* args = (__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1dzsfqo_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_8)(void* block, unsigned long arg0, BOOL * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1dzsfqo_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(unsigned long arg0, BOOL * arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_8)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1dzsfqo_blocking* args = [[_1wx624s_BlockArgs_1dzsfqo_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1dzsfqo_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_1wa2b1l : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1wa2b1l
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1wa2b1l_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1wa2b1l*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1wa2b1l_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1wa2b1l*)peer)->arg1;
}


void _1wx624s_BlockArgs_1wa2b1l_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1wa2b1l* args = (__bridge _1wx624s_BlockArgs_1wa2b1l*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1wa2b1l_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1wa2b1l* args = (__bridge _1wx624s_BlockArgs_1wa2b1l*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1wa2b1l_free, peer);
}

typedef void  (^_ListenerTrampoline_9)(id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1wa2b1l_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    _1wx624s_BlockArgs_1wa2b1l* args = [[_1wx624s_BlockArgs_1wa2b1l alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1wa2b1l_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1wa2b1l_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1wa2b1l_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1wa2b1l_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1wa2b1l_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1wa2b1l_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1wa2b1l_blocking* args = (__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer;
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

void _1wx624s_BlockArgs_1wa2b1l_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1wa2b1l_blocking* args = (__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1wa2b1l_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_9)(void* block, id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1wa2b1l_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_9)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1wa2b1l_blocking* args = [[_1wx624s_BlockArgs_1wa2b1l_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1wa2b1l_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_jnk8ia : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
  BOOL  arg1;
  id  arg2;
}
@end

@implementation _1wx624s_BlockArgs_jnk8ia
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_jnk8ia_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_jnk8ia*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx624s_BlockArgs_jnk8ia_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_jnk8ia*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_jnk8ia_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_jnk8ia*)peer)->arg2;
}


void _1wx624s_BlockArgs_jnk8ia_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_jnk8ia* args = (__bridge _1wx624s_BlockArgs_jnk8ia*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_jnk8ia_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_jnk8ia* args = (__bridge _1wx624s_BlockArgs_jnk8ia*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_jnk8ia_free, peer);
}

typedef void  (^_ListenerTrampoline_10)(id arg0, BOOL arg1, id arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_jnk8ia_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, BOOL arg1, id arg2) {
    _1wx624s_BlockArgs_jnk8ia* args = [[_1wx624s_BlockArgs_jnk8ia alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_jnk8ia_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_jnk8ia_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
  BOOL  arg1;
  id  arg2;
}
@end

@implementation _1wx624s_BlockArgs_jnk8ia_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_jnk8ia_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_jnk8ia_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx624s_BlockArgs_jnk8ia_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_jnk8ia_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_jnk8ia_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_jnk8ia_blocking*)peer)->arg2;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_jnk8ia_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_jnk8ia_blocking* args = (__bridge _1wx624s_BlockArgs_jnk8ia_blocking*)peer;
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

void _1wx624s_BlockArgs_jnk8ia_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_jnk8ia_blocking* args = (__bridge _1wx624s_BlockArgs_jnk8ia_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_jnk8ia_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_10)(void* block, id arg0, BOOL arg1, id arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_jnk8ia_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, BOOL arg1, id arg2) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_10)block)((__bridge void*)block, arg0, arg1, arg2);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_jnk8ia_blocking* args = [[_1wx624s_BlockArgs_jnk8ia_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      args->arg2 = arg2;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_jnk8ia_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_borsj5 : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
  BOOL *  arg1;
}
@end

@implementation _1wx624s_BlockArgs_borsj5
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_borsj5_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_borsj5*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_borsj5*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_borsj5_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_borsj5*)peer)->arg1;
}


void _1wx624s_BlockArgs_borsj5_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_borsj5* args = (__bridge _1wx624s_BlockArgs_borsj5*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_borsj5_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_borsj5* args = (__bridge _1wx624s_BlockArgs_borsj5*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_borsj5_free, peer);
}

typedef void  (^_ListenerTrampoline_11)(id arg0, BOOL * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_borsj5_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, BOOL * arg1) {
    _1wx624s_BlockArgs_borsj5* args = [[_1wx624s_BlockArgs_borsj5 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge_retained void*)arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_borsj5_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_borsj5_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
  BOOL *  arg1;
}
@end

@implementation _1wx624s_BlockArgs_borsj5_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_borsj5_blocking_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_borsj5_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_borsj5_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_borsj5_blocking* args = (__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer;
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

void _1wx624s_BlockArgs_borsj5_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_borsj5_blocking* args = (__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_borsj5_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_11)(void* block, id arg0, BOOL * arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_borsj5_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, BOOL * arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_11)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_borsj5_blocking* args = [[_1wx624s_BlockArgs_borsj5_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge_retained void*)arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_borsj5_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_448250 : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
}
@end

@implementation _1wx624s_BlockArgs_448250
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_448250_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_448250*)peer)->arg0;
}


void _1wx624s_BlockArgs_448250_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_448250* args = (__bridge _1wx624s_BlockArgs_448250*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_448250_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_448250* args = (__bridge _1wx624s_BlockArgs_448250*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_448250_free, peer);
}

typedef void  (^_ListenerTrampoline_12)(void * arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_448250_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0) {
    _1wx624s_BlockArgs_448250* args = [[_1wx624s_BlockArgs_448250 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_448250_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_448250_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
}
@end

@implementation _1wx624s_BlockArgs_448250_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_448250_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_448250_blocking*)peer)->arg0;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_448250_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_448250_blocking* args = (__bridge _1wx624s_BlockArgs_448250_blocking*)peer;
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

void _1wx624s_BlockArgs_448250_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_448250_blocking* args = (__bridge _1wx624s_BlockArgs_448250_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_448250_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_12)(void* block, void * arg0);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_448250_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_12)block)((__bridge void*)block, arg0);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_448250_blocking* args = [[_1wx624s_BlockArgs_448250_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_448250_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_9)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((_ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}
@interface _1wx624s_BlockArgs_1vi0sov : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _1wx624s_BlockArgs_1vi0sov
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1vi0sov_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1vi0sov*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1vi0sov_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_1vi0sov*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_1vi0sov*)peer)->arg1 = NULL;
  return val;
}


void _1wx624s_BlockArgs_1vi0sov_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1vi0sov* args = (__bridge _1wx624s_BlockArgs_1vi0sov*)peer;
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1vi0sov_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1vi0sov* args = (__bridge _1wx624s_BlockArgs_1vi0sov*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1vi0sov_free, peer);
}

typedef void  (^_ListenerTrampoline_13)(void * arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1vi0sov_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1) {
    _1wx624s_BlockArgs_1vi0sov* args = [[_1wx624s_BlockArgs_1vi0sov alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1vi0sov_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1vi0sov_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _1wx624s_BlockArgs_1vi0sov_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1vi0sov_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1vi0sov_blocking_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer)->arg1 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1vi0sov_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1vi0sov_blocking* args = (__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1vi0sov_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1vi0sov_blocking* args = (__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1vi0sov_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_13)(void* block, void * arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1vi0sov_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
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
      ((_BlockingTrampoline_13)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1vi0sov_blocking* args = [[_1wx624s_BlockArgs_1vi0sov_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1vi0sov_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_10)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
@interface _1wx624s_BlockArgs_1mmoiyc : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _1wx624s_BlockArgs_1mmoiyc
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1mmoiyc_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1mmoiyc*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1mmoiyc_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_1mmoiyc*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_1mmoiyc*)peer)->arg1 = NULL;
  return val;
}


void _1wx624s_BlockArgs_1mmoiyc_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1mmoiyc* args = (__bridge _1wx624s_BlockArgs_1mmoiyc*)peer;
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1mmoiyc_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1mmoiyc* args = (__bridge _1wx624s_BlockArgs_1mmoiyc*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1mmoiyc_free, peer);
}

typedef void  (^_ListenerTrampoline_14)(void * arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1mmoiyc_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1) {
    _1wx624s_BlockArgs_1mmoiyc* args = [[_1wx624s_BlockArgs_1mmoiyc alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1mmoiyc_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1mmoiyc_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  void* arg1;
}
@end

@implementation _1wx624s_BlockArgs_1mmoiyc_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1mmoiyc_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1mmoiyc_blocking_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer)->arg1 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1mmoiyc_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1mmoiyc_blocking* args = (__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1mmoiyc_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1mmoiyc_blocking* args = (__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1mmoiyc_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_14)(void* block, void * arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1mmoiyc_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
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
      ((_BlockingTrampoline_14)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1mmoiyc_blocking* args = [[_1wx624s_BlockArgs_1mmoiyc_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1mmoiyc_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_1yt1g7s : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  struct _NSRange  arg1;
  BOOL *  arg2;
}
@end

@implementation _1wx624s_BlockArgs_1yt1g7s
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1yt1g7s_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1yt1g7s*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_1yt1g7s_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1yt1g7s*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_1yt1g7s_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1yt1g7s*)peer)->arg2;
}


void _1wx624s_BlockArgs_1yt1g7s_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1yt1g7s* args = (__bridge _1wx624s_BlockArgs_1yt1g7s*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1yt1g7s_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1yt1g7s* args = (__bridge _1wx624s_BlockArgs_1yt1g7s*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1yt1g7s_free, peer);
}

typedef void  (^_ListenerTrampoline_15)(void * arg0, struct _NSRange arg1, BOOL * arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1yt1g7s_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, struct _NSRange arg1, BOOL * arg2) {
    _1wx624s_BlockArgs_1yt1g7s* args = [[_1wx624s_BlockArgs_1yt1g7s alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1yt1g7s_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1yt1g7s_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  struct _NSRange  arg1;
  BOOL *  arg2;
}
@end

@implementation _1wx624s_BlockArgs_1yt1g7s_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1yt1g7s_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1yt1g7s_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_1yt1g7s_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1yt1g7s_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_1yt1g7s_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1yt1g7s_blocking*)peer)->arg2;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1yt1g7s_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1yt1g7s_blocking* args = (__bridge _1wx624s_BlockArgs_1yt1g7s_blocking*)peer;
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

void _1wx624s_BlockArgs_1yt1g7s_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1yt1g7s_blocking* args = (__bridge _1wx624s_BlockArgs_1yt1g7s_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1yt1g7s_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_15)(void* block, void * arg0, struct _NSRange arg1, BOOL * arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1yt1g7s_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0, struct _NSRange arg1, BOOL * arg2) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_15)block)((__bridge void*)block, arg0, arg1, arg2);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1yt1g7s_blocking* args = [[_1wx624s_BlockArgs_1yt1g7s_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      args->arg2 = arg2;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1yt1g7s_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_n9asv4 : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  void* arg1;
  NSStreamEvent  arg2;
}
@end

@implementation _1wx624s_BlockArgs_n9asv4
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_n9asv4_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_n9asv4*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_n9asv4_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_n9asv4*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_n9asv4*)peer)->arg1 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
NSStreamEvent  _1wx624s_BlockArgs_n9asv4_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_n9asv4*)peer)->arg2;
}


void _1wx624s_BlockArgs_n9asv4_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_n9asv4* args = (__bridge _1wx624s_BlockArgs_n9asv4*)peer;
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_n9asv4_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_n9asv4* args = (__bridge _1wx624s_BlockArgs_n9asv4*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_n9asv4_free, peer);
}

typedef void  (^_ListenerTrampoline_16)(void * arg0, id arg1, NSStreamEvent arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_n9asv4_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1, NSStreamEvent arg2) {
    _1wx624s_BlockArgs_n9asv4* args = [[_1wx624s_BlockArgs_n9asv4 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    args->arg2 = arg2;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_n9asv4_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_n9asv4_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  void* arg1;
  NSStreamEvent  arg2;
}
@end

@implementation _1wx624s_BlockArgs_n9asv4_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_n9asv4_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_n9asv4_blocking_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer)->arg1 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
NSStreamEvent  _1wx624s_BlockArgs_n9asv4_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer)->arg2;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_n9asv4_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_n9asv4_blocking* args = (__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_n9asv4_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_n9asv4_blocking* args = (__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_n9asv4_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_16)(void* block, void * arg0, id arg1, NSStreamEvent arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_n9asv4_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1, NSStreamEvent arg2) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_16)block)((__bridge void*)block, arg0, arg1, arg2);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_n9asv4_blocking* args = [[_1wx624s_BlockArgs_n9asv4_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      args->arg2 = arg2;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_n9asv4_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_11)(void * sel, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_hoampi(id target, void * sel, id arg1, NSStreamEvent arg2) {
  return ((_ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}
@interface _1wx624s_BlockArgs_a5zxhf : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  void* arg1;
  void* arg2;
  void* arg3;
  void *  arg4;
}
@end

@implementation _1wx624s_BlockArgs_a5zxhf
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_a5zxhf_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg1 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_getArg2(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg2;
  ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg2 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_getArg3(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg3;
  ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg3 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_a5zxhf_getArg4(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg4;
}


void _1wx624s_BlockArgs_a5zxhf_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_a5zxhf* args = (__bridge _1wx624s_BlockArgs_a5zxhf*)peer;
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    if (args->arg2 != NULL) { id relObj = (__bridge_transfer id)args->arg2; }
    if (args->arg3 != NULL) { id relObj = (__bridge_transfer id)args->arg3; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_a5zxhf_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_a5zxhf* args = (__bridge _1wx624s_BlockArgs_a5zxhf*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_a5zxhf_free, peer);
}

typedef void  (^_ListenerTrampoline_17)(void * arg0, id arg1, id arg2, id arg3, void * arg4);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_a5zxhf_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1, id arg2, id arg3, void * arg4) {
    _1wx624s_BlockArgs_a5zxhf* args = [[_1wx624s_BlockArgs_a5zxhf alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    args->arg2 = (__bridge_retained void*)arg2;
    args->arg3 = (__bridge_retained void*)arg3;
    args->arg4 = arg4;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_a5zxhf_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_a5zxhf_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  void* arg1;
  void* arg2;
  void* arg3;
  void *  arg4;
}
@end

@implementation _1wx624s_BlockArgs_a5zxhf_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_a5zxhf_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_blocking_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg1 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_blocking_getArg2(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg2;
  ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg2 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_blocking_getArg3(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg3;
  ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg3 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_a5zxhf_blocking_getArg4(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg4;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_a5zxhf_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_a5zxhf_blocking* args = (__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    if (args->arg2 != NULL) { id relObj = (__bridge_transfer id)args->arg2; }
    if (args->arg3 != NULL) { id relObj = (__bridge_transfer id)args->arg3; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_a5zxhf_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_a5zxhf_blocking* args = (__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_a5zxhf_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_17)(void* block, void * arg0, id arg1, id arg2, id arg3, void * arg4);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_a5zxhf_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0, id arg1, id arg2, id arg3, void * arg4) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_17)block)((__bridge void*)block, arg0, arg1, arg2, arg3, arg4);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_a5zxhf_blocking* args = [[_1wx624s_BlockArgs_a5zxhf_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      args->arg2 = (__bridge_retained void*)arg2;
      args->arg3 = (__bridge_retained void*)arg3;
      args->arg4 = arg4;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_a5zxhf_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef void  (^_ProtocolTrampoline_12)(void * sel, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_1sr3ozv(id target, void * sel, id arg1, id arg2, id arg3, void * arg4) {
  return ((_ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}
@interface _1wx624s_BlockArgs_1y1ob59 : NSObject {
  @public
  id block;
  void* context;
  void *  arg0;
  unsigned long  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1y1ob59
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1y1ob59_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1y1ob59*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_1y1ob59_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1y1ob59*)peer)->arg1;
}


void _1wx624s_BlockArgs_1y1ob59_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1y1ob59* args = (__bridge _1wx624s_BlockArgs_1y1ob59*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1y1ob59_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1y1ob59* args = (__bridge _1wx624s_BlockArgs_1y1ob59*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1y1ob59_free, peer);
}

typedef void  (^_ListenerTrampoline_18)(void * arg0, unsigned long arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1y1ob59_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(void * arg0, unsigned long arg1) {
    _1wx624s_BlockArgs_1y1ob59* args = [[_1wx624s_BlockArgs_1y1ob59 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1y1ob59_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1y1ob59_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void *  arg0;
  unsigned long  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1y1ob59_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1y1ob59_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_1y1ob59_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1y1ob59_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1y1ob59_blocking* args = (__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer;
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

void _1wx624s_BlockArgs_1y1ob59_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1y1ob59_blocking* args = (__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1y1ob59_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_18)(void* block, void * arg0, unsigned long arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1y1ob59_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(void * arg0, unsigned long arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_18)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1y1ob59_blocking* args = [[_1wx624s_BlockArgs_1y1ob59_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1y1ob59_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_chi4tl : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _1wx624s_BlockArgs_chi4tl
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_chi4tl_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_chi4tl*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_chi4tl_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_chi4tl*)peer)->arg1;
}


void _1wx624s_BlockArgs_chi4tl_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_chi4tl* args = (__bridge _1wx624s_BlockArgs_chi4tl*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_chi4tl_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_chi4tl* args = (__bridge _1wx624s_BlockArgs_chi4tl*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_chi4tl_free, peer);
}

typedef void  (^_ListenerTrampoline_19)(id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_chi4tl_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    _1wx624s_BlockArgs_chi4tl* args = [[_1wx624s_BlockArgs_chi4tl alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_chi4tl_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_chi4tl_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _1wx624s_BlockArgs_chi4tl_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_chi4tl_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_chi4tl_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_chi4tl_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_chi4tl_blocking* args = (__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer;
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

void _1wx624s_BlockArgs_chi4tl_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_chi4tl_blocking* args = (__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_chi4tl_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_19)(void* block, id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_chi4tl_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_19)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_chi4tl_blocking* args = [[_1wx624s_BlockArgs_chi4tl_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_chi4tl_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_1kxxlrd : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1kxxlrd
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1kxxlrd_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1kxxlrd*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1kxxlrd_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1kxxlrd*)peer)->arg1;
}


void _1wx624s_BlockArgs_1kxxlrd_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1kxxlrd* args = (__bridge _1wx624s_BlockArgs_1kxxlrd*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1kxxlrd_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1kxxlrd* args = (__bridge _1wx624s_BlockArgs_1kxxlrd*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1kxxlrd_free, peer);
}

typedef void  (^_ListenerTrampoline_20)(id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1kxxlrd_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    _1wx624s_BlockArgs_1kxxlrd* args = [[_1wx624s_BlockArgs_1kxxlrd alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1kxxlrd_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1kxxlrd_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _1wx624s_BlockArgs_1kxxlrd_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1kxxlrd_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1kxxlrd_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1kxxlrd_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1kxxlrd_blocking* args = (__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer;
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

void _1wx624s_BlockArgs_1kxxlrd_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1kxxlrd_blocking* args = (__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1kxxlrd_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_20)(void* block, id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1kxxlrd_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_20)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1kxxlrd_blocking* args = [[_1wx624s_BlockArgs_1kxxlrd_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1kxxlrd_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_1a2aane : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
  void* arg1;
}
@end

@implementation _1wx624s_BlockArgs_1a2aane
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1a2aane_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1a2aane*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1a2aane_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_1a2aane*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_1a2aane*)peer)->arg1 = NULL;
  return val;
}


void _1wx624s_BlockArgs_1a2aane_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1a2aane* args = (__bridge _1wx624s_BlockArgs_1a2aane*)peer;
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1a2aane_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1a2aane* args = (__bridge _1wx624s_BlockArgs_1a2aane*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1a2aane_free, peer);
}

typedef void  (^_ListenerTrampoline_21)(id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1a2aane_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    _1wx624s_BlockArgs_1a2aane* args = [[_1wx624s_BlockArgs_1a2aane alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = (__bridge_retained void*)arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1a2aane_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_1a2aane_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
  void* arg1;
}
@end

@implementation _1wx624s_BlockArgs_1a2aane_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1a2aane_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1a2aane_blocking_getArg1(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer)->arg1;
  ((__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer)->arg1 = NULL;
  return val;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1a2aane_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_1a2aane_blocking* args = (__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer;
    if (args->block != NULL) {
      id relBlock = (__bridge_transfer id)args->block;
      args->block = NULL;
    }
    if (args->waiter != NULL) {
      ((DOBJC_Context*)args->context)->signalWaiter(args->waiter);
      args->waiter = NULL;
    }
    if (args->arg1 != NULL) { id relObj = (__bridge_transfer id)args->arg1; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_1a2aane_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_1a2aane_blocking* args = (__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_1a2aane_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_21)(void* block, id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_1a2aane_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_21)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_1a2aane_blocking* args = [[_1wx624s_BlockArgs_1a2aane_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = (__bridge_retained void*)arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1a2aane_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_enc3u4 : NSObject {
  @public
  id block;
  void* context;
  void* arg0;
  unsigned long  arg1;
  BOOL *  arg2;
}
@end

@implementation _1wx624s_BlockArgs_enc3u4
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_enc3u4_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_enc3u4*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_enc3u4*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_enc3u4_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_enc3u4*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_enc3u4_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_enc3u4*)peer)->arg2;
}


void _1wx624s_BlockArgs_enc3u4_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_enc3u4* args = (__bridge _1wx624s_BlockArgs_enc3u4*)peer;
    if (args->arg0 != NULL) { id relObj = (__bridge_transfer id)args->arg0; }
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_enc3u4_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_enc3u4* args = (__bridge _1wx624s_BlockArgs_enc3u4*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_enc3u4_free, peer);
}

typedef void  (^_ListenerTrampoline_22)(id arg0, unsigned long arg1, BOOL * arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_enc3u4_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, unsigned long arg1, BOOL * arg2) {
    _1wx624s_BlockArgs_enc3u4* args = [[_1wx624s_BlockArgs_enc3u4 alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = (__bridge_retained void*)arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_enc3u4_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_enc3u4_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  void* arg0;
  unsigned long  arg1;
  BOOL *  arg2;
}
@end

@implementation _1wx624s_BlockArgs_enc3u4_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_enc3u4_blocking_getArg0(void* peer) {
  void* val = ((__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer)->arg0;
  ((__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer)->arg0 = NULL;
  return val;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_enc3u4_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_enc3u4_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer)->arg2;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_enc3u4_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_enc3u4_blocking* args = (__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer;
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

void _1wx624s_BlockArgs_enc3u4_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_enc3u4_blocking* args = (__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_enc3u4_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_22)(void* block, id arg0, unsigned long arg1, BOOL * arg2);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_enc3u4_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(id arg0, unsigned long arg1, BOOL * arg2) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_22)block)((__bridge void*)block, arg0, arg1, arg2);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_enc3u4_blocking* args = [[_1wx624s_BlockArgs_enc3u4_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = (__bridge_retained void*)arg0;
      args->arg1 = arg1;
      args->arg2 = arg2;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_enc3u4_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
@interface _1wx624s_BlockArgs_9k92cw : NSObject {
  @public
  id block;
  void* context;
  unsigned short *  arg0;
  unsigned long  arg1;
}
@end

@implementation _1wx624s_BlockArgs_9k92cw
@end

__attribute__((visibility("default"))) __attribute__((used))
unsigned short *  _1wx624s_BlockArgs_9k92cw_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_9k92cw*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_9k92cw_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_9k92cw*)peer)->arg1;
}


void _1wx624s_BlockArgs_9k92cw_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_9k92cw* args = (__bridge _1wx624s_BlockArgs_9k92cw*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _1wx624s_BlockArgs_9k92cw_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_9k92cw* args = (__bridge _1wx624s_BlockArgs_9k92cw*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_9k92cw_free, peer);
}

typedef void  (^_ListenerTrampoline_23)(unsigned short * arg0, unsigned long arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_9k92cw_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(unsigned short * arg0, unsigned long arg1) {
    _1wx624s_BlockArgs_9k92cw* args = [[_1wx624s_BlockArgs_9k92cw alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_9k92cw_finalize);
  } copy]);
}
@interface _1wx624s_BlockArgs_9k92cw_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  unsigned short *  arg0;
  unsigned long  arg1;
}
@end

@implementation _1wx624s_BlockArgs_9k92cw_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
unsigned short *  _1wx624s_BlockArgs_9k92cw_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_9k92cw_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_9k92cw_blocking_free(void* peer) {
  @autoreleasepool {
    _1wx624s_BlockArgs_9k92cw_blocking* args = (__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer;
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

void _1wx624s_BlockArgs_9k92cw_blocking_finalize(void* isolate_callback_data, void* peer) {
  _1wx624s_BlockArgs_9k92cw_blocking* args = (__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_1wx624s_BlockArgs_9k92cw_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline_23)(void* block, unsigned short * arg0, unsigned long arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_9k92cw_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  int64_t targetPort = context->getMainPortId == NULL ? 0 : context->getMainPortId();
  void* targetIsolate = context->currentIsolate();
  return (void*)CFBridgingRetain((id)[^void(unsigned short * arg0, unsigned long arg1) {
    void* currentIsolate = context->currentIsolate();
    bool mayEnterIsolate =
        currentIsolate == NULL &&
        context->getCurrentThreadOwnsIsolate != NULL &&
        context->getCurrentThreadOwnsIsolate(targetPort);
    if (currentIsolate == targetIsolate || mayEnterIsolate) {
      if (mayEnterIsolate) {
        context->enterIsolate(targetIsolate);
      }
      ((_BlockingTrampoline_23)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _1wx624s_BlockArgs_9k92cw_blocking* args = [[_1wx624s_BlockArgs_9k92cw_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _1wx624s_BlockArgs_9k92cw_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}

typedef id  (^_ProtocolTrampoline_13)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_13)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_14)(void * sel, struct _NSZone * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_18nsem0(id target, void * sel, struct _NSZone * arg1) {
  return ((_ProtocolTrampoline_14)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_15)(void * sel, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_50as9u(id target, void * sel, struct objc_selector * arg1) {
  return ((_ProtocolTrampoline_15)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_16)(void * sel, struct objc_selector * arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_1mllhpc(id target, void * sel, struct objc_selector * arg1, id arg2) {
  return ((_ProtocolTrampoline_16)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_17)(void * sel, struct objc_selector * arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_c7gk2u(id target, void * sel, struct objc_selector * arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_17)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_Observer(void) { return @protocol(Observer); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
