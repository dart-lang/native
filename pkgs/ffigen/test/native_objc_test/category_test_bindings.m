#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "category_test.h"
#import "category_test.h"

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

@interface _l3cf7j_BlockArgs_1ilrkog : NSObject {
  @public
  id block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _l3cf7j_BlockArgs_1ilrkog
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _l3cf7j_BlockArgs_1ilrkog_getArg0(void* peer) {
  return ((__bridge _l3cf7j_BlockArgs_1ilrkog*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _l3cf7j_BlockArgs_1ilrkog_getArg1(void* peer) {
  return ((__bridge _l3cf7j_BlockArgs_1ilrkog*)peer)->arg1;
}


void _l3cf7j_BlockArgs_1ilrkog_free(void* peer) {
  @autoreleasepool {
    _l3cf7j_BlockArgs_1ilrkog* args = (__bridge _l3cf7j_BlockArgs_1ilrkog*)peer;
    
    id argsObj = (__bridge_transfer id)peer;
  }
}

void _l3cf7j_BlockArgs_1ilrkog_finalize(void* isolate_callback_data, void* peer) {
  _l3cf7j_BlockArgs_1ilrkog* args = (__bridge _l3cf7j_BlockArgs_1ilrkog*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_l3cf7j_BlockArgs_1ilrkog_free, peer);
}

typedef void  (^_ListenerTrampoline)(id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _l3cf7j_1ilrkog_wrapPortBlock(id block, int64_t port_id, void* ctx) {
  DOBJC_Context* context = (DOBJC_Context*)ctx;
  return (void*)CFBridgingRetain((id)[^void(id arg0, id arg1) {
    _l3cf7j_BlockArgs_1ilrkog* args = [[_l3cf7j_BlockArgs_1ilrkog alloc] init];
    args->block = block;
    args->context = context;
    args->arg0 = arg0;
    args->arg1 = arg1;
    void* raw_args = (__bridge_retained void*)args;
    context->postCObject(port_id, raw_args, _l3cf7j_BlockArgs_1ilrkog_finalize);
  } copy]);
}
@interface _l3cf7j_BlockArgs_1ilrkog_blocking : NSObject {
  @public
  void* waiter;
  void* block;
  void* context;
  id  arg0;
  id  arg1;
}
@end

@implementation _l3cf7j_BlockArgs_1ilrkog_blocking
@end

__attribute__((visibility("default"))) __attribute__((used))
id  _l3cf7j_BlockArgs_1ilrkog_blocking_getArg0(void* peer) {
  return ((__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer)->arg0;
}

__attribute__((visibility("default"))) __attribute__((used))
id  _l3cf7j_BlockArgs_1ilrkog_blocking_getArg1(void* peer) {
  return ((__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer)->arg1;
}


__attribute__((visibility("default"))) __attribute__((used))
void _l3cf7j_BlockArgs_1ilrkog_blocking_free(void* peer) {
  @autoreleasepool {
    _l3cf7j_BlockArgs_1ilrkog_blocking* args = (__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer;
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

void _l3cf7j_BlockArgs_1ilrkog_blocking_finalize(void* isolate_callback_data, void* peer) {
  _l3cf7j_BlockArgs_1ilrkog_blocking* args = (__bridge _l3cf7j_BlockArgs_1ilrkog_blocking*)peer;
  ((DOBJC_Context*)args->context)->runOnMainThread(_l3cf7j_BlockArgs_1ilrkog_blocking_free, peer);
}

typedef void  (^_BlockingTrampoline)(void* block, id arg0, id arg1);

__attribute__((visibility("default"))) __attribute__((used))
void* _l3cf7j_1ilrkog_wrapPortBlock_blocking(id block, id listener_block, int64_t port_id, void* ctx) {
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
      ((_BlockingTrampoline)block)((__bridge void*)block, arg0, arg1);
      if (mayEnterIsolate) {
        context->exitIsolate();
      }
    } else {
      void* waiter = context->newWaiter();
      _l3cf7j_BlockArgs_1ilrkog_blocking* args = [[_l3cf7j_BlockArgs_1ilrkog_blocking alloc] init];
      args->block = (__bridge_retained void*)listener_block;
      args->waiter = waiter;
      args->context = context;
      args->arg0 = arg0;
      args->arg1 = arg1;
      void* raw_args = (__bridge_retained void*)args;
      context->postCObject(port_id, raw_args, _l3cf7j_BlockArgs_1ilrkog_blocking_finalize);
      context->awaitWaiter(waiter);
    }
  } copy]);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
