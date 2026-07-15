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
  void (*invokeListenerPortBlock)(int64_t port, void*);
  void (*invokeBlockingPortBlock)(int64_t port, void*, void*);
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, TYPE, SIG, INVOKE_DIRECT, INVOKE_LISTENER)    \
  assert(ctx->version >= 1);                                                   \
  void* targetIsolate = ctx->currentIsolate();                                 \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();  \
  __block __weak TYPE weakSelfBlock = nil;                                     \
  TYPE strongSelfBlock = SIG {                                                 \
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
  };                                                                           \
  weakSelfBlock = strongSelfBlock;                                             \
  return strongSelfBlock;


@interface _18tji2r_BlockArgs_1pl9qdv : NSObject {
  @public
  id block;

} @end
@implementation _18tji2r_BlockArgs_1pl9qdv @end

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _18tji2r_wrapListenerBlock_1pl9qdv(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline weakSelfBlock = nil;
  _ListenerTrampoline strongSelfBlock = ^void() {
    _18tji2r_BlockArgs_1pl9qdv* args = [[_18tji2r_BlockArgs_1pl9qdv alloc] init];
    args->block = weakSelfBlock;

    ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
  };
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _18tji2r_wrapBlockingBlock_1pl9qdv(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline, ^void(), {
    _18tji2r_BlockArgs_1pl9qdv* args = [[_18tji2r_BlockArgs_1pl9qdv alloc] init];
    args->block = weakSelfBlock;

    directInvoke((__bridge_retained void*)args);
  }, {
    _18tji2r_BlockArgs_1pl9qdv* args = [[_18tji2r_BlockArgs_1pl9qdv alloc] init];
    args->block = weakSelfBlock;

    ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
  });
}

@interface _18tji2r_BlockArgs_xtuoz7$1 : NSObject {
  @public
  id block;
  id arg0;
} @end
@implementation _18tji2r_BlockArgs_xtuoz7$1 @end

