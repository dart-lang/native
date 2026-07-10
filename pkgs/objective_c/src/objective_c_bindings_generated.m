#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>

extern uint64_t getBlockRetainCount(void*);
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

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1wx624s_wrapListenerBlock_1pl9qdv(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void() {
    _ListenerTrampoline strongBlock = block;
    strongBlock();
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1wx624s_wrapBlockingBlock_1pl9qdv(
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
@interface _1wx624s_BlockArgs_1cme7zu : NSObject {
  @public
  id block;

}
@end

@implementation _1wx624s_BlockArgs_1cme7zu
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1cme7zu_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1cme7zu*)peer)->block;
}


void _1wx624s_BlockArgs_1cme7zu_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1cme7zu_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1cme7zu_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1cme7zu_portBlockInvoke(ObjCBlockImpl* block) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1cme7zu* args = [[_1wx624s_BlockArgs_1cme7zu alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1cme7zu_finalize);
}
@interface _1wx624s_BlockArgs_1cme7zu_blocking : NSObject {
  @public
  void* waiter;
  id block;

}
@end

@implementation _1wx624s_BlockArgs_1cme7zu_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1cme7zu_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1cme7zu_blocking* args = (__bridge _1wx624s_BlockArgs_1cme7zu_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1cme7zu_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1cme7zu_blocking*)peer)->block;
}


void _1wx624s_BlockArgs_1cme7zu_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1cme7zu_blocking* args = (__bridge _1wx624s_BlockArgs_1cme7zu_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1cme7zu_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1cme7zu_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1cme7zu_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1cme7zu_blocking* args = [[_1wx624s_BlockArgs_1cme7zu_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1cme7zu_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_1)(id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx624s_wrapListenerBlock_1o83rbn(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, BOOL * arg2) {
    _ListenerTrampoline_1 strongBlock = block;
    strongBlock(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx624s_wrapBlockingBlock_1o83rbn(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, BOOL * arg2), {
    _BlockingTrampoline_1 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2);
  }, {
    _BlockingTrampoline_1 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2);
  });
}
@interface _1wx624s_BlockArgs_tbq8wd : NSObject {
  @public
  id block;
  id arg0;
  id arg1;
  BOOL * arg2;
}
@end

@implementation _1wx624s_BlockArgs_tbq8wd
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_tbq8wd_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_tbq8wd*)peer)->arg2;
}


void _1wx624s_BlockArgs_tbq8wd_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_tbq8wd_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_tbq8wd_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_tbq8wd_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_tbq8wd* args = [[_1wx624s_BlockArgs_tbq8wd alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_tbq8wd_finalize);
}
@interface _1wx624s_BlockArgs_tbq8wd_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  id arg1;
  BOOL * arg2;
}
@end

@implementation _1wx624s_BlockArgs_tbq8wd_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_tbq8wd_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_tbq8wd_blocking* args = (__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_tbq8wd_blocking_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_tbq8wd_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer)->arg2;
}


