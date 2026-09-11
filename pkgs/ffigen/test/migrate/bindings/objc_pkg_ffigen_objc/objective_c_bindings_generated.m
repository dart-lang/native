#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "../../../../../objective_c/src/foundation.h"
#import "../../../../../objective_c/src/input_stream_adapter.h"
#import "../../../../../objective_c/src/ns_number.h"
#import "../../../../../objective_c/src/observer.h"
#import "../../../../../objective_c/src/protocol.h"

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

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx624s_Observer(void) { return @protocol(Observer); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
