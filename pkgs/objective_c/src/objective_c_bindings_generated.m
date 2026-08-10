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
  void (*invokeListenerPortBlock)(int64_t port, void*);
  void (*invokeBlockingPortBlock)(int64_t port, void*, void*);
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, TYPE, SIG, INVOKE_DIRECT, INVOKE_LISTENER)    \
  assert(ctx->version >= 1);                                                   \
  void* targetIsolate = ctx->currentIsolate();                                 \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();  \
  __block __weak TYPE weakSelfBlock = nil;                                     \
  TYPE strongSelfBlock = [SIG {                                                \
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
      TYPE selfRetain = [weakSelfBlock copy];                                  \
      INVOKE_LISTENER;                                                         \
      ctx->awaitWaiter(waiter);                                                \
      (void)selfRetain;                                                        \
    }                                                                          \
  } copy];                                                                     \
  weakSelfBlock = strongSelfBlock;                                             \
  return strongSelfBlock;


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

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_1pl9qdv : NSObject
@property (copy) id block;

@end
@implementation _1wx624s_BlockArgs_1pl9qdv
@end

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1wx624s_wrapListenerBlock_1pl9qdv(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline weakSelfBlock = nil;
  _ListenerTrampoline strongSelfBlock = [^void() {
    @autoreleasepool {
      _1wx624s_BlockArgs_1pl9qdv* args = [[_1wx624s_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1wx624s_wrapBlockingBlock_1pl9qdv(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline, ^void(), {
    @autoreleasepool {
      _1wx624s_BlockArgs_1pl9qdv* args = [[_1wx624s_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_1pl9qdv* args = [[_1wx624s_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_1o83rbn : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property (strong) id arg1;
@property BOOL * arg2;
@end
@implementation _1wx624s_BlockArgs_1o83rbn
@end

typedef void  (^_ListenerTrampoline_1)(id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx624s_wrapListenerBlock_1o83rbn(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_1 weakSelfBlock = nil;
  _ListenerTrampoline_1 strongSelfBlock = [^void(id arg0, id arg1, BOOL * arg2) {
    @autoreleasepool {
      _1wx624s_BlockArgs_1o83rbn* args = [[_1wx624s_BlockArgs_1o83rbn alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx624s_wrapBlockingBlock_1o83rbn(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_1, ^void(id arg0, id arg1, BOOL * arg2), {
    @autoreleasepool {
      _1wx624s_BlockArgs_1o83rbn* args = [[_1wx624s_BlockArgs_1o83rbn alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_1o83rbn* args = [[_1wx624s_BlockArgs_1o83rbn alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_pfv6jd : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property (strong) id arg1;
@end
@implementation _1wx624s_BlockArgs_pfv6jd
@end

typedef void  (^_ListenerTrampoline_2)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx624s_wrapListenerBlock_pfv6jd(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_2 weakSelfBlock = nil;
  _ListenerTrampoline_2 strongSelfBlock = [^void(id arg0, id arg1) {
    @autoreleasepool {
      _1wx624s_BlockArgs_pfv6jd* args = [[_1wx624s_BlockArgs_pfv6jd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx624s_wrapBlockingBlock_pfv6jd(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_2, ^void(id arg0, id arg1), {
    @autoreleasepool {
      _1wx624s_BlockArgs_pfv6jd* args = [[_1wx624s_BlockArgs_pfv6jd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_pfv6jd* args = [[_1wx624s_BlockArgs_pfv6jd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_1b3bb6a : NSObject
@property (copy) id block;
@property (copy) id arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@end
@implementation _1wx624s_BlockArgs_1b3bb6a
@end

typedef void  (^_ListenerTrampoline_3)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx624s_wrapListenerBlock_1b3bb6a(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_3 weakSelfBlock = nil;
  _ListenerTrampoline_3 strongSelfBlock = [^void(id arg0, id arg1, id arg2) {
    @autoreleasepool {
      _1wx624s_BlockArgs_1b3bb6a* args = [[_1wx624s_BlockArgs_1b3bb6a alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx624s_wrapBlockingBlock_1b3bb6a(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_3, ^void(id arg0, id arg1, id arg2), {
    @autoreleasepool {
      _1wx624s_BlockArgs_1b3bb6a* args = [[_1wx624s_BlockArgs_1b3bb6a alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_1b3bb6a* args = [[_1wx624s_BlockArgs_1b3bb6a alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_zkjmn1 : NSObject
@property (copy) id block;
@property struct _NSRange arg0;
@property BOOL * arg1;
@end
@implementation _1wx624s_BlockArgs_zkjmn1
@end

typedef void  (^_ListenerTrampoline_4)(struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx624s_wrapListenerBlock_zkjmn1(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_4 weakSelfBlock = nil;
  _ListenerTrampoline_4 strongSelfBlock = [^void(struct _NSRange arg0, BOOL * arg1) {
    @autoreleasepool {
      _1wx624s_BlockArgs_zkjmn1* args = [[_1wx624s_BlockArgs_zkjmn1 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx624s_wrapBlockingBlock_zkjmn1(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_4, ^void(struct _NSRange arg0, BOOL * arg1), {
    @autoreleasepool {
      _1wx624s_BlockArgs_zkjmn1* args = [[_1wx624s_BlockArgs_zkjmn1 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_zkjmn1* args = [[_1wx624s_BlockArgs_zkjmn1 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_lmc3p5 : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property struct _NSRange arg1;
@property struct _NSRange arg2;
@property BOOL * arg3;
@end
@implementation _1wx624s_BlockArgs_lmc3p5
@end

typedef void  (^_ListenerTrampoline_5)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx624s_wrapListenerBlock_lmc3p5(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_5 weakSelfBlock = nil;
  _ListenerTrampoline_5 strongSelfBlock = [^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    @autoreleasepool {
      _1wx624s_BlockArgs_lmc3p5* args = [[_1wx624s_BlockArgs_lmc3p5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx624s_wrapBlockingBlock_lmc3p5(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_5, ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3), {
    @autoreleasepool {
      _1wx624s_BlockArgs_lmc3p5* args = [[_1wx624s_BlockArgs_lmc3p5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_lmc3p5* args = [[_1wx624s_BlockArgs_lmc3p5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_t8l8el : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property BOOL * arg1;
@end
@implementation _1wx624s_BlockArgs_t8l8el
@end

typedef void  (^_ListenerTrampoline_6)(id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx624s_wrapListenerBlock_t8l8el(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_6 weakSelfBlock = nil;
  _ListenerTrampoline_6 strongSelfBlock = [^void(id arg0, BOOL * arg1) {
    @autoreleasepool {
      _1wx624s_BlockArgs_t8l8el* args = [[_1wx624s_BlockArgs_t8l8el alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx624s_wrapBlockingBlock_t8l8el(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_6, ^void(id arg0, BOOL * arg1), {
    @autoreleasepool {
      _1wx624s_BlockArgs_t8l8el* args = [[_1wx624s_BlockArgs_t8l8el alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_t8l8el* args = [[_1wx624s_BlockArgs_t8l8el alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_xtuoz7 : NSObject
@property (copy) id block;
@property (strong) id arg0;
@end
@implementation _1wx624s_BlockArgs_xtuoz7
@end

typedef void  (^_ListenerTrampoline_7)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx624s_wrapListenerBlock_xtuoz7(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_7 weakSelfBlock = nil;
  _ListenerTrampoline_7 strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _1wx624s_BlockArgs_xtuoz7* args = [[_1wx624s_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx624s_wrapBlockingBlock_xtuoz7(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_7, ^void(id arg0), {
    @autoreleasepool {
      _1wx624s_BlockArgs_xtuoz7* args = [[_1wx624s_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_xtuoz7* args = [[_1wx624s_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_q5jeyk : NSObject
@property (copy) id block;
@property unsigned long arg0;
@property BOOL * arg1;
@end
@implementation _1wx624s_BlockArgs_q5jeyk
@end

typedef void  (^_ListenerTrampoline_8)(unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx624s_wrapListenerBlock_q5jeyk(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_8 weakSelfBlock = nil;
  _ListenerTrampoline_8 strongSelfBlock = [^void(unsigned long arg0, BOOL * arg1) {
    @autoreleasepool {
      _1wx624s_BlockArgs_q5jeyk* args = [[_1wx624s_BlockArgs_q5jeyk alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_8)(void * waiter, unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx624s_wrapBlockingBlock_q5jeyk(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_8, ^void(unsigned long arg0, BOOL * arg1), {
    @autoreleasepool {
      _1wx624s_BlockArgs_q5jeyk* args = [[_1wx624s_BlockArgs_q5jeyk alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_q5jeyk* args = [[_1wx624s_BlockArgs_q5jeyk alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_rnu2c5 : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property BOOL arg1;
@property (strong) id arg2;
@end
@implementation _1wx624s_BlockArgs_rnu2c5
@end

typedef void  (^_ListenerTrampoline_9)(id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx624s_wrapListenerBlock_rnu2c5(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_9 weakSelfBlock = nil;
  _ListenerTrampoline_9 strongSelfBlock = [^void(id arg0, BOOL arg1, id arg2) {
    @autoreleasepool {
      _1wx624s_BlockArgs_rnu2c5* args = [[_1wx624s_BlockArgs_rnu2c5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_9)(void * waiter, id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx624s_wrapBlockingBlock_rnu2c5(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_9, ^void(id arg0, BOOL arg1, id arg2), {
    @autoreleasepool {
      _1wx624s_BlockArgs_rnu2c5* args = [[_1wx624s_BlockArgs_rnu2c5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_rnu2c5* args = [[_1wx624s_BlockArgs_rnu2c5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_ovsamd : NSObject
@property (copy) id block;
@property void * arg0;
@end
@implementation _1wx624s_BlockArgs_ovsamd
@end

typedef void  (^_ListenerTrampoline_10)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx624s_wrapListenerBlock_ovsamd(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_10 weakSelfBlock = nil;
  _ListenerTrampoline_10 strongSelfBlock = [^void(void * arg0) {
    @autoreleasepool {
      _1wx624s_BlockArgs_ovsamd* args = [[_1wx624s_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_10)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx624s_wrapBlockingBlock_ovsamd(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_10, ^void(void * arg0), {
    @autoreleasepool {
      _1wx624s_BlockArgs_ovsamd* args = [[_1wx624s_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_ovsamd* args = [[_1wx624s_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_9)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((_ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_18v1jvf : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@end
@implementation _1wx624s_BlockArgs_18v1jvf
@end

typedef void  (^_ListenerTrampoline_11)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx624s_wrapListenerBlock_18v1jvf(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_11 weakSelfBlock = nil;
  _ListenerTrampoline_11 strongSelfBlock = [^void(void * arg0, id arg1) {
    @autoreleasepool {
      _1wx624s_BlockArgs_18v1jvf* args = [[_1wx624s_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_11)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx624s_wrapBlockingBlock_18v1jvf(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_11, ^void(void * arg0, id arg1), {
    @autoreleasepool {
      _1wx624s_BlockArgs_18v1jvf* args = [[_1wx624s_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_18v1jvf* args = [[_1wx624s_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_10)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_1q8ia8l : NSObject
@property (copy) id block;
@property void * arg0;
@property struct _NSRange arg1;
@property BOOL * arg2;
@end
@implementation _1wx624s_BlockArgs_1q8ia8l
@end

typedef void  (^_ListenerTrampoline_12)(void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx624s_wrapListenerBlock_1q8ia8l(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_12 weakSelfBlock = nil;
  _ListenerTrampoline_12 strongSelfBlock = [^void(void * arg0, struct _NSRange arg1, BOOL * arg2) {
    @autoreleasepool {
      _1wx624s_BlockArgs_1q8ia8l* args = [[_1wx624s_BlockArgs_1q8ia8l alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_12)(void * waiter, void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx624s_wrapBlockingBlock_1q8ia8l(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_12, ^void(void * arg0, struct _NSRange arg1, BOOL * arg2), {
    @autoreleasepool {
      _1wx624s_BlockArgs_1q8ia8l* args = [[_1wx624s_BlockArgs_1q8ia8l alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_1q8ia8l* args = [[_1wx624s_BlockArgs_1q8ia8l alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_hoampi : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property NSStreamEvent arg2;
@end
@implementation _1wx624s_BlockArgs_hoampi
@end

typedef void  (^_ListenerTrampoline_13)(void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx624s_wrapListenerBlock_hoampi(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_13 weakSelfBlock = nil;
  _ListenerTrampoline_13 strongSelfBlock = [^void(void * arg0, id arg1, NSStreamEvent arg2) {
    @autoreleasepool {
      _1wx624s_BlockArgs_hoampi* args = [[_1wx624s_BlockArgs_hoampi alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_13)(void * waiter, void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx624s_wrapBlockingBlock_hoampi(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_13, ^void(void * arg0, id arg1, NSStreamEvent arg2), {
    @autoreleasepool {
      _1wx624s_BlockArgs_hoampi* args = [[_1wx624s_BlockArgs_hoampi alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_hoampi* args = [[_1wx624s_BlockArgs_hoampi alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_11)(void * sel, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_hoampi(id target, void * sel, id arg1, NSStreamEvent arg2) {
  return ((_ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_1sr3ozv : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (strong) id arg3;
@property void * arg4;
@end
@implementation _1wx624s_BlockArgs_1sr3ozv
@end

typedef void  (^_ListenerTrampoline_14)(void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx624s_wrapListenerBlock_1sr3ozv(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_14 weakSelfBlock = nil;
  _ListenerTrampoline_14 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3, void * arg4) {
    @autoreleasepool {
      _1wx624s_BlockArgs_1sr3ozv* args = [[_1wx624s_BlockArgs_1sr3ozv alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_14)(void * waiter, void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx624s_wrapBlockingBlock_1sr3ozv(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_14, ^void(void * arg0, id arg1, id arg2, id arg3, void * arg4), {
    @autoreleasepool {
      _1wx624s_BlockArgs_1sr3ozv* args = [[_1wx624s_BlockArgs_1sr3ozv alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_1sr3ozv* args = [[_1wx624s_BlockArgs_1sr3ozv alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_12)(void * sel, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_1sr3ozv(id target, void * sel, id arg1, id arg2, id arg3, void * arg4) {
  return ((_ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_zuf90e : NSObject
@property (copy) id block;
@property void * arg0;
@property unsigned long arg1;
@end
@implementation _1wx624s_BlockArgs_zuf90e
@end

typedef void  (^_ListenerTrampoline_15)(void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx624s_wrapListenerBlock_zuf90e(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_15 weakSelfBlock = nil;
  _ListenerTrampoline_15 strongSelfBlock = [^void(void * arg0, unsigned long arg1) {
    @autoreleasepool {
      _1wx624s_BlockArgs_zuf90e* args = [[_1wx624s_BlockArgs_zuf90e alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_15)(void * waiter, void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx624s_wrapBlockingBlock_zuf90e(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_15, ^void(void * arg0, unsigned long arg1), {
    @autoreleasepool {
      _1wx624s_BlockArgs_zuf90e* args = [[_1wx624s_BlockArgs_zuf90e alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_zuf90e* args = [[_1wx624s_BlockArgs_zuf90e alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_1p9ui4q : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property unsigned long arg1;
@property BOOL * arg2;
@end
@implementation _1wx624s_BlockArgs_1p9ui4q
@end

typedef void  (^_ListenerTrampoline_16)(id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx624s_wrapListenerBlock_1p9ui4q(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_16 weakSelfBlock = nil;
  _ListenerTrampoline_16 strongSelfBlock = [^void(id arg0, unsigned long arg1, BOOL * arg2) {
    @autoreleasepool {
      _1wx624s_BlockArgs_1p9ui4q* args = [[_1wx624s_BlockArgs_1p9ui4q alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_16)(void * waiter, id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx624s_wrapBlockingBlock_1p9ui4q(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_16, ^void(id arg0, unsigned long arg1, BOOL * arg2), {
    @autoreleasepool {
      _1wx624s_BlockArgs_1p9ui4q* args = [[_1wx624s_BlockArgs_1p9ui4q alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_1p9ui4q* args = [[_1wx624s_BlockArgs_1p9ui4q alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx624s_BlockArgs_vhbh5h : NSObject
@property (copy) id block;
@property unsigned short * arg0;
@property unsigned long arg1;
@end
@implementation _1wx624s_BlockArgs_vhbh5h
@end

typedef void  (^_ListenerTrampoline_17)(unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx624s_wrapListenerBlock_vhbh5h(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_17 weakSelfBlock = nil;
  _ListenerTrampoline_17 strongSelfBlock = [^void(unsigned short * arg0, unsigned long arg1) {
    @autoreleasepool {
      _1wx624s_BlockArgs_vhbh5h* args = [[_1wx624s_BlockArgs_vhbh5h alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_17)(void * waiter, unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx624s_wrapBlockingBlock_vhbh5h(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_17, ^void(unsigned short * arg0, unsigned long arg1), {
    @autoreleasepool {
      _1wx624s_BlockArgs_vhbh5h* args = [[_1wx624s_BlockArgs_vhbh5h alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx624s_BlockArgs_vhbh5h* args = [[_1wx624s_BlockArgs_vhbh5h alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
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