void _1wx624s_BlockArgs_tbq8wd_blocking_free(void* peer) {
  _1wx624s_BlockArgs_tbq8wd_blocking* args = (__bridge _1wx624s_BlockArgs_tbq8wd_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_tbq8wd_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_tbq8wd_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_tbq8wd_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, id arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_tbq8wd_blocking* args = [[_1wx624s_BlockArgs_tbq8wd_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_tbq8wd_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_2)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx624s_wrapListenerBlock_pfv6jd(_ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    _ListenerTrampoline_2 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx624s_wrapBlockingBlock_pfv6jd(
    _BlockingTrampoline_2 block, _BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    _BlockingTrampoline_2 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_2 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _1wx624s_BlockArgs_1ilrkog : NSObject {
  @public
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1ilrkog
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1ilrkog_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1ilrkog*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1ilrkog_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1ilrkog*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1ilrkog_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1ilrkog*)peer)->arg1;
}


void _1wx624s_BlockArgs_1ilrkog_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1ilrkog_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1ilrkog_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1ilrkog_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1ilrkog* args = [[_1wx624s_BlockArgs_1ilrkog alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1ilrkog_finalize);
}
@interface _1wx624s_BlockArgs_1ilrkog_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1ilrkog_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1ilrkog_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1ilrkog_blocking* args = (__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1ilrkog_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1ilrkog_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1ilrkog_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_1ilrkog_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1ilrkog_blocking* args = (__bridge _1wx624s_BlockArgs_1ilrkog_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1ilrkog_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1ilrkog_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1ilrkog_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1ilrkog_blocking* args = [[_1wx624s_BlockArgs_1ilrkog_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1ilrkog_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_3)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx624s_wrapListenerBlock_1b3bb6a(_ListenerTrampoline_3 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    _ListenerTrampoline_3 strongBlock = block;
    strongBlock(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx624s_wrapBlockingBlock_1b3bb6a(
    _BlockingTrampoline_3 block, _BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    _BlockingTrampoline_3 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2);
  }, {
    _BlockingTrampoline_3 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2);
  });
}
@interface _1wx624s_BlockArgs_dgl1yu : NSObject {
  @public
  id block;
  id arg0;
  id arg1;
  id arg2;
}
@end

@implementation _1wx624s_BlockArgs_dgl1yu
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_getArg2(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_dgl1yu*)peer)->arg2;
}


void _1wx624s_BlockArgs_dgl1yu_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_dgl1yu_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_dgl1yu_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_dgl1yu_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_dgl1yu* args = [[_1wx624s_BlockArgs_dgl1yu alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = (__bridge_transfer id)(__bridge void*)objc_retainBlock(arg0);
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_dgl1yu_finalize);
}
@interface _1wx624s_BlockArgs_dgl1yu_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  id arg1;
  id arg2;
}
@end

@implementation _1wx624s_BlockArgs_dgl1yu_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_dgl1yu_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_dgl1yu_blocking* args = (__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_blocking_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_dgl1yu_blocking_getArg2(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer)->arg2;
}


void _1wx624s_BlockArgs_dgl1yu_blocking_free(void* peer) {
  _1wx624s_BlockArgs_dgl1yu_blocking* args = (__bridge _1wx624s_BlockArgs_dgl1yu_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_dgl1yu_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_dgl1yu_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_dgl1yu_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, id arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_dgl1yu_blocking* args = [[_1wx624s_BlockArgs_dgl1yu_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = (__bridge_transfer id)(__bridge void*)objc_retainBlock(arg0);
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_dgl1yu_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_4)(struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx624s_wrapListenerBlock_zkjmn1(_ListenerTrampoline_4 block) NS_RETURNS_RETAINED {
  return ^void(struct _NSRange arg0, BOOL * arg1) {
    _ListenerTrampoline_4 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx624s_wrapBlockingBlock_zkjmn1(
    _BlockingTrampoline_4 block, _BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct _NSRange arg0, BOOL * arg1), {
    _BlockingTrampoline_4 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_4 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _1wx624s_BlockArgs_meh2de : NSObject {
  @public
  id block;
  struct _NSRange arg0;
  BOOL * arg1;
}
@end

@implementation _1wx624s_BlockArgs_meh2de
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_meh2de_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_meh2de*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_meh2de_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_meh2de*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_meh2de_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_meh2de*)peer)->arg1;
}


void _1wx624s_BlockArgs_meh2de_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_meh2de_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_meh2de_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_meh2de_portBlockInvoke(ObjCBlockImpl* block, struct _NSRange arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_meh2de* args = [[_1wx624s_BlockArgs_meh2de alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_meh2de_finalize);
}
@interface _1wx624s_BlockArgs_meh2de_blocking : NSObject {
  @public
  void* waiter;
  id block;
  struct _NSRange arg0;
  BOOL * arg1;
}
@end

@implementation _1wx624s_BlockArgs_meh2de_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_meh2de_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_meh2de_blocking* args = (__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_meh2de_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1wx624s_BlockArgs_meh2de_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_meh2de_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_meh2de_blocking_free(void* peer) {
  _1wx624s_BlockArgs_meh2de_blocking* args = (__bridge _1wx624s_BlockArgs_meh2de_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_meh2de_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_meh2de_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_meh2de_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, struct _NSRange arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_meh2de_blocking* args = [[_1wx624s_BlockArgs_meh2de_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_meh2de_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_5)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx624s_wrapListenerBlock_lmc3p5(_ListenerTrampoline_5 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    _ListenerTrampoline_5 strongBlock = block;
    strongBlock(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx624s_wrapBlockingBlock_lmc3p5(
    _BlockingTrampoline_5 block, _BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3), {
    _BlockingTrampoline_5 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2, arg3);
  }, {
    _BlockingTrampoline_5 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}
@interface _1wx624s_BlockArgs_1r0pv4q : NSObject {
  @public
  id block;
  id arg0;
  struct _NSRange arg1;
  struct _NSRange arg2;
  BOOL * arg3;
}
@end

@implementation _1wx624s_BlockArgs_1r0pv4q
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1r0pv4q_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1r0pv4q*)peer)->block;
}

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
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1r0pv4q_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1r0pv4q_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1r0pv4q_portBlockInvoke(ObjCBlockImpl* block, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1r0pv4q* args = [[_1wx624s_BlockArgs_1r0pv4q alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;
  args->arg3 = arg3;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1r0pv4q_finalize);
}
@interface _1wx624s_BlockArgs_1r0pv4q_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  struct _NSRange arg1;
  struct _NSRange arg2;
  BOOL * arg3;
}
@end

@implementation _1wx624s_BlockArgs_1r0pv4q_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1r0pv4q_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1r0pv4q_blocking* args = (__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1r0pv4q_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer)->block;
}

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


void _1wx624s_BlockArgs_1r0pv4q_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1r0pv4q_blocking* args = (__bridge _1wx624s_BlockArgs_1r0pv4q_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1r0pv4q_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1r0pv4q_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1r0pv4q_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1r0pv4q_blocking* args = [[_1wx624s_BlockArgs_1r0pv4q_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;
  args->arg3 = arg3;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1r0pv4q_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_6)(id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx624s_wrapListenerBlock_t8l8el(_ListenerTrampoline_6 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL * arg1) {
    _ListenerTrampoline_6 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx624s_wrapBlockingBlock_t8l8el(
    _BlockingTrampoline_6 block, _BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL * arg1), {
    _BlockingTrampoline_6 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_6 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _1wx624s_BlockArgs_v348wu : NSObject {
  @public
  id block;
  id arg0;
  BOOL * arg1;
}
@end

@implementation _1wx624s_BlockArgs_v348wu
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_v348wu_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_v348wu*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_v348wu_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_v348wu*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_v348wu_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_v348wu*)peer)->arg1;
}


void _1wx624s_BlockArgs_v348wu_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_v348wu_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_v348wu_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_v348wu_portBlockInvoke(ObjCBlockImpl* block, id arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_v348wu* args = [[_1wx624s_BlockArgs_v348wu alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_v348wu_finalize);
}
@interface _1wx624s_BlockArgs_v348wu_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  BOOL * arg1;
}
@end

@implementation _1wx624s_BlockArgs_v348wu_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_v348wu_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_v348wu_blocking* args = (__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_v348wu_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_v348wu_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_v348wu_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_v348wu_blocking_free(void* peer) {
  _1wx624s_BlockArgs_v348wu_blocking* args = (__bridge _1wx624s_BlockArgs_v348wu_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_v348wu_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_v348wu_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_v348wu_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_v348wu_blocking* args = [[_1wx624s_BlockArgs_v348wu_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_v348wu_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_7)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx624s_wrapListenerBlock_xtuoz7(_ListenerTrampoline_7 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    _ListenerTrampoline_7 strongBlock = block;
    strongBlock(arg0);
  };
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx624s_wrapBlockingBlock_xtuoz7(
    _BlockingTrampoline_7 block, _BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    _BlockingTrampoline_7 strongBlock = block;
    strongBlock(nil, arg0);
  }, {
    _BlockingTrampoline_7 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0);
  });
}
@interface _1wx624s_BlockArgs_1yuig1 : NSObject {
  @public
  id block;
  id arg0;
}
@end

@implementation _1wx624s_BlockArgs_1yuig1
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1yuig1_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1yuig1*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1yuig1_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1yuig1*)peer)->arg0;
}


void _1wx624s_BlockArgs_1yuig1_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1yuig1_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1yuig1_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1yuig1_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1yuig1* args = [[_1wx624s_BlockArgs_1yuig1 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1yuig1_finalize);
}
@interface _1wx624s_BlockArgs_1yuig1_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
}
@end

@implementation _1wx624s_BlockArgs_1yuig1_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1yuig1_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1yuig1_blocking* args = (__bridge _1wx624s_BlockArgs_1yuig1_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1yuig1_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1yuig1_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1yuig1_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1yuig1_blocking*)peer)->arg0;
}


void _1wx624s_BlockArgs_1yuig1_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1yuig1_blocking* args = (__bridge _1wx624s_BlockArgs_1yuig1_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1yuig1_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1yuig1_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1yuig1_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1yuig1_blocking* args = [[_1wx624s_BlockArgs_1yuig1_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1yuig1_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_8)(unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx624s_wrapListenerBlock_q5jeyk(_ListenerTrampoline_8 block) NS_RETURNS_RETAINED {
  return ^void(unsigned long arg0, BOOL * arg1) {
    _ListenerTrampoline_8 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_8)(void * waiter, unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx624s_wrapBlockingBlock_q5jeyk(
    _BlockingTrampoline_8 block, _BlockingTrampoline_8 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned long arg0, BOOL * arg1), {
    _BlockingTrampoline_8 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_8 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _1wx624s_BlockArgs_1dzsfqo : NSObject {
  @public
  id block;
  unsigned long arg0;
  BOOL * arg1;
}
@end

@implementation _1wx624s_BlockArgs_1dzsfqo
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1dzsfqo_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1dzsfqo*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_1dzsfqo_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1dzsfqo*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_1dzsfqo_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1dzsfqo*)peer)->arg1;
}


void _1wx624s_BlockArgs_1dzsfqo_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1dzsfqo_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1dzsfqo_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1dzsfqo_portBlockInvoke(ObjCBlockImpl* block, unsigned long arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1dzsfqo* args = [[_1wx624s_BlockArgs_1dzsfqo alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1dzsfqo_finalize);
}
@interface _1wx624s_BlockArgs_1dzsfqo_blocking : NSObject {
  @public
  void* waiter;
  id block;
  unsigned long arg0;
  BOOL * arg1;
}
@end

@implementation _1wx624s_BlockArgs_1dzsfqo_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1dzsfqo_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1dzsfqo_blocking* args = (__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1dzsfqo_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_1dzsfqo_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_1dzsfqo_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_1dzsfqo_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1dzsfqo_blocking* args = (__bridge _1wx624s_BlockArgs_1dzsfqo_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1dzsfqo_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1dzsfqo_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1dzsfqo_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, unsigned long arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1dzsfqo_blocking* args = [[_1wx624s_BlockArgs_1dzsfqo_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1dzsfqo_blocking_finalize);
}
@interface _1wx624s_BlockArgs_1wa2b1l : NSObject {
  @public
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1wa2b1l
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1wa2b1l_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1wa2b1l*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1wa2b1l_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1wa2b1l*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1wa2b1l_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1wa2b1l*)peer)->arg1;
}


void _1wx624s_BlockArgs_1wa2b1l_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1wa2b1l_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1wa2b1l_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1wa2b1l_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1wa2b1l* args = [[_1wx624s_BlockArgs_1wa2b1l alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1wa2b1l_finalize);
}
@interface _1wx624s_BlockArgs_1wa2b1l_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1wa2b1l_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1wa2b1l_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1wa2b1l_blocking* args = (__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1wa2b1l_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1wa2b1l_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1wa2b1l_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_1wa2b1l_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1wa2b1l_blocking* args = (__bridge _1wx624s_BlockArgs_1wa2b1l_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1wa2b1l_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1wa2b1l_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1wa2b1l_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1wa2b1l_blocking* args = [[_1wx624s_BlockArgs_1wa2b1l_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1wa2b1l_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_9)(id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx624s_wrapListenerBlock_rnu2c5(_ListenerTrampoline_9 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, id arg2) {
    _ListenerTrampoline_9 strongBlock = block;
    strongBlock(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_9)(void * waiter, id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx624s_wrapBlockingBlock_rnu2c5(
    _BlockingTrampoline_9 block, _BlockingTrampoline_9 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1, id arg2), {
    _BlockingTrampoline_9 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2);
  }, {
    _BlockingTrampoline_9 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2);
  });
}
@interface _1wx624s_BlockArgs_jnk8ia : NSObject {
  @public
  id block;
  id arg0;
  BOOL arg1;
  id arg2;
}
@end

@implementation _1wx624s_BlockArgs_jnk8ia
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_jnk8ia_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_jnk8ia*)peer)->block;
}

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
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_jnk8ia_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_jnk8ia_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_jnk8ia_portBlockInvoke(ObjCBlockImpl* block, id arg0, BOOL arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_jnk8ia* args = [[_1wx624s_BlockArgs_jnk8ia alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_jnk8ia_finalize);
}
@interface _1wx624s_BlockArgs_jnk8ia_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  BOOL arg1;
  id arg2;
}
@end

@implementation _1wx624s_BlockArgs_jnk8ia_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_jnk8ia_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_jnk8ia_blocking* args = (__bridge _1wx624s_BlockArgs_jnk8ia_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_jnk8ia_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_jnk8ia_blocking*)peer)->block;
}

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


void _1wx624s_BlockArgs_jnk8ia_blocking_free(void* peer) {
  _1wx624s_BlockArgs_jnk8ia_blocking* args = (__bridge _1wx624s_BlockArgs_jnk8ia_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_jnk8ia_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_jnk8ia_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_jnk8ia_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, BOOL arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_jnk8ia_blocking* args = [[_1wx624s_BlockArgs_jnk8ia_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_jnk8ia_blocking_finalize);
}
@interface _1wx624s_BlockArgs_borsj5 : NSObject {
  @public
  id block;
  id arg0;
  BOOL * arg1;
}
@end

@implementation _1wx624s_BlockArgs_borsj5
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_borsj5_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_borsj5*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_borsj5_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_borsj5*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_borsj5_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_borsj5*)peer)->arg1;
}


void _1wx624s_BlockArgs_borsj5_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_borsj5_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_borsj5_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_borsj5_portBlockInvoke(ObjCBlockImpl* block, id arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_borsj5* args = [[_1wx624s_BlockArgs_borsj5 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_borsj5_finalize);
}
@interface _1wx624s_BlockArgs_borsj5_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  BOOL * arg1;
}
@end

@implementation _1wx624s_BlockArgs_borsj5_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_borsj5_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_borsj5_blocking* args = (__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_borsj5_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_borsj5_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_borsj5_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_borsj5_blocking_free(void* peer) {
  _1wx624s_BlockArgs_borsj5_blocking* args = (__bridge _1wx624s_BlockArgs_borsj5_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_borsj5_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_borsj5_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_borsj5_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_borsj5_blocking* args = [[_1wx624s_BlockArgs_borsj5_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_borsj5_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_10)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx624s_wrapListenerBlock_ovsamd(_ListenerTrampoline_10 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    _ListenerTrampoline_10 strongBlock = block;
    strongBlock(arg0);
  };
}

typedef void  (^_BlockingTrampoline_10)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx624s_wrapBlockingBlock_ovsamd(
    _BlockingTrampoline_10 block, _BlockingTrampoline_10 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0), {
    _BlockingTrampoline_10 strongBlock = block;
    strongBlock(nil, arg0);
  }, {
    _BlockingTrampoline_10 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0);
  });
}
@interface _1wx624s_BlockArgs_448250 : NSObject {
  @public
  id block;
  void * arg0;
}
@end

@implementation _1wx624s_BlockArgs_448250
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_448250_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_448250*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_448250_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_448250*)peer)->arg0;
}


void _1wx624s_BlockArgs_448250_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_448250_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_448250_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_448250_portBlockInvoke(ObjCBlockImpl* block, void * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_448250* args = [[_1wx624s_BlockArgs_448250 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_448250_finalize);
}
@interface _1wx624s_BlockArgs_448250_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
}
@end

@implementation _1wx624s_BlockArgs_448250_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_448250_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_448250_blocking* args = (__bridge _1wx624s_BlockArgs_448250_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_448250_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_448250_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_448250_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_448250_blocking*)peer)->arg0;
}


