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


typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _18tji2r_wrapListenerBlock_1pl9qdv(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void() {
    objc_retainBlock(block);
    block();
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _18tji2r_wrapBlockingBlock_1pl9qdv(
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
  char dummy;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid;

void _18tji2r_ObjCBlock_ffiVoid_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid*)peer;

  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_portBlockInvoke(ObjCBlockImpl* block) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid));
  

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_1)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _18tji2r_wrapListenerBlock_xtuoz7(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0));
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _18tji2r_wrapBlockingBlock_xtuoz7(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
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
  void* arg0;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject;

void _18tji2r_ObjCBlock_ffiVoid_DummyObject_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject*)peer;
  if (args->arg0) CFRelease(args->arg0);
  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_DummyObject_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_DummyObject_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_DummyObject_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject));
  args->arg0 = (__bridge_retained void*)arg0;

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_DummyObject_portBlockInvoke_finalize);
}
typedef struct {
  id arg0;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject_1;

void _18tji2r_ObjCBlock_ffiVoid_DummyObject_1_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject_1* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject_1*)peer;

  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_DummyObject_1_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_DummyObject_1_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_DummyObject_1_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject_1* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_DummyObject_1));
  args->arg0 = arg0;

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_DummyObject_1_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_2)(int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _18tji2r_wrapListenerBlock_1bqef4y(_ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(int32_t arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _18tji2r_wrapBlockingBlock_1bqef4y(
    _BlockingTrampoline_2 block, _BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}
typedef struct {
  int32_t arg0;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32;

void _18tji2r_ObjCBlock_ffiVoid_Int32_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32*)peer;

  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_Int32_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_Int32_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_Int32_portBlockInvoke(ObjCBlockImpl* block, int32_t arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32));
  args->arg0 = arg0;

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_Int32_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_3)(int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _18tji2r_wrapListenerBlock_yhkuco(_ListenerTrampoline_3 block) NS_RETURNS_RETAINED {
  return ^void(int32_t * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _18tji2r_wrapBlockingBlock_yhkuco(
    _BlockingTrampoline_3 block, _BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}
typedef struct {
  int32_t * arg0;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_1;

void _18tji2r_ObjCBlock_ffiVoid_Int32_1_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_1* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_1*)peer;

  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_Int32_1_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_Int32_1_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_Int32_1_portBlockInvoke(ObjCBlockImpl* block, int32_t * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_1* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_1));
  args->arg0 = arg0;

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_Int32_1_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_4)(int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _18tji2r_wrapListenerBlock_li50va(_ListenerTrampoline_4 block) NS_RETURNS_RETAINED {
  return ^void(int32_t arg0, Vec4 arg1, char * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _18tji2r_wrapBlockingBlock_li50va(
    _BlockingTrampoline_4 block, _BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0, Vec4 arg1, char * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}
typedef struct {
  int32_t arg0;
  Vec4 arg1;
  char * arg2;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar;

void _18tji2r_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar*)peer;

  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar_portBlockInvoke(ObjCBlockImpl* block, int32_t arg0, Vec4 arg1, char * arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar));
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = arg2;

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_Int32_Vec4_ffiChar_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_5)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _18tji2r_wrapListenerBlock_f167m6(_ListenerTrampoline_5 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block(objc_retainBlock(arg0));
  };
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _18tji2r_wrapBlockingBlock_f167m6(
    _BlockingTrampoline_5 block, _BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0));
  });
}
typedef struct {
  void* arg0;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_IntBlock;

void _18tji2r_ObjCBlock_ffiVoid_IntBlock_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_IntBlock* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_IntBlock*)peer;
  if (args->arg0) CFRelease(args->arg0);
  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_IntBlock_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_IntBlock_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_IntBlock_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_IntBlock* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_IntBlock));
  args->arg0 = (__bridge void*)objc_retainBlock(arg0);

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_IntBlock_portBlockInvoke_finalize);
}
typedef struct {
  void* arg0;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_NSString;

void _18tji2r_ObjCBlock_ffiVoid_NSString_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_NSString* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_NSString*)peer;
  if (args->arg0) CFRelease(args->arg0);
  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_NSString_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_NSString_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_NSString_portBlockInvoke(ObjCBlockImpl* block, id arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_NSString* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_NSString));
  args->arg0 = (__bridge_retained void*)arg0;

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_NSString_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_6)(struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _18tji2r_wrapListenerBlock_ru30ue(_ListenerTrampoline_6 block) NS_RETURNS_RETAINED {
  return ^void(struct Vec2 arg0, Vec4 arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _18tji2r_wrapBlockingBlock_ru30ue(
    _BlockingTrampoline_6 block, _BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct Vec2 arg0, Vec4 arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}
typedef struct {
  struct Vec2 arg0;
  Vec4 arg1;
  void* arg2;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject;

void _18tji2r_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject*)peer;
  if (args->arg2) CFRelease(args->arg2);
  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject_portBlockInvoke(ObjCBlockImpl* block, struct Vec2 arg0, Vec4 arg1, id arg2) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject));
  args->arg0 = arg0;
  args->arg1 = arg1;
  args->arg2 = (__bridge_retained void*)arg2;

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_Vec2_Vec4_NSObject_portBlockInvoke_finalize);
}

typedef void  (^_ListenerTrampoline_7)(struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _18tji2r_wrapListenerBlock_1d9e4oe(_ListenerTrampoline_7 block) NS_RETURNS_RETAINED {
  return ^void(struct objc_selector * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _18tji2r_wrapBlockingBlock_1d9e4oe(
    _BlockingTrampoline_7 block, _BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct objc_selector * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}
typedef struct {
  struct objc_selector * arg0;
} _18tji2r_BlockArgs_ObjCBlock_ffiVoid_objcObjCSelector;

void _18tji2r_ObjCBlock_ffiVoid_objcObjCSelector_portBlockInvoke_free(void* peer) {
  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_objcObjCSelector* args = (_18tji2r_BlockArgs_ObjCBlock_ffiVoid_objcObjCSelector*)peer;

  free(args);
}

void _18tji2r_ObjCBlock_ffiVoid_objcObjCSelector_portBlockInvoke_finalize(void* isolate_callback_data, void* peer) {
  DOBJC_runOnMainThread(_18tji2r_ObjCBlock_ffiVoid_objcObjCSelector_portBlockInvoke_free, peer);
}

__attribute__((visibility("default"))) __attribute__((used))
void _18tji2r_ObjCBlock_ffiVoid_objcObjCSelector_portBlockInvoke(ObjCBlockImpl* block, struct objc_selector * arg0) {
  PortBlockTarget* target = (PortBlockTarget*)block->target;
  int64_t port_id = target->port_id;
  DOBJC_Context* ctx = target->ctx;

  _18tji2r_BlockArgs_ObjCBlock_ffiVoid_objcObjCSelector* args = calloc(1, sizeof(_18tji2r_BlockArgs_ObjCBlock_ffiVoid_objcObjCSelector));
  args->arg0 = arg0;

  ctx->postCObject(port_id, args, _18tji2r_ObjCBlock_ffiVoid_objcObjCSelector_portBlockInvoke_finalize);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
