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
    block();
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1wx624s_wrapBlockingBlock_1pl9qdv(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter);
  });
}
typedef struct {
  char dummy;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid;

void _1wx624s_ObjCBlock_ffiVoid_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_portBlockInvoke(ObjCBlockImpl* block) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid));
  

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_1)(id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx624s_wrapListenerBlock_1o83rbn(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, BOOL * arg2) {
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx624s_wrapBlockingBlock_1o83rbn(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, BOOL * arg2), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}
typedef struct {
  void* arg0;
  void* arg1;
  BOOL * arg2;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_KeyType_ObjectType_bool;

void _1wx624s_ObjCBlock_ffiVoid_KeyType_ObjectType_bool_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_KeyType_ObjectType_bool* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_KeyType_ObjectType_bool*)peer;
  CFRelease(args->arg0);
  CFRelease(args->arg1);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_KeyType_ObjectType_bool_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_KeyType_ObjectType_bool_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_KeyType_ObjectType_bool_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_KeyType_ObjectType_bool* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_KeyType_ObjectType_bool));
  args->arg0 = (__bridge_retained void*)arg0;
  args->arg1 = (__bridge_retained void*)arg1;
  args->arg2 = arg2;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_KeyType_ObjectType_bool_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_2)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx624s_wrapListenerBlock_pfv6jd(_ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx624s_wrapBlockingBlock_pfv6jd(
    _BlockingTrampoline_2 block, _BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  });
}
typedef struct {
  id arg0;
  id arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSData_NSError;

void _1wx624s_ObjCBlock_ffiVoid_NSData_NSError_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSData_NSError* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSData_NSError*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSData_NSError_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSData_NSError_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSData_NSError_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSData_NSError* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSData_NSError));
  args->arg0 = arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSData_NSError_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_3)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx624s_wrapListenerBlock_1b3bb6a(_ListenerTrampoline_3 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    block(objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx624s_wrapBlockingBlock_1b3bb6a(
    _BlockingTrampoline_3 block, _BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}
typedef struct {
  void* arg0;
  void* arg1;
  void* arg2;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary;

void _1wx624s_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary*)peer;
  CFRelease(args->arg0);
  CFRelease(args->arg1);
  CFRelease(args->arg2);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary));
  args->arg0 = (__bridge_retained void*)arg0;
  args->arg1 = (__bridge_retained void*)arg1;
  args->arg2 = (__bridge_retained void*)arg2;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSItemProviderCompletionHandler_objcObjCObjectImpl_NSDictionary_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_4)(struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx624s_wrapListenerBlock_zkjmn1(_ListenerTrampoline_4 block) NS_RETURNS_RETAINED {
  return ^void(struct _NSRange arg0, BOOL * arg1) {
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, struct _NSRange arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx624s_wrapBlockingBlock_zkjmn1(
    _BlockingTrampoline_4 block, _BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct _NSRange arg0, BOOL * arg1), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0, arg1);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}
typedef struct {
  struct _NSRange arg0;
  BOOL * arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSRange_bool;

void _1wx624s_ObjCBlock_ffiVoid_NSRange_bool_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSRange_bool* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSRange_bool*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSRange_bool_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSRange_bool_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSRange_bool_portBlockInvoke(ObjCBlockImpl* block, struct _NSRange arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSRange_bool* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSRange_bool));
  args->arg0 = arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSRange_bool_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_5)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx624s_wrapListenerBlock_lmc3p5(_ListenerTrampoline_5 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx624s_wrapBlockingBlock_lmc3p5(
    _BlockingTrampoline_5 block, _BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  });
}
typedef struct {
  id arg0;
  struct _NSRange arg1;
  struct _NSRange arg2;
  BOOL * arg3;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool;

void _1wx624s_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool_portBlockInvoke(ObjCBlockImpl* block, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool));
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;
  args->arg3 = arg3;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSString_NSRange_NSRange_bool_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_6)(id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx624s_wrapListenerBlock_t8l8el(_ListenerTrampoline_6 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL * arg1) {
    block((__bridge id)(__bridge_retained void*)(arg0), arg1);
  };
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx624s_wrapBlockingBlock_t8l8el(
    _BlockingTrampoline_6 block, _BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL * arg1), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  });
}
typedef struct {
  void* arg0;
  BOOL * arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_bool;

void _1wx624s_ObjCBlock_ffiVoid_NSString_bool_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_bool* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_bool*)peer;
  CFRelease(args->arg0);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSString_bool_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSString_bool_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSString_bool_portBlockInvoke(ObjCBlockImpl* block, id arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_bool* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSString_bool));
  args->arg0 = (__bridge_retained void*)arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSString_bool_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_7)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx624s_wrapListenerBlock_xtuoz7(_ListenerTrampoline_7 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    block((__bridge id)(__bridge_retained void*)(arg0));
  };
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx624s_wrapBlockingBlock_xtuoz7(
    _BlockingTrampoline_7 block, _BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0));
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0));
  });
}
typedef struct {
  void* arg0;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSTimer;

void _1wx624s_ObjCBlock_ffiVoid_NSTimer_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSTimer* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSTimer*)peer;
  CFRelease(args->arg0);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSTimer_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSTimer_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSTimer_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSTimer* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSTimer));
  args->arg0 = (__bridge_retained void*)arg0;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSTimer_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_8)(unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx624s_wrapListenerBlock_q5jeyk(_ListenerTrampoline_8 block) NS_RETURNS_RETAINED {
  return ^void(unsigned long arg0, BOOL * arg1) {
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_8)(void * waiter, unsigned long arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx624s_wrapBlockingBlock_q5jeyk(
    _BlockingTrampoline_8 block, _BlockingTrampoline_8 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned long arg0, BOOL * arg1), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0, arg1);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}
typedef struct {
  unsigned long arg0;
  BOOL * arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSUInteger_bool;

void _1wx624s_ObjCBlock_ffiVoid_NSUInteger_bool_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSUInteger_bool* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSUInteger_bool*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSUInteger_bool_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSUInteger_bool_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSUInteger_bool_portBlockInvoke(ObjCBlockImpl* block, unsigned long arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSUInteger_bool* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSUInteger_bool));
  args->arg0 = arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSUInteger_bool_portBlockInvoke_finalize);
}
typedef struct {
  id arg0;
  id arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_NSError;

void _1wx624s_ObjCBlock_ffiVoid_NSURL_NSError_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_NSError* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_NSError*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSURL_NSError_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSURL_NSError_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSURL_NSError_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_NSError* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_NSError));
  args->arg0 = arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSURL_NSError_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_9)(id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx624s_wrapListenerBlock_rnu2c5(_ListenerTrampoline_9 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, id arg2) {
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_9)(void * waiter, id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx624s_wrapBlockingBlock_rnu2c5(
    _BlockingTrampoline_9 block, _BlockingTrampoline_9 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1, id arg2), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}
typedef struct {
  id arg0;
  BOOL arg1;
  id arg2;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_bool_NSError;

void _1wx624s_ObjCBlock_ffiVoid_NSURL_bool_NSError_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_bool_NSError* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_bool_NSError*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_NSURL_bool_NSError_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_NSURL_bool_NSError_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_NSURL_bool_NSError_portBlockInvoke(ObjCBlockImpl* block, id arg0, BOOL arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_bool_NSError* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_NSURL_bool_NSError));
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_NSURL_bool_NSError_portBlockInvoke_finalize);
}
typedef struct {
  void* arg0;
  BOOL * arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ObjectType_bool;

void _1wx624s_ObjCBlock_ffiVoid_ObjectType_bool_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ObjectType_bool* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ObjectType_bool*)peer;
  CFRelease(args->arg0);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_ObjectType_bool_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_ObjectType_bool_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_ObjectType_bool_portBlockInvoke(ObjCBlockImpl* block, id arg0, BOOL * arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ObjectType_bool* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ObjectType_bool));
  args->arg0 = (__bridge_retained void*)arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_ObjectType_bool_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_10)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx624s_wrapListenerBlock_ovsamd(_ListenerTrampoline_10 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_10)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx624s_wrapBlockingBlock_ovsamd(
    _BlockingTrampoline_10 block, _BlockingTrampoline_10 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0);
  });
}
typedef struct {
  void * arg0;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid;

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_ffiVoid_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_portBlockInvoke(ObjCBlockImpl* block, void * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid));
  args->arg0 = arg0;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_ffiVoid_portBlockInvoke_finalize);
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
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_11)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx624s_wrapBlockingBlock_18v1jvf(
    _BlockingTrampoline_11 block, _BlockingTrampoline_11 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}
