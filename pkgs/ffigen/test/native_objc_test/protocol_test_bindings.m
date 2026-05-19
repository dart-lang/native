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

typedef void  (^_ListenerTrampoline)(void * arg0, int32_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _13hhotk_wrapListenerBlock_1pbq496(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, int32_t arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter, void * arg0, int32_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _13hhotk_wrapBlockingBlock_1pbq496(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, int32_t arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_4)(void * sel, int32_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _13hhotk_protocolTrampoline_1pbq496(id target, void * sel, int32_t arg1) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_1)(void * arg0, int32_t * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _13hhotk_wrapListenerBlock_8r9qkg(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, int32_t * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, void * arg0, int32_t * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _13hhotk_wrapBlockingBlock_8r9qkg(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, int32_t * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_5)(void * sel, int32_t * arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _13hhotk_protocolTrampoline_8r9qkg(id target, void * sel, int32_t * arg1) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_6)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _13hhotk_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((_ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _13hhotk_SecondaryProtocol(void) { return @protocol(SecondaryProtocol); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _13hhotk_UnusedProtocol(void) { return @protocol(UnusedProtocol); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