void _1wx624s_BlockArgs_448250_blocking_free(void* peer) {
  _1wx624s_BlockArgs_448250_blocking* args = (__bridge _1wx624s_BlockArgs_448250_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_448250_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_448250_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_448250_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_448250_blocking* args = [[_1wx624s_BlockArgs_448250_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_448250_blocking_finalize);
}

typedef void  (^_ProtocolTrampoline_9)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((_ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^_ListenerTrampoline_11)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx624s_wrapListenerBlock_18v1jvf(_ListenerTrampoline_11 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    _ListenerTrampoline_11 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_11)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx624s_wrapBlockingBlock_18v1jvf(
    _BlockingTrampoline_11 block, _BlockingTrampoline_11 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    _BlockingTrampoline_11 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_11 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _1wx624s_BlockArgs_1vi0sov : NSObject {
  @public
  id block;
  void * arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1vi0sov
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1vi0sov_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1vi0sov*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1vi0sov_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1vi0sov*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1vi0sov_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1vi0sov*)peer)->arg1;
}


void _1wx624s_BlockArgs_1vi0sov_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1vi0sov_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1vi0sov_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1vi0sov_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1vi0sov* args = [[_1wx624s_BlockArgs_1vi0sov alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1vi0sov_finalize);
}
@interface _1wx624s_BlockArgs_1vi0sov_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1vi0sov_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1vi0sov_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1vi0sov_blocking* args = (__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1vi0sov_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1vi0sov_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1vi0sov_blocking_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_1vi0sov_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1vi0sov_blocking* args = (__bridge _1wx624s_BlockArgs_1vi0sov_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1vi0sov_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1vi0sov_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1vi0sov_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1vi0sov_blocking* args = [[_1wx624s_BlockArgs_1vi0sov_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1vi0sov_blocking_finalize);
}

typedef void  (^_ProtocolTrampoline_10)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
@interface _1wx624s_BlockArgs_1mmoiyc : NSObject {
  @public
  id block;
  void * arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1mmoiyc
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1mmoiyc_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1mmoiyc*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1mmoiyc_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1mmoiyc*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1mmoiyc_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1mmoiyc*)peer)->arg1;
}


void _1wx624s_BlockArgs_1mmoiyc_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1mmoiyc_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1mmoiyc_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1mmoiyc_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1mmoiyc* args = [[_1wx624s_BlockArgs_1mmoiyc alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1mmoiyc_finalize);
}
@interface _1wx624s_BlockArgs_1mmoiyc_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1mmoiyc_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1mmoiyc_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1mmoiyc_blocking* args = (__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1mmoiyc_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1mmoiyc_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1mmoiyc_blocking_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_1mmoiyc_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1mmoiyc_blocking* args = (__bridge _1wx624s_BlockArgs_1mmoiyc_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1mmoiyc_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1mmoiyc_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1mmoiyc_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1mmoiyc_blocking* args = [[_1wx624s_BlockArgs_1mmoiyc_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1mmoiyc_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_12)(void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx624s_wrapListenerBlock_1q8ia8l(_ListenerTrampoline_12 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct _NSRange arg1, BOOL * arg2) {
    _ListenerTrampoline_12 strongBlock = block;
    strongBlock(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_12)(void * waiter, void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx624s_wrapBlockingBlock_1q8ia8l(
    _BlockingTrampoline_12 block, _BlockingTrampoline_12 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct _NSRange arg1, BOOL * arg2), {
    _BlockingTrampoline_12 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2);
  }, {
    _BlockingTrampoline_12 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2);
  });
}
@interface _1wx624s_BlockArgs_1yt1g7s : NSObject {
  @public
  id block;
  void * arg0;
  struct _NSRange arg1;
  BOOL * arg2;
}
@end

@implementation _1wx624s_BlockArgs_1yt1g7s
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1yt1g7s_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1yt1g7s*)peer)->block;
}

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
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1yt1g7s_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1yt1g7s_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1yt1g7s_portBlockInvoke(ObjCBlockImpl* block, void * arg0, struct _NSRange arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1yt1g7s* args = [[_1wx624s_BlockArgs_1yt1g7s alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1yt1g7s_finalize);
}
@interface _1wx624s_BlockArgs_1yt1g7s_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
  struct _NSRange arg1;
  BOOL * arg2;
}
@end

@implementation _1wx624s_BlockArgs_1yt1g7s_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1yt1g7s_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1yt1g7s_blocking* args = (__bridge _1wx624s_BlockArgs_1yt1g7s_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1yt1g7s_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1yt1g7s_blocking*)peer)->block;
}

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


