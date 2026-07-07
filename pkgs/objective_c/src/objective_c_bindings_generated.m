#include <stdint.h>
#include <stdlib.h>
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

// Duplicated from package:objective_c's objective_c.h. Keep in sync.
typedef struct _DOBJC_ListenerInvocation {
  void *block;
  void (*dispose)(struct _DOBJC_ListenerInvocation *invocation);
} DOBJC_ListenerInvocation;

typedef struct {
  int64_t version;
  void* (*newWaiter)(void);
  void (*awaitWaiter)(void*);
  void* (*currentIsolate)(void);
  void (*enterIsolate)(void*);
  void (*exitIsolate)(void);
  int64_t (*getMainPortId)(void);
  bool (*getCurrentThreadOwnsIsolate)(int64_t);
  // Version 2 additions:
  void (*postListenerInvocation)(void*, DOBJC_ListenerInvocation*);
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
_ListenerTrampoline _1wx624s_wrapListenerBlock_1pl9qdv(
    _ListenerTrampoline block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void() {
    DOBJC_ListenerInvocation *invocation =
        (DOBJC_ListenerInvocation *)malloc(sizeof(DOBJC_ListenerInvocation));
    invocation->dispose = NULL;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1wx624s_wrapBlockingBlock_1pl9qdv(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(), {
    objc_retainBlock(block);
    block(nil);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void *arg0;
  void *arg1;
} _1wx624s_ListenerArgs_pfv6jd;

static void _1wx624s_ListenerArgs_pfv6jd_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_pfv6jd *args = (_1wx624s_ListenerArgs_pfv6jd *)invocation;
  (void)(__bridge_transfer id)(args->arg0);
  (void)(__bridge_transfer id)(args->arg1);
}

typedef void  (^_ListenerTrampoline_1)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx624s_wrapListenerBlock_pfv6jd(
    _ListenerTrampoline_1 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0, id arg1) {
    _1wx624s_ListenerArgs_pfv6jd *args = (_1wx624s_ListenerArgs_pfv6jd *)malloc(sizeof(_1wx624s_ListenerArgs_pfv6jd));
    args->invocation.dispose = &_1wx624s_ListenerArgs_pfv6jd_dispose;
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    args->arg1 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg1));
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx624s_wrapBlockingBlock_pfv6jd(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void *arg0;
  void *arg1;
  void *arg2;
} _1wx624s_ListenerArgs_1b3bb6a;

static void _1wx624s_ListenerArgs_1b3bb6a_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_1b3bb6a *args = (_1wx624s_ListenerArgs_1b3bb6a *)invocation;
  (void)(__bridge_transfer id)(args->arg0);
  (void)(__bridge_transfer id)(args->arg1);
  (void)(__bridge_transfer id)(args->arg2);
}

typedef void  (^_ListenerTrampoline_2)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx624s_wrapListenerBlock_1b3bb6a(
    _ListenerTrampoline_2 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0, id arg1, id arg2) {
    _1wx624s_ListenerArgs_1b3bb6a *args = (_1wx624s_ListenerArgs_1b3bb6a *)malloc(sizeof(_1wx624s_ListenerArgs_1b3bb6a));
    args->invocation.dispose = &_1wx624s_ListenerArgs_1b3bb6a_dispose;
    args->arg0 = (__bridge void*)(objc_retainBlock(arg0));
    args->arg1 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg1));
    args->arg2 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg2));
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx624s_wrapBlockingBlock_1b3bb6a(
    _BlockingTrampoline_2 block, _BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  struct _NSRange arg0;
  BOOL * arg1;
} _1wx624s_ListenerArgs_zkjmn1;