typedef struct {
  void * arg0;
  void* arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSCoder;

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSCoder_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSCoder* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSCoder*)peer;
  CFRelease(args->arg1);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSCoder_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSCoder_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSCoder_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSCoder* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSCoder));
  args->arg0 = arg0;
  args->arg1 = (__bridge_retained void*)arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSCoder_portBlockInvoke_finalize);
}

typedef void  (^_ProtocolTrampoline_10)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx624s_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}
typedef struct {
  void * arg0;
  void* arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage;

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage*)peer;
  CFRelease(args->arg1);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage));
  args->arg0 = arg0;
  args->arg1 = (__bridge_retained void*)arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSPortMessage_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_12)(void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx624s_wrapListenerBlock_1q8ia8l(_ListenerTrampoline_12 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct _NSRange arg1, BOOL * arg2) {
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_12)(void * waiter, void * arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx624s_wrapBlockingBlock_1q8ia8l(
    _BlockingTrampoline_12 block, _BlockingTrampoline_12 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct _NSRange arg1, BOOL * arg2), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0, arg1, arg2);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}
typedef struct {
  void * arg0;
  struct _NSRange arg1;
  BOOL * arg2;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool;

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool_portBlockInvoke(ObjCBlockImpl* block, void * arg0, struct _NSRange arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool));
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSRange_bool_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_13)(void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx624s_wrapListenerBlock_hoampi(_ListenerTrampoline_13 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, NSStreamEvent arg2) {
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_13)(void * waiter, void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx624s_wrapBlockingBlock_hoampi(
    _BlockingTrampoline_13 block, _BlockingTrampoline_13 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, NSStreamEvent arg2), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}
typedef struct {
  void * arg0;
  void* arg1;
  NSStreamEvent arg2;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent;

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent*)peer;
  CFRelease(args->arg1);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1, NSStreamEvent arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent));
  args->arg0 = arg0;
  args->arg1 = (__bridge_retained void*)arg1;
  args->arg2 = arg2;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSStream_NSStreamEvent_portBlockInvoke_finalize);
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
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^_BlockingTrampoline_14)(void * waiter, void * arg0, id arg1, id arg2, id arg3, void * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx624s_wrapBlockingBlock_1sr3ozv(
    _BlockingTrampoline_14 block, _BlockingTrampoline_14 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, void * arg4), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}