void _1wx624s_BlockArgs_1yt1g7s_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1yt1g7s_blocking* args = (__bridge _1wx624s_BlockArgs_1yt1g7s_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1yt1g7s_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1yt1g7s_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1yt1g7s_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0, struct _NSRange arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1yt1g7s_blocking* args = [[_1wx624s_BlockArgs_1yt1g7s_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1yt1g7s_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_13)(void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx624s_wrapListenerBlock_hoampi(_ListenerTrampoline_13 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, NSStreamEvent arg2) {
    _ListenerTrampoline_13 strongBlock = block;
    strongBlock(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_13)(void * waiter, void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx624s_wrapBlockingBlock_hoampi(
    _BlockingTrampoline_13 block, _BlockingTrampoline_13 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, NSStreamEvent arg2), {
    _BlockingTrampoline_13 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2);
  }, {
    _BlockingTrampoline_13 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2);
  });
}
@interface _1wx624s_BlockArgs_n9asv4 : NSObject {
  @public
  id block;
  void * arg0;
  id arg1;
  NSStreamEvent arg2;
}
@end

@implementation _1wx624s_BlockArgs_n9asv4
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_n9asv4_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_n9asv4*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_n9asv4_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_n9asv4*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_n9asv4_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_n9asv4*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
NSStreamEvent  _1wx624s_BlockArgs_n9asv4_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_n9asv4*)peer)->arg2;
}


