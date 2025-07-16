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
} DOBJC_Context;

id objc_retainBlock(id);

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


Protocol* _ObjectiveCBindings_NSCoding(void) { return @protocol(NSCoding); }

Protocol* _ObjectiveCBindings_NSCopying(void) { return @protocol(NSCopying); }

Protocol* _ObjectiveCBindings_NSFastEnumeration(void) { return @protocol(NSFastEnumeration); }

Protocol* _ObjectiveCBindings_NSItemProviderReading(void) { return @protocol(NSItemProviderReading); }

Protocol* _ObjectiveCBindings_NSItemProviderWriting(void) { return @protocol(NSItemProviderWriting); }

Protocol* _ObjectiveCBindings_NSMutableCopying(void) { return @protocol(NSMutableCopying); }

Protocol* _ObjectiveCBindings_NSObject(void) { return @protocol(NSObject); }

Protocol* _ObjectiveCBindings_NSPortDelegate(void) { return @protocol(NSPortDelegate); }

Protocol* _ObjectiveCBindings_NSSecureCoding(void) { return @protocol(NSSecureCoding); }

Protocol* _ObjectiveCBindings_NSStreamDelegate(void) { return @protocol(NSStreamDelegate); }

typedef id  (^ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef NSItemProviderRepresentationVisibility  (^ProtocolTrampoline_1)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
NSItemProviderRepresentationVisibility  _ObjectiveCBindings_protocolTrampoline_1ldqghh(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_2)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_protocolTrampoline_1q0i84(id target, void * sel, id arg1, id arg2) {
  return ((ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef unsigned long  (^ProtocolTrampoline_3)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _ObjectiveCBindings_protocolTrampoline_1ckyi24(id target, void * sel) {
  return ((ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef unsigned long  (^ProtocolTrampoline_4)(void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _ObjectiveCBindings_protocolTrampoline_17ap02x(id target, void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef struct _NSZone *  (^ProtocolTrampoline_5)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct _NSZone *  _ObjectiveCBindings_protocolTrampoline_1a8cl66(id target, void * sel) {
  return ((ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^ProtocolTrampoline_6)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _ObjectiveCBindings_protocolTrampoline_e3qsqz(id target, void * sel) {
  return ((ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^ProtocolTrampoline_7)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _ObjectiveCBindings_protocolTrampoline_3su7tt(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_7)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^ProtocolTrampoline_8)(void * sel, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _ObjectiveCBindings_protocolTrampoline_w1e3k0(id target, void * sel, struct objc_selector * arg1) {
  return ((ProtocolTrampoline_8)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline)();
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline _ObjectiveCBindings_wrapListenerBlock_1pl9qdv(ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void() {
    objc_retainBlock(block);
    block();
  };
}

typedef void  (^BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline _ObjectiveCBindings_wrapBlockingBlock_1pl9qdv(
    BlockingTrampoline block, BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(), {
    objc_retainBlock(block);
    block(nil);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter);
  });
}

typedef void  (^ListenerTrampoline_1)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_1 _ObjectiveCBindings_wrapListenerBlock_pfv6jd(ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^BlockingTrampoline_1)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_1 _ObjectiveCBindings_wrapBlockingBlock_pfv6jd(
    BlockingTrampoline_1 block, BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^ListenerTrampoline_2)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_2 _ObjectiveCBindings_wrapListenerBlock_1b3bb6a(ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^BlockingTrampoline_2)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_2 _ObjectiveCBindings_wrapBlockingBlock_1b3bb6a(
    BlockingTrampoline_2 block, BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^ListenerTrampoline_3)(struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_3 _ObjectiveCBindings_wrapListenerBlock_zkjmn1(ListenerTrampoline_3 block) NS_RETURNS_RETAINED {
  return ^void(struct _NSRange arg0, BOOL * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_3)(void * waiter, struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_3 _ObjectiveCBindings_wrapBlockingBlock_zkjmn1(
    BlockingTrampoline_3 block, BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct _NSRange arg0, BOOL * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ListenerTrampoline_4)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_4 _ObjectiveCBindings_wrapListenerBlock_lmc3p5(ListenerTrampoline_4 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_4)(void * waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_4 _ObjectiveCBindings_wrapBlockingBlock_lmc3p5(
    BlockingTrampoline_4 block, BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  });
}

typedef void  (^ListenerTrampoline_5)(id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_5 _ObjectiveCBindings_wrapListenerBlock_t8l8el(ListenerTrampoline_5 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL * arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1);
  };
}

typedef void  (^BlockingTrampoline_5)(void * waiter, id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_5 _ObjectiveCBindings_wrapBlockingBlock_t8l8el(
    BlockingTrampoline_5 block, BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL * arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  });
}

typedef void  (^ListenerTrampoline_6)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_6 _ObjectiveCBindings_wrapListenerBlock_xtuoz7(ListenerTrampoline_6 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0));
  };
}

typedef void  (^BlockingTrampoline_6)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_6 _ObjectiveCBindings_wrapBlockingBlock_xtuoz7(
    BlockingTrampoline_6 block, BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0));
  });
}

typedef void  (^ListenerTrampoline_7)(unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_7 _ObjectiveCBindings_wrapListenerBlock_q5jeyk(ListenerTrampoline_7 block) NS_RETURNS_RETAINED {
  return ^void(unsigned long arg0, BOOL * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_7)(void * waiter, unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_7 _ObjectiveCBindings_wrapBlockingBlock_q5jeyk(
    BlockingTrampoline_7 block, BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned long arg0, BOOL * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ListenerTrampoline_8)(id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_8 _ObjectiveCBindings_wrapListenerBlock_rnu2c5(ListenerTrampoline_8 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^BlockingTrampoline_8)(void * waiter, id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_8 _ObjectiveCBindings_wrapBlockingBlock_rnu2c5(
    BlockingTrampoline_8 block, BlockingTrampoline_8 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^ListenerTrampoline_9)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_9 _ObjectiveCBindings_wrapListenerBlock_ovsamd(ListenerTrampoline_9 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^BlockingTrampoline_9)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_9 _ObjectiveCBindings_wrapBlockingBlock_ovsamd(
    BlockingTrampoline_9 block, BlockingTrampoline_9 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^ProtocolTrampoline_9)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^ListenerTrampoline_10)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_10 _ObjectiveCBindings_wrapListenerBlock_18v1jvf(ListenerTrampoline_10 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^BlockingTrampoline_10)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_10 _ObjectiveCBindings_wrapBlockingBlock_18v1jvf(
    BlockingTrampoline_10 block, BlockingTrampoline_10 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^ProtocolTrampoline_10)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_11)(void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_11 _ObjectiveCBindings_wrapListenerBlock_1q8ia8l(ListenerTrampoline_11 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct _NSRange arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_11)(void * waiter, void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_11 _ObjectiveCBindings_wrapBlockingBlock_1q8ia8l(
    BlockingTrampoline_11 block, BlockingTrampoline_11 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct _NSRange arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ListenerTrampoline_12)(void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_12 _ObjectiveCBindings_wrapListenerBlock_hoampi(ListenerTrampoline_12 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, NSStreamEvent arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^BlockingTrampoline_12)(void * waiter, void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_12 _ObjectiveCBindings_wrapBlockingBlock_hoampi(
    BlockingTrampoline_12 block, BlockingTrampoline_12 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, NSStreamEvent arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^ProtocolTrampoline_11)(void * sel, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_protocolTrampoline_hoampi(id target, void * sel, id arg1, NSStreamEvent arg2) {
  return ((ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_13)(void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_13 _ObjectiveCBindings_wrapListenerBlock_1sr3ozv(ListenerTrampoline_13 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, void * arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^BlockingTrampoline_13)(void * waiter, void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_13 _ObjectiveCBindings_wrapBlockingBlock_1sr3ozv(
    BlockingTrampoline_13 block, BlockingTrampoline_13 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, void * arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^ProtocolTrampoline_12)(void * sel, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_protocolTrampoline_1sr3ozv(id target, void * sel, id arg1, id arg2, id arg3, void * arg4) {
  return ((ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_14)(void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_14 _ObjectiveCBindings_wrapListenerBlock_zuf90e(ListenerTrampoline_14 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_14)(void * waiter, void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_14 _ObjectiveCBindings_wrapBlockingBlock_zuf90e(
    BlockingTrampoline_14 block, BlockingTrampoline_14 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ListenerTrampoline_15)(id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_15 _ObjectiveCBindings_wrapListenerBlock_1p9ui4q(ListenerTrampoline_15 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, unsigned long arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_15)(void * waiter, id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_15 _ObjectiveCBindings_wrapBlockingBlock_1p9ui4q(
    BlockingTrampoline_15 block, BlockingTrampoline_15 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, unsigned long arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^ListenerTrampoline_16)(id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_16 _ObjectiveCBindings_wrapListenerBlock_1o83rbn(ListenerTrampoline_16 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^BlockingTrampoline_16)(void * waiter, id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_16 _ObjectiveCBindings_wrapBlockingBlock_1o83rbn(
    BlockingTrampoline_16 block, BlockingTrampoline_16 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^ListenerTrampoline_17)(unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_17 _ObjectiveCBindings_wrapListenerBlock_vhbh5h(ListenerTrampoline_17 block) NS_RETURNS_RETAINED {
  return ^void(unsigned short * arg0, unsigned long arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_17)(void * waiter, unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_17 _ObjectiveCBindings_wrapBlockingBlock_vhbh5h(
    BlockingTrampoline_17 block, BlockingTrampoline_17 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned short * arg0, unsigned long arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef id  (^ProtocolTrampoline_13)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_13)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_14)(void * sel, id arg1, id arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_protocolTrampoline_10z9f5k(id target, void * sel, id arg1, id arg2, id * arg3) {
  return ((ProtocolTrampoline_14)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^ProtocolTrampoline_15)(void * sel, struct _NSZone * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_protocolTrampoline_18nsem0(id target, void * sel, struct _NSZone * arg1) {
  return ((ProtocolTrampoline_15)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_16)(void * sel, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_protocolTrampoline_50as9u(id target, void * sel, struct objc_selector * arg1) {
  return ((ProtocolTrampoline_16)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_17)(void * sel, struct objc_selector * arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_protocolTrampoline_1mllhpc(id target, void * sel, struct objc_selector * arg1, id arg2) {
  return ((ProtocolTrampoline_17)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^ProtocolTrampoline_18)(void * sel, struct objc_selector * arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_protocolTrampoline_c7gk2u(id target, void * sel, struct objc_selector * arg1, id arg2, id arg3) {
  return ((ProtocolTrampoline_18)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

Protocol* _ObjectiveCBindings_Observer(void) { return @protocol(Observer); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