typedef struct {
  void * arg0;
  void* arg1;
  void* arg2;
  void* arg3;
  void * arg4;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid;

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid*)peer;
  CFRelease(args->arg1);
  CFRelease(args->arg2);
  CFRelease(args->arg3);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid_portBlockInvoke(ObjCBlockImpl* block, void * arg0, id arg1, id arg2, id arg3, void * arg4) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid));
  args->arg0 = arg0;
  args->arg1 = (__bridge_retained void*)arg1;
  args->arg2 = (__bridge_retained void*)arg2;
  args->arg3 = (__bridge_retained void*)arg3;
  args->arg4 = arg4;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSString_objcObjCObjectImpl_NSDictionary_ffiVoid_portBlockInvoke_finalize);
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
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_15)(void * waiter, void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx624s_wrapBlockingBlock_zuf90e(
    _BlockingTrampoline_15 block, _BlockingTrampoline_15 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0, arg1);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}
typedef struct {
  void * arg0;
  unsigned long arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSUInteger;

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSUInteger_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSUInteger* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSUInteger*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSUInteger_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSUInteger_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSUInteger_portBlockInvoke(ObjCBlockImpl* block, void * arg0, unsigned long arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSUInteger* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_ffiVoid_NSUInteger));
  args->arg0 = arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_ffiVoid_NSUInteger_portBlockInvoke_finalize);
}
typedef struct {
  id arg0;
  id arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError;

void _1wx624s_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError));
  args->arg0 = arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_idNSItemProviderReading_NSError_portBlockInvoke_finalize);
}
typedef struct {
  id arg0;
  id arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError;

void _1wx624s_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError));
  args->arg0 = arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_idNSItemProviderWriting_NSError_portBlockInvoke_finalize);
}
typedef struct {
  id arg0;
  void* arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSSecureCoding_NSError;

void _1wx624s_ObjCBlock_ffiVoid_idNSSecureCoding_NSError_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSSecureCoding_NSError* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSSecureCoding_NSError*)peer;
  CFRelease(args->arg1);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_idNSSecureCoding_NSError_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_idNSSecureCoding_NSError_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_idNSSecureCoding_NSError_portBlockInvoke(ObjCBlockImpl* block, id arg0, id arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSSecureCoding_NSError* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_idNSSecureCoding_NSError));
  args->arg0 = arg0;
  args->arg1 = (__bridge_retained void*)arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_idNSSecureCoding_NSError_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_16)(id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx624s_wrapListenerBlock_1p9ui4q(_ListenerTrampoline_16 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, unsigned long arg1, BOOL * arg2) {
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_16)(void * waiter, id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx624s_wrapBlockingBlock_1p9ui4q(
    _BlockingTrampoline_16 block, _BlockingTrampoline_16 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, unsigned long arg1, BOOL * arg2), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}
typedef struct {
  void* arg0;
  unsigned long arg1;
  BOOL * arg2;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool;

void _1wx624s_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool*)peer;
  CFRelease(args->arg0);
  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool_portBlockInvoke(ObjCBlockImpl* block, id arg0, unsigned long arg1, BOOL * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool));
  args->arg0 = (__bridge_retained void*)arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_objcObjCObjectImpl_ffiUnsignedLong_bool_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_17)(unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx624s_wrapListenerBlock_vhbh5h(_ListenerTrampoline_17 block) NS_RETURNS_RETAINED {
  return ^void(unsigned short * arg0, unsigned long arg1) {
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_17)(void * waiter, unsigned short * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx624s_wrapBlockingBlock_vhbh5h(
    _BlockingTrampoline_17 block, _BlockingTrampoline_17 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned short * arg0, unsigned long arg1), {
    CFRetain((__bridge CFTypeRef)block);
    block(nil, arg0, arg1);
  }, {
    CFRetain((__bridge CFTypeRef)listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}
typedef struct {
  unsigned short * arg0;
  unsigned long arg1;
} _1wx624s_BlockArgs_ObjCBlock_ffiVoid_unichar_NSUInteger;

void _1wx624s_ObjCBlock_ffiVoid_unichar_NSUInteger_portBlockInvoke_free(void* peer) {
  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_unichar_NSUInteger* args = (_1wx624s_BlockArgs_ObjCBlock_ffiVoid_unichar_NSUInteger*)peer;

  free(args);
}

void _1wx624s_ObjCBlock_ffiVoid_unichar_NSUInteger_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_1wx624s_ObjCBlock_ffiVoid_unichar_NSUInteger_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _1wx624s_ObjCBlock_ffiVoid_unichar_NSUInteger_portBlockInvoke(ObjCBlockImpl* block, unsigned short * arg0, unsigned long arg1) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _1wx624s_BlockArgs_ObjCBlock_ffiVoid_unichar_NSUInteger* args = malloc(sizeof(_1wx624s_BlockArgs_ObjCBlock_ffiVoid_unichar_NSUInteger));
  args->arg0 = arg0;
  args->arg1 = arg1;

  ctx->postCObject(port_id, args, _1wx624s_ObjCBlock_ffiVoid_unichar_NSUInteger_portBlockInvoke_finalize);
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