typedef void  (^_ListenerTrampoline_3)(struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx624s_wrapListenerBlock_zkjmn1(
    _ListenerTrampoline_3 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(struct _NSRange arg0, BOOL * arg1) {
    _1wx624s_ListenerArgs_zkjmn1 *args = (_1wx624s_ListenerArgs_zkjmn1 *)malloc(sizeof(_1wx624s_ListenerArgs_zkjmn1));
    args->invocation.dispose = NULL;
    args->arg0 = arg0;
    args->arg1 = arg1;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx624s_wrapBlockingBlock_zkjmn1(
    _BlockingTrampoline_3 block, _BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct _NSRange arg0, BOOL * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void *arg0;
  struct _NSRange arg1;
  struct _NSRange arg2;
  BOOL * arg3;
} _1wx624s_ListenerArgs_lmc3p5;

static void _1wx624s_ListenerArgs_lmc3p5_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_lmc3p5 *args = (_1wx624s_ListenerArgs_lmc3p5 *)invocation;
  (void)(__bridge_transfer id)(args->arg0);
}

typedef void  (^_ListenerTrampoline_4)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx624s_wrapListenerBlock_lmc3p5(
    _ListenerTrampoline_4 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    _1wx624s_ListenerArgs_lmc3p5 *args = (_1wx624s_ListenerArgs_lmc3p5 *)malloc(sizeof(_1wx624s_ListenerArgs_lmc3p5));
    args->invocation.dispose = &_1wx624s_ListenerArgs_lmc3p5_dispose;
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    args->arg1 = arg1;
    args->arg2 = arg2;
    args->arg3 = arg3;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx624s_wrapBlockingBlock_lmc3p5(
    _BlockingTrampoline_4 block, _BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void *arg0;
  BOOL * arg1;
} _1wx624s_ListenerArgs_t8l8el;

static void _1wx624s_ListenerArgs_t8l8el_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_t8l8el *args = (_1wx624s_ListenerArgs_t8l8el *)invocation;
  (void)(__bridge_transfer id)(args->arg0);
}

typedef void  (^_ListenerTrampoline_5)(id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx624s_wrapListenerBlock_t8l8el(
    _ListenerTrampoline_5 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0, BOOL * arg1) {
    _1wx624s_ListenerArgs_t8l8el *args = (_1wx624s_ListenerArgs_t8l8el *)malloc(sizeof(_1wx624s_ListenerArgs_t8l8el));
    args->invocation.dispose = &_1wx624s_ListenerArgs_t8l8el_dispose;
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    args->arg1 = arg1;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx624s_wrapBlockingBlock_t8l8el(
    _BlockingTrampoline_5 block, _BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL * arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void *arg0;
} _1wx624s_ListenerArgs_xtuoz7;

static void _1wx624s_ListenerArgs_xtuoz7_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_xtuoz7 *args = (_1wx624s_ListenerArgs_xtuoz7 *)invocation;
  (void)(__bridge_transfer id)(args->arg0);
}

typedef void  (^_ListenerTrampoline_6)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx624s_wrapListenerBlock_xtuoz7(
    _ListenerTrampoline_6 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0) {
    _1wx624s_ListenerArgs_xtuoz7 *args = (_1wx624s_ListenerArgs_xtuoz7 *)malloc(sizeof(_1wx624s_ListenerArgs_xtuoz7));
    args->invocation.dispose = &_1wx624s_ListenerArgs_xtuoz7_dispose;
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx624s_wrapBlockingBlock_xtuoz7(
    _BlockingTrampoline_6 block, _BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0));
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  unsigned long arg0;
  BOOL * arg1;
} _1wx624s_ListenerArgs_q5jeyk;

typedef void  (^_ListenerTrampoline_7)(unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx624s_wrapListenerBlock_q5jeyk(
    _ListenerTrampoline_7 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(unsigned long arg0, BOOL * arg1) {
    _1wx624s_ListenerArgs_q5jeyk *args = (_1wx624s_ListenerArgs_q5jeyk *)malloc(sizeof(_1wx624s_ListenerArgs_q5jeyk));
    args->invocation.dispose = NULL;
    args->arg0 = arg0;
    args->arg1 = arg1;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx624s_wrapBlockingBlock_q5jeyk(
    _BlockingTrampoline_7 block, _BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned long arg0, BOOL * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void *arg0;
  BOOL arg1;
  void *arg2;
} _1wx624s_ListenerArgs_rnu2c5;

static void _1wx624s_ListenerArgs_rnu2c5_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_rnu2c5 *args = (_1wx624s_ListenerArgs_rnu2c5 *)invocation;
  (void)(__bridge_transfer id)(args->arg0);
  (void)(__bridge_transfer id)(args->arg2);
}

typedef void  (^_ListenerTrampoline_8)(id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx624s_wrapListenerBlock_rnu2c5(
    _ListenerTrampoline_8 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0, BOOL arg1, id arg2) {
    _1wx624s_ListenerArgs_rnu2c5 *args = (_1wx624s_ListenerArgs_rnu2c5 *)malloc(sizeof(_1wx624s_ListenerArgs_rnu2c5));
    args->invocation.dispose = &_1wx624s_ListenerArgs_rnu2c5_dispose;
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    args->arg1 = arg1;
    args->arg2 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg2));
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_8)(void * waiter, id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx624s_wrapBlockingBlock_rnu2c5(
    _BlockingTrampoline_8 block, _BlockingTrampoline_8 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void * arg0;
} _1wx624s_ListenerArgs_ovsamd;

typedef void  (^_ListenerTrampoline_9)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx624s_wrapListenerBlock_ovsamd(
    _ListenerTrampoline_9 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(void * arg0) {
    _1wx624s_ListenerArgs_ovsamd *args = (_1wx624s_ListenerArgs_ovsamd *)malloc(sizeof(_1wx624s_ListenerArgs_ovsamd));
    args->invocation.dispose = NULL;
    args->arg0 = arg0;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_9)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx624s_wrapBlockingBlock_ovsamd(
    _BlockingTrampoline_9 block, _BlockingTrampoline_9 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ProtocolTrampoline_9)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((_ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void * arg0;
  void *arg1;
} _1wx624s_ListenerArgs_18v1jvf;

static void _1wx624s_ListenerArgs_18v1jvf_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_18v1jvf *args = (_1wx624s_ListenerArgs_18v1jvf *)invocation;
  (void)(__bridge_transfer id)(args->arg1);
}

typedef void  (^_ListenerTrampoline_10)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx624s_wrapListenerBlock_18v1jvf(
    _ListenerTrampoline_10 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(void * arg0, id arg1) {
    _1wx624s_ListenerArgs_18v1jvf *args = (_1wx624s_ListenerArgs_18v1jvf *)malloc(sizeof(_1wx624s_ListenerArgs_18v1jvf));
    args->invocation.dispose = &_1wx624s_ListenerArgs_18v1jvf_dispose;
    args->arg0 = arg0;
    args->arg1 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg1));
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_10)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx624s_wrapBlockingBlock_18v1jvf(
    _BlockingTrampoline_10 block, _BlockingTrampoline_10 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ProtocolTrampoline_10)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void * arg0;
  struct _NSRange arg1;
  BOOL * arg2;
} _1wx624s_ListenerArgs_1q8ia8l;

typedef void  (^_ListenerTrampoline_11)(void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx624s_wrapListenerBlock_1q8ia8l(
    _ListenerTrampoline_11 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(void * arg0, struct _NSRange arg1, BOOL * arg2) {
    _1wx624s_ListenerArgs_1q8ia8l *args = (_1wx624s_ListenerArgs_1q8ia8l *)malloc(sizeof(_1wx624s_ListenerArgs_1q8ia8l));
    args->invocation.dispose = NULL;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_11)(void * waiter, void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx624s_wrapBlockingBlock_1q8ia8l(
    _BlockingTrampoline_11 block, _BlockingTrampoline_11 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct _NSRange arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void * arg0;
  void *arg1;
  NSStreamEvent arg2;
} _1wx624s_ListenerArgs_hoampi;

static void _1wx624s_ListenerArgs_hoampi_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_hoampi *args = (_1wx624s_ListenerArgs_hoampi *)invocation;
  (void)(__bridge_transfer id)(args->arg1);
}

typedef void  (^_ListenerTrampoline_12)(void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx624s_wrapListenerBlock_hoampi(
    _ListenerTrampoline_12 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(void * arg0, id arg1, NSStreamEvent arg2) {
    _1wx624s_ListenerArgs_hoampi *args = (_1wx624s_ListenerArgs_hoampi *)malloc(sizeof(_1wx624s_ListenerArgs_hoampi));
    args->invocation.dispose = &_1wx624s_ListenerArgs_hoampi_dispose;
    args->arg0 = arg0;
    args->arg1 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg1));
    args->arg2 = arg2;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_12)(void * waiter, void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx624s_wrapBlockingBlock_hoampi(
    _BlockingTrampoline_12 block, _BlockingTrampoline_12 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, NSStreamEvent arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_11)(void * sel, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_hoampi(id target, void * sel, id arg1, NSStreamEvent arg2) {
  return ((_ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void * arg0;
  void *arg1;
  void *arg2;
  void *arg3;
  void * arg4;
} _1wx624s_ListenerArgs_1sr3ozv;

static void _1wx624s_ListenerArgs_1sr3ozv_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_1sr3ozv *args = (_1wx624s_ListenerArgs_1sr3ozv *)invocation;
  (void)(__bridge_transfer id)(args->arg1);
  (void)(__bridge_transfer id)(args->arg2);
  (void)(__bridge_transfer id)(args->arg3);
}

typedef void  (^_ListenerTrampoline_13)(void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx624s_wrapListenerBlock_1sr3ozv(
    _ListenerTrampoline_13 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(void * arg0, id arg1, id arg2, id arg3, void * arg4) {
    _1wx624s_ListenerArgs_1sr3ozv *args = (_1wx624s_ListenerArgs_1sr3ozv *)malloc(sizeof(_1wx624s_ListenerArgs_1sr3ozv));
    args->invocation.dispose = &_1wx624s_ListenerArgs_1sr3ozv_dispose;
    args->arg0 = arg0;
    args->arg1 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg1));
    args->arg2 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg2));
    args->arg3 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg3));
    args->arg4 = arg4;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_13)(void * waiter, void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx624s_wrapBlockingBlock_1sr3ozv(
    _BlockingTrampoline_13 block, _BlockingTrampoline_13 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, void * arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^_ProtocolTrampoline_12)(void * sel, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_1sr3ozv(id target, void * sel, id arg1, id arg2, id arg3, void * arg4) {
  return ((_ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void * arg0;
  unsigned long arg1;
} _1wx624s_ListenerArgs_zuf90e;

typedef void  (^_ListenerTrampoline_14)(void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx624s_wrapListenerBlock_zuf90e(
    _ListenerTrampoline_14 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(void * arg0, unsigned long arg1) {
    _1wx624s_ListenerArgs_zuf90e *args = (_1wx624s_ListenerArgs_zuf90e *)malloc(sizeof(_1wx624s_ListenerArgs_zuf90e));
    args->invocation.dispose = NULL;
    args->arg0 = arg0;
    args->arg1 = arg1;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_14)(void * waiter, void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx624s_wrapBlockingBlock_zuf90e(
    _BlockingTrampoline_14 block, _BlockingTrampoline_14 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void *arg0;
  unsigned long arg1;
  BOOL * arg2;
} _1wx624s_ListenerArgs_1p9ui4q;

static void _1wx624s_ListenerArgs_1p9ui4q_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_1p9ui4q *args = (_1wx624s_ListenerArgs_1p9ui4q *)invocation;
  (void)(__bridge_transfer id)(args->arg0);
}

typedef void  (^_ListenerTrampoline_15)(id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx624s_wrapListenerBlock_1p9ui4q(
    _ListenerTrampoline_15 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0, unsigned long arg1, BOOL * arg2) {
    _1wx624s_ListenerArgs_1p9ui4q *args = (_1wx624s_ListenerArgs_1p9ui4q *)malloc(sizeof(_1wx624s_ListenerArgs_1p9ui4q));
    args->invocation.dispose = &_1wx624s_ListenerArgs_1p9ui4q_dispose;
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    args->arg1 = arg1;
    args->arg2 = arg2;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_15)(void * waiter, id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx624s_wrapBlockingBlock_1p9ui4q(
    _BlockingTrampoline_15 block, _BlockingTrampoline_15 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, unsigned long arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  void *arg0;
  void *arg1;
  BOOL * arg2;
} _1wx624s_ListenerArgs_1o83rbn;

static void _1wx624s_ListenerArgs_1o83rbn_dispose(DOBJC_ListenerInvocation *invocation) {
  _1wx624s_ListenerArgs_1o83rbn *args = (_1wx624s_ListenerArgs_1o83rbn *)invocation;
  (void)(__bridge_transfer id)(args->arg0);
  (void)(__bridge_transfer id)(args->arg1);
}

typedef void  (^_ListenerTrampoline_16)(id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx624s_wrapListenerBlock_1o83rbn(
    _ListenerTrampoline_16 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(id arg0, id arg1, BOOL * arg2) {
    _1wx624s_ListenerArgs_1o83rbn *args = (_1wx624s_ListenerArgs_1o83rbn *)malloc(sizeof(_1wx624s_ListenerArgs_1o83rbn));
    args->invocation.dispose = &_1wx624s_ListenerArgs_1o83rbn_dispose;
    args->arg0 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg0));
    args->arg1 = (__bridge void*)((__bridge id)(__bridge_retained void*)(arg1));
    args->arg2 = arg2;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_16)(void * waiter, id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx624s_wrapBlockingBlock_1o83rbn(
    _BlockingTrampoline_16 block, _BlockingTrampoline_16 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef struct {
  DOBJC_ListenerInvocation invocation;
  unsigned short * arg0;
  unsigned long arg1;
} _1wx624s_ListenerArgs_vhbh5h;

typedef void  (^_ListenerTrampoline_17)(unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx624s_wrapListenerBlock_vhbh5h(
    _ListenerTrampoline_17 block, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  NSCAssert(ctx->version >= 2, @"package:objective_c is too old");
  return ^void(unsigned short * arg0, unsigned long arg1) {
    _1wx624s_ListenerArgs_vhbh5h *args = (_1wx624s_ListenerArgs_vhbh5h *)malloc(sizeof(_1wx624s_ListenerArgs_vhbh5h));
    args->invocation.dispose = NULL;
    args->arg0 = arg0;
    args->arg1 = arg1;
    DOBJC_ListenerInvocation *invocation = &args->invocation;
    ctx->postListenerInvocation((__bridge void*)block, invocation);
  };
}

typedef void  (^_BlockingTrampoline_17)(void * waiter, unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx624s_wrapBlockingBlock_vhbh5h(
    _BlockingTrampoline_17 block, _BlockingTrampoline_17 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned short * arg0, unsigned long arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef id  (^_ProtocolTrampoline_13)(void * sel, struct _NSZone * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_18nsem0(id target, void * sel, struct _NSZone * arg1) {
  return ((_ProtocolTrampoline_13)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_14)(void * sel, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_50as9u(id target, void * sel, struct objc_selector * arg1) {
  return ((_ProtocolTrampoline_14)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_15)(void * sel, struct objc_selector * arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_1mllhpc(id target, void * sel, struct objc_selector * arg1, id arg2) {
  return ((_ProtocolTrampoline_15)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_16)(void * sel, struct objc_selector * arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_c7gk2u(id target, void * sel, struct objc_selector * arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_16)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_17)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx624s_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_17)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_Observer(void) { return @protocol(Observer); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