typedef void  (^_ListenerTrampoline_1)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _18tji2r_wrapListenerBlock_xtuoz7(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  printf("zxcv: Native 1\n");
  __block __weak _ListenerTrampoline_1 weakSelfBlock = nil;
  _ListenerTrampoline_1 strongSelfBlock = ^void(id arg0) {
  printf("zxcv: Native 2\n");
    _18tji2r_BlockArgs_xtuoz7$1* args = [[_18tji2r_BlockArgs_xtuoz7$1 alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
  printf("zxcv: Native 3\n");
    ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
  printf("zxcv: Native 4\n");
  };
  weakSelfBlock = strongSelfBlock;
  printf("zxcv: Native 5\n");
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _18tji2r_wrapBlockingBlock_xtuoz7(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_1, ^void(id arg0), {
    _18tji2r_BlockArgs_xtuoz7$1* args = [[_18tji2r_BlockArgs_xtuoz7$1 alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    directInvoke((__bridge_retained void*)args);
  }, {
    _18tji2r_BlockArgs_xtuoz7$1* args = [[_18tji2r_BlockArgs_xtuoz7$1 alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
  });
}

@interface _18tji2r_BlockArgs_1bqef4y : NSObject {
  @public
  id block;
  int32_t arg0;
} @end
@implementation _18tji2r_BlockArgs_1bqef4y @end

typedef void  (^_ListenerTrampoline_2)(int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _18tji2r_wrapListenerBlock_1bqef4y(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_2 weakSelfBlock = nil;
  _ListenerTrampoline_2 strongSelfBlock = ^void(int32_t arg0) {
    _18tji2r_BlockArgs_1bqef4y* args = [[_18tji2r_BlockArgs_1bqef4y alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
  };
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, int32_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _18tji2r_wrapBlockingBlock_1bqef4y(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_2, ^void(int32_t arg0), {
    _18tji2r_BlockArgs_1bqef4y* args = [[_18tji2r_BlockArgs_1bqef4y alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    directInvoke((__bridge_retained void*)args);
  }, {
    _18tji2r_BlockArgs_1bqef4y* args = [[_18tji2r_BlockArgs_1bqef4y alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
  });
}

@interface _18tji2r_BlockArgs_yhkuco : NSObject {
  @public
  id block;
  int32_t * arg0;
} @end
@implementation _18tji2r_BlockArgs_yhkuco @end

typedef void  (^_ListenerTrampoline_3)(int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _18tji2r_wrapListenerBlock_yhkuco(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_3 weakSelfBlock = nil;
  _ListenerTrampoline_3 strongSelfBlock = ^void(int32_t * arg0) {
    _18tji2r_BlockArgs_yhkuco* args = [[_18tji2r_BlockArgs_yhkuco alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
  };
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, int32_t * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _18tji2r_wrapBlockingBlock_yhkuco(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_3, ^void(int32_t * arg0), {
    _18tji2r_BlockArgs_yhkuco* args = [[_18tji2r_BlockArgs_yhkuco alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    directInvoke((__bridge_retained void*)args);
  }, {
    _18tji2r_BlockArgs_yhkuco* args = [[_18tji2r_BlockArgs_yhkuco alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
  });
}

@interface _18tji2r_BlockArgs_li50va : NSObject {
  @public
  id block;
  int32_t arg0;
  Vec4 arg1;
  char * arg2;
} @end
@implementation _18tji2r_BlockArgs_li50va @end

typedef void  (^_ListenerTrampoline_4)(int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _18tji2r_wrapListenerBlock_li50va(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_4 weakSelfBlock = nil;
  _ListenerTrampoline_4 strongSelfBlock = ^void(int32_t arg0, Vec4 arg1, char * arg2) {
    _18tji2r_BlockArgs_li50va* args = [[_18tji2r_BlockArgs_li50va alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
  };
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, int32_t arg0, Vec4 arg1, char * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _18tji2r_wrapBlockingBlock_li50va(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_4, ^void(int32_t arg0, Vec4 arg1, char * arg2), {
    _18tji2r_BlockArgs_li50va* args = [[_18tji2r_BlockArgs_li50va alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    directInvoke((__bridge_retained void*)args);
  }, {
    _18tji2r_BlockArgs_li50va* args = [[_18tji2r_BlockArgs_li50va alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
  });
}

@interface _18tji2r_BlockArgs_f167m6 : NSObject {
  @public
  id block;
  id arg0;
} @end
@implementation _18tji2r_BlockArgs_f167m6 @end

typedef void  (^_ListenerTrampoline_5)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _18tji2r_wrapListenerBlock_f167m6(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_5 weakSelfBlock = nil;
  _ListenerTrampoline_5 strongSelfBlock = ^void(id arg0) {
    _18tji2r_BlockArgs_f167m6* args = [[_18tji2r_BlockArgs_f167m6 alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
  };
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _18tji2r_wrapBlockingBlock_f167m6(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_5, ^void(id arg0), {
    _18tji2r_BlockArgs_f167m6* args = [[_18tji2r_BlockArgs_f167m6 alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    directInvoke((__bridge_retained void*)args);
  }, {
    _18tji2r_BlockArgs_f167m6* args = [[_18tji2r_BlockArgs_f167m6 alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
  });
}

@interface _18tji2r_BlockArgs_ru30ue : NSObject {
  @public
  id block;
  struct Vec2 arg0;
  Vec4 arg1;
  id arg2;
} @end
@implementation _18tji2r_BlockArgs_ru30ue @end

typedef void  (^_ListenerTrampoline_6)(struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _18tji2r_wrapListenerBlock_ru30ue(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_6 weakSelfBlock = nil;
  _ListenerTrampoline_6 strongSelfBlock = ^void(struct Vec2 arg0, Vec4 arg1, id arg2) {
    _18tji2r_BlockArgs_ru30ue* args = [[_18tji2r_BlockArgs_ru30ue alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
  };
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, struct Vec2 arg0, Vec4 arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _18tji2r_wrapBlockingBlock_ru30ue(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_6, ^void(struct Vec2 arg0, Vec4 arg1, id arg2), {
    _18tji2r_BlockArgs_ru30ue* args = [[_18tji2r_BlockArgs_ru30ue alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    directInvoke((__bridge_retained void*)args);
  }, {
    _18tji2r_BlockArgs_ru30ue* args = [[_18tji2r_BlockArgs_ru30ue alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    args->arg1 = arg1;
    args->arg2 = arg2;
    ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
  });
}

@interface _18tji2r_BlockArgs_1d9e4oe : NSObject {
  @public
  id block;
  struct objc_selector * arg0;
} @end
@implementation _18tji2r_BlockArgs_1d9e4oe @end

typedef void  (^_ListenerTrampoline_7)(struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _18tji2r_wrapListenerBlock_1d9e4oe(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_7 weakSelfBlock = nil;
  _ListenerTrampoline_7 strongSelfBlock = ^void(struct objc_selector * arg0) {
    _18tji2r_BlockArgs_1d9e4oe* args = [[_18tji2r_BlockArgs_1d9e4oe alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
  };
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, struct objc_selector * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _18tji2r_wrapBlockingBlock_1d9e4oe(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_7, ^void(struct objc_selector * arg0), {
    _18tji2r_BlockArgs_1d9e4oe* args = [[_18tji2r_BlockArgs_1d9e4oe alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    directInvoke((__bridge_retained void*)args);
  }, {
    _18tji2r_BlockArgs_1d9e4oe* args = [[_18tji2r_BlockArgs_1d9e4oe alloc] init];
    args->block = weakSelfBlock;
    args->arg0 = arg0;
    ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
  });
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