void _1wx624s_BlockArgs_n9asv4_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_n9asv4_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_n9asv4_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_n9asv4_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1, NSStreamEvent arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_n9asv4* args = [[_1wx624s_BlockArgs_n9asv4 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_n9asv4_finalize);
}
@interface _1wx624s_BlockArgs_n9asv4_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
  id arg1;
  NSStreamEvent arg2;
}
@end

@implementation _1wx624s_BlockArgs_n9asv4_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_n9asv4_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_n9asv4_blocking* args = (__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_n9asv4_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_n9asv4_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_n9asv4_blocking_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
NSStreamEvent  _1wx624s_BlockArgs_n9asv4_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer)->arg2;
}


void _1wx624s_BlockArgs_n9asv4_blocking_free(void* peer) {
  _1wx624s_BlockArgs_n9asv4_blocking* args = (__bridge _1wx624s_BlockArgs_n9asv4_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_n9asv4_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_n9asv4_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_n9asv4_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0, id arg1, NSStreamEvent arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_n9asv4_blocking* args = [[_1wx624s_BlockArgs_n9asv4_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_n9asv4_blocking_finalize);
}

typedef void  (^_ProtocolTrampoline_11)(void * sel, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_hoampi(id target, void * sel, id arg1, NSStreamEvent arg2) {
  return ((_ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_14)(void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx624s_wrapListenerBlock_1sr3ozv(_ListenerTrampoline_14 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, void * arg4) {
    _ListenerTrampoline_14 strongBlock = block;
    strongBlock(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^_BlockingTrampoline_14)(void * waiter, void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx624s_wrapBlockingBlock_1sr3ozv(
    _BlockingTrampoline_14 block, _BlockingTrampoline_14 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, void * arg4), {
    _BlockingTrampoline_14 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    _BlockingTrampoline_14 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}
@interface _1wx624s_BlockArgs_a5zxhf : NSObject {
  @public
  id block;
  void * arg0;
  id arg1;
  id arg2;
  id arg3;
  void * arg4;
}
@end

@implementation _1wx624s_BlockArgs_a5zxhf
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_a5zxhf_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_getArg2(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg2;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_getArg3(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg3;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_a5zxhf_getArg4(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_a5zxhf*)peer)->arg4;
}


void _1wx624s_BlockArgs_a5zxhf_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_a5zxhf_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_a5zxhf_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_a5zxhf_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1, id arg2, id arg3, void * arg4) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_a5zxhf* args = [[_1wx624s_BlockArgs_a5zxhf alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;
  args->arg3 = arg3;
  args->arg4 = arg4;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_a5zxhf_finalize);
}
@interface _1wx624s_BlockArgs_a5zxhf_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
  id arg1;
  id arg2;
  id arg3;
  void * arg4;
}
@end

@implementation _1wx624s_BlockArgs_a5zxhf_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_a5zxhf_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_a5zxhf_blocking* args = (__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_a5zxhf_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_blocking_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_blocking_getArg2(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg2;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_a5zxhf_blocking_getArg3(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg3;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_a5zxhf_blocking_getArg4(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer)->arg4;
}


void _1wx624s_BlockArgs_a5zxhf_blocking_free(void* peer) {
  _1wx624s_BlockArgs_a5zxhf_blocking* args = (__bridge _1wx624s_BlockArgs_a5zxhf_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_a5zxhf_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_a5zxhf_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_a5zxhf_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0, id arg1, id arg2, id arg3, void * arg4) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_a5zxhf_blocking* args = [[_1wx624s_BlockArgs_a5zxhf_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;
  args->arg3 = arg3;
  args->arg4 = arg4;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_a5zxhf_blocking_finalize);
}

typedef void  (^_ProtocolTrampoline_12)(void * sel, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_1sr3ozv(id target, void * sel, id arg1, id arg2, id arg3, void * arg4) {
  return ((_ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_15)(void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx624s_wrapListenerBlock_zuf90e(_ListenerTrampoline_15 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1) {
    _ListenerTrampoline_15 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_15)(void * waiter, void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx624s_wrapBlockingBlock_zuf90e(
    _BlockingTrampoline_15 block, _BlockingTrampoline_15 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1), {
    _BlockingTrampoline_15 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_15 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _1wx624s_BlockArgs_1y1ob59 : NSObject {
  @public
  id block;
  void * arg0;
  unsigned long arg1;
}
@end

@implementation _1wx624s_BlockArgs_1y1ob59
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1y1ob59_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1y1ob59*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1y1ob59_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1y1ob59*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_1y1ob59_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1y1ob59*)peer)->arg1;
}


void _1wx624s_BlockArgs_1y1ob59_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1y1ob59_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1y1ob59_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1y1ob59_portBlockInvoke(ObjCBlockImpl* block, void * arg0, unsigned long arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1y1ob59* args = [[_1wx624s_BlockArgs_1y1ob59 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1y1ob59_finalize);
}
@interface _1wx624s_BlockArgs_1y1ob59_blocking : NSObject {
  @public
  void* waiter;
  id block;
  void * arg0;
  unsigned long arg1;
}
@end

@implementation _1wx624s_BlockArgs_1y1ob59_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1y1ob59_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1y1ob59_blocking* args = (__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1y1ob59_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void *  _1wx624s_BlockArgs_1y1ob59_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_1y1ob59_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_1y1ob59_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1y1ob59_blocking* args = (__bridge _1wx624s_BlockArgs_1y1ob59_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1y1ob59_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1y1ob59_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1y1ob59_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, void * arg0, unsigned long arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1y1ob59_blocking* args = [[_1wx624s_BlockArgs_1y1ob59_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1y1ob59_blocking_finalize);
}
@interface _1wx624s_BlockArgs_chi4tl : NSObject {
  @public
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_chi4tl
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_chi4tl_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_chi4tl*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_chi4tl_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_chi4tl*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_chi4tl_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_chi4tl*)peer)->arg1;
}


void _1wx624s_BlockArgs_chi4tl_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_chi4tl_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_chi4tl_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_chi4tl_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_chi4tl* args = [[_1wx624s_BlockArgs_chi4tl alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_chi4tl_finalize);
}
@interface _1wx624s_BlockArgs_chi4tl_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_chi4tl_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_chi4tl_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_chi4tl_blocking* args = (__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_chi4tl_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_chi4tl_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_chi4tl_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_chi4tl_blocking_free(void* peer) {
  _1wx624s_BlockArgs_chi4tl_blocking* args = (__bridge _1wx624s_BlockArgs_chi4tl_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_chi4tl_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_chi4tl_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_chi4tl_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_chi4tl_blocking* args = [[_1wx624s_BlockArgs_chi4tl_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_chi4tl_blocking_finalize);
}
@interface _1wx624s_BlockArgs_1kxxlrd : NSObject {
  @public
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1kxxlrd
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1kxxlrd_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1kxxlrd*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1kxxlrd_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1kxxlrd*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1kxxlrd_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1kxxlrd*)peer)->arg1;
}


void _1wx624s_BlockArgs_1kxxlrd_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1kxxlrd_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1kxxlrd_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1kxxlrd_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1kxxlrd* args = [[_1wx624s_BlockArgs_1kxxlrd alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1kxxlrd_finalize);
}
@interface _1wx624s_BlockArgs_1kxxlrd_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1kxxlrd_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1kxxlrd_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1kxxlrd_blocking* args = (__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1kxxlrd_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1kxxlrd_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1kxxlrd_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_1kxxlrd_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1kxxlrd_blocking* args = (__bridge _1wx624s_BlockArgs_1kxxlrd_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1kxxlrd_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1kxxlrd_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1kxxlrd_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1kxxlrd_blocking* args = [[_1wx624s_BlockArgs_1kxxlrd_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1kxxlrd_blocking_finalize);
}
@interface _1wx624s_BlockArgs_1a2aane : NSObject {
  @public
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1a2aane
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1a2aane_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1a2aane*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1a2aane_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1a2aane*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1a2aane_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1a2aane*)peer)->arg1;
}


void _1wx624s_BlockArgs_1a2aane_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_1a2aane_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1a2aane_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1a2aane_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1a2aane* args = [[_1wx624s_BlockArgs_1a2aane alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1a2aane_finalize);
}
@interface _1wx624s_BlockArgs_1a2aane_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  id arg1;
}
@end

@implementation _1wx624s_BlockArgs_1a2aane_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_1a2aane_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_1a2aane_blocking* args = (__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1a2aane_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_BlockArgs_1a2aane_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_1a2aane_blocking_getArg1(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_1a2aane_blocking_free(void* peer) {
  _1wx624s_BlockArgs_1a2aane_blocking* args = (__bridge _1wx624s_BlockArgs_1a2aane_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_1a2aane_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_1a2aane_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_1a2aane_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_1a2aane_blocking* args = [[_1wx624s_BlockArgs_1a2aane_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_1a2aane_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_16)(id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx624s_wrapListenerBlock_1p9ui4q(_ListenerTrampoline_16 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, unsigned long arg1, BOOL * arg2) {
    _ListenerTrampoline_16 strongBlock = block;
    strongBlock(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_16)(void * waiter, id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx624s_wrapBlockingBlock_1p9ui4q(
    _BlockingTrampoline_16 block, _BlockingTrampoline_16 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, unsigned long arg1, BOOL * arg2), {
    _BlockingTrampoline_16 strongBlock = block;
    strongBlock(nil, arg0, arg1, arg2);
  }, {
    _BlockingTrampoline_16 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1, arg2);
  });
}
@interface _1wx624s_BlockArgs_enc3u4 : NSObject {
  @public
  id block;
  id arg0;
  unsigned long arg1;
  BOOL * arg2;
}
@end

@implementation _1wx624s_BlockArgs_enc3u4
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_enc3u4_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_enc3u4*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_enc3u4_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_enc3u4*)peer)->arg0;
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
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_enc3u4_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_enc3u4_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_enc3u4_portBlockInvoke(ObjCBlockImpl* block, id arg0, unsigned long arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_enc3u4* args = [[_1wx624s_BlockArgs_enc3u4 alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_enc3u4_finalize);
}
@interface _1wx624s_BlockArgs_enc3u4_blocking : NSObject {
  @public
  void* waiter;
  id block;
  id arg0;
  unsigned long arg1;
  BOOL * arg2;
}
@end

@implementation _1wx624s_BlockArgs_enc3u4_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_enc3u4_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_enc3u4_blocking* args = (__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_enc3u4_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_enc3u4_blocking_getArg0(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_enc3u4_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer)->arg1;
}

__attribute__((visibility("default"))) __attribute__((used))
BOOL *  _1wx624s_BlockArgs_enc3u4_blocking_getArg2(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer)->arg2;
}


void _1wx624s_BlockArgs_enc3u4_blocking_free(void* peer) {
  _1wx624s_BlockArgs_enc3u4_blocking* args = (__bridge _1wx624s_BlockArgs_enc3u4_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_enc3u4_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_enc3u4_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_enc3u4_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, id arg0, unsigned long arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_enc3u4_blocking* args = [[_1wx624s_BlockArgs_enc3u4_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_enc3u4_blocking_finalize);
}

typedef void  (^_ListenerTrampoline_17)(unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx624s_wrapListenerBlock_vhbh5h(_ListenerTrampoline_17 block) NS_RETURNS_RETAINED {
  return ^void(unsigned short * arg0, unsigned long arg1) {
    _ListenerTrampoline_17 strongBlock = block;
    strongBlock(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_17)(void * waiter, unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx624s_wrapBlockingBlock_vhbh5h(
    _BlockingTrampoline_17 block, _BlockingTrampoline_17 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned short * arg0, unsigned long arg1), {
    _BlockingTrampoline_17 strongBlock = block;
    strongBlock(nil, arg0, arg1);
  }, {
    _BlockingTrampoline_17 strongListenerBlock = listenerBlock;
    strongListenerBlock(waiter, arg0, arg1);
  });
}
@interface _1wx624s_BlockArgs_9k92cw : NSObject {
  @public
  id block;
  unsigned short * arg0;
  unsigned long arg1;
}
@end

@implementation _1wx624s_BlockArgs_9k92cw
@end

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_9k92cw_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_9k92cw*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned short *  _1wx624s_BlockArgs_9k92cw_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_9k92cw*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_9k92cw_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_9k92cw*)peer)->arg1;
}


void _1wx624s_BlockArgs_9k92cw_free(void* peer) {
  id args = (__bridge_transfer id)peer;
}

void _1wx624s_BlockArgs_9k92cw_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_9k92cw_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_9k92cw_portBlockInvoke(ObjCBlockImpl* block, unsigned short * arg0, unsigned long arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_9k92cw* args = [[_1wx624s_BlockArgs_9k92cw alloc] init];
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_9k92cw_finalize);
}
@interface _1wx624s_BlockArgs_9k92cw_blocking : NSObject {
  @public
  void* waiter;
  id block;
  unsigned short * arg0;
  unsigned long arg1;
}
@end

@implementation _1wx624s_BlockArgs_9k92cw_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_BlockArgs_9k92cw_blocking_signalWaiter(void* peer) {
  _1wx624s_BlockArgs_9k92cw_blocking* args = (__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer;
  if (args->waiter != NULL) {
    DOBJC_signalWaiter(args->waiter);
    args->waiter = NULL;
  }
}

__attribute__((visibility("default"))) __attribute__((used))
void* _1wx624s_BlockArgs_9k92cw_blocking_getBlock(void* peer) {
  return (__bridge void*)((__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer)->block;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned short *  _1wx624s_BlockArgs_9k92cw_blocking_getArg0(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _1wx624s_BlockArgs_9k92cw_blocking_getArg1(void* peer) {
  return ((__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer)->arg1;
}


void _1wx624s_BlockArgs_9k92cw_blocking_free(void* peer) {
  _1wx624s_BlockArgs_9k92cw_blocking* args = (__bridge _1wx624s_BlockArgs_9k92cw_blocking*)peer;
  void* waiter = args->waiter;
  args->waiter = NULL;
  id argsObj = (__bridge_transfer id)peer;
  argsObj = nil;
  DOBJC_signalWaiter(waiter);
}

void _1wx624s_BlockArgs_9k92cw_blocking_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_BlockArgs_9k92cw_blocking_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_9k92cw_portBlockInvoke_blocking(ObjCBlockImpl* block, void* waiter, unsigned short * arg0, unsigned long arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_9k92cw_blocking* args = [[_1wx624s_BlockArgs_9k92cw_blocking alloc] init];
  args->waiter = waiter;
  args->block = (__bridge_transfer id)(__bridge void*)objc_retainBlock((__bridge id)block);
  args->arg0 = arg0;
  args->arg1 = arg1;

  void* raw_args = (__bridge_retained void*)args;
  ctx->postCObject(port_id, raw_args, _1wx624s_BlockArgs_9k92cw_blocking_finalize);
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
