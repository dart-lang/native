#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <AVFAudio/AVAudioPlayer.h>

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
Protocol* _1uu024u_AVAudioPlayerDelegate(void) { return @protocol(AVAudioPlayerDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_AVAudioSessionDelegate(void) { return @protocol(AVAudioSessionDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_CTAdaptiveImageProviding(void) { return @protocol(CTAdaptiveImageProviding); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSCacheDelegate(void) { return @protocol(NSCacheDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSConnectionDelegate(void) { return @protocol(NSConnectionDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSDecimalNumberBehaviors(void) { return @protocol(NSDecimalNumberBehaviors); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSDiscardableContent(void) { return @protocol(NSDiscardableContent); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSExtensionRequestHandling(void) { return @protocol(NSExtensionRequestHandling); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSFileManagerDelegate(void) { return @protocol(NSFileManagerDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSFilePresenter(void) { return @protocol(NSFilePresenter); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSKeyedArchiverDelegate(void) { return @protocol(NSKeyedArchiverDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSKeyedUnarchiverDelegate(void) { return @protocol(NSKeyedUnarchiverDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSLocking(void) { return @protocol(NSLocking); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSMachPortDelegate(void) { return @protocol(NSMachPortDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSMetadataQueryDelegate(void) { return @protocol(NSMetadataQueryDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSNetServiceBrowserDelegate(void) { return @protocol(NSNetServiceBrowserDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSNetServiceDelegate(void) { return @protocol(NSNetServiceDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSProgressReporting(void) { return @protocol(NSProgressReporting); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSSpellServerDelegate(void) { return @protocol(NSSpellServerDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLAuthenticationChallengeSender(void) { return @protocol(NSURLAuthenticationChallengeSender); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLConnectionDataDelegate(void) { return @protocol(NSURLConnectionDataDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLConnectionDelegate(void) { return @protocol(NSURLConnectionDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLConnectionDownloadDelegate(void) { return @protocol(NSURLConnectionDownloadDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLDownloadDelegate(void) { return @protocol(NSURLDownloadDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLHandleClient(void) { return @protocol(NSURLHandleClient); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLProtocolClient(void) { return @protocol(NSURLProtocolClient); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLSessionDataDelegate(void) { return @protocol(NSURLSessionDataDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLSessionDelegate(void) { return @protocol(NSURLSessionDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLSessionDownloadDelegate(void) { return @protocol(NSURLSessionDownloadDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLSessionStreamDelegate(void) { return @protocol(NSURLSessionStreamDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLSessionTaskDelegate(void) { return @protocol(NSURLSessionTaskDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSURLSessionWebSocketDelegate(void) { return @protocol(NSURLSessionWebSocketDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSUserActivityDelegate(void) { return @protocol(NSUserActivityDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSUserNotificationCenterDelegate(void) { return @protocol(NSUserNotificationCenterDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSXMLParserDelegate(void) { return @protocol(NSXMLParserDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSXPCListenerDelegate(void) { return @protocol(NSXPCListenerDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_NSXPCProxyCreating(void) { return @protocol(NSXPCProxyCreating); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_data(void) { return @protocol(OS_dispatch_data); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_group(void) { return @protocol(OS_dispatch_group); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_io(void) { return @protocol(OS_dispatch_io); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_object(void) { return @protocol(OS_dispatch_object); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_queue(void) { return @protocol(OS_dispatch_queue); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_queue_attr(void) { return @protocol(OS_dispatch_queue_attr); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_queue_concurrent(void) { return @protocol(OS_dispatch_queue_concurrent); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_queue_global(void) { return @protocol(OS_dispatch_queue_global); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_queue_main(void) { return @protocol(OS_dispatch_queue_main); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_queue_serial(void) { return @protocol(OS_dispatch_queue_serial); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_queue_serial_executor(void) { return @protocol(OS_dispatch_queue_serial_executor); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_semaphore(void) { return @protocol(OS_dispatch_semaphore); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_source(void) { return @protocol(OS_dispatch_source); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_dispatch_workloop(void) { return @protocol(OS_dispatch_workloop); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_os_workgroup_interval(void) { return @protocol(OS_os_workgroup_interval); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_os_workgroup_parallel(void) { return @protocol(OS_os_workgroup_parallel); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_sec_certificate(void) { return @protocol(OS_sec_certificate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_sec_identity(void) { return @protocol(OS_sec_identity); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_sec_object(void) { return @protocol(OS_sec_object); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_sec_protocol_metadata(void) { return @protocol(OS_sec_protocol_metadata); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_sec_protocol_options(void) { return @protocol(OS_sec_protocol_options); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_sec_trust(void) { return @protocol(OS_sec_trust); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_xpc_listener(void) { return @protocol(OS_xpc_listener); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_xpc_object(void) { return @protocol(OS_xpc_object); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_xpc_peer_requirement(void) { return @protocol(OS_xpc_peer_requirement); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_OS_xpc_session(void) { return @protocol(OS_xpc_session); }

typedef struct CGImage *  (^_ProtocolTrampoline)(void * sel, struct CGSize arg1, double arg2, struct CGPoint * arg3, struct CGSize * arg4);
__attribute__((visibility("default"))) __attribute__((used))
struct CGImage *  _1uu024u_protocolTrampoline_1p89e63(id target, void * sel, struct CGSize arg1, double arg2, struct CGPoint * arg3, struct CGSize * arg4) {
  return ((_ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef id  (^_ProtocolTrampoline_1)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((_ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_2)(void * sel, id arg1, struct _NSRange arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_19u921t(id target, void * sel, id arg1, struct _NSRange arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef id  (^_ProtocolTrampoline_3)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_1yw2rcr(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_4)(void * sel, id arg1, id arg2, unsigned long arg3, uint64_t arg4, id arg5, id arg6, long * arg7);
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_1chy5b9(id target, void * sel, id arg1, id arg2, unsigned long arg3, uint64_t arg4, id arg5, id arg6, long * arg7) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}

typedef id  (^_ProtocolTrampoline_5)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_zi5eed(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_6)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_7)(void * sel, struct objc_selector * arg1, NSCalculationError arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_738w24(id target, void * sel, struct objc_selector * arg1, NSCalculationError arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_7)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef struct _NSRange  (^_ProtocolTrampoline_8)(void * sel, id arg1, id arg2, id arg3, id * arg4);
__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1uu024u_protocolTrampoline_xsqx6i(id target, void * sel, id arg1, id arg2, id arg3, id * arg4) {
  return ((_ProtocolTrampoline_8)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef struct _NSRange  (^_ProtocolTrampoline_9)(void * sel, id arg1, id arg2, id arg3, long * arg4, BOOL arg5);
__attribute__((visibility("default"))) __attribute__((used))
struct _NSRange  _1uu024u_protocolTrampoline_1j6oadz(id target, void * sel, id arg1, id arg2, id arg3, long * arg4, BOOL arg5) {
  return ((_ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef NSRoundingMode  (^_ProtocolTrampoline_10)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
NSRoundingMode  _1uu024u_protocolTrampoline_5cb1bj(id target, void * sel) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct OpaquePMPageFormat *  (^_ProtocolTrampoline_11)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct OpaquePMPageFormat *  _1uu024u_protocolTrampoline_1pm5t72(id target, void * sel) {
  return ((_ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct OpaquePMPrintSession *  (^_ProtocolTrampoline_12)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct OpaquePMPrintSession *  _1uu024u_protocolTrampoline_1ch2rph(id target, void * sel) {
  return ((_ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct OpaquePMPrintSettings *  (^_ProtocolTrampoline_13)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct OpaquePMPrintSettings *  _1uu024u_protocolTrampoline_1cwrrqo(id target, void * sel) {
  return ((_ProtocolTrampoline_13)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct OpaquePMPrinter *  (^_ProtocolTrampoline_14)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct OpaquePMPrinter *  _1uu024u_protocolTrampoline_h8xvuu(id target, void * sel) {
  return ((_ProtocolTrampoline_14)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_15)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1uu024u_protocolTrampoline_e3qsqz(id target, void * sel) {
  return ((_ProtocolTrampoline_15)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_16)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1uu024u_protocolTrampoline_2n06mv(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_16)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_17)(void * sel, id * arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1uu024u_protocolTrampoline_jp3gca(id target, void * sel, id * arg1) {
  return ((_ProtocolTrampoline_17)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^_ProtocolTrampoline_18)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1uu024u_protocolTrampoline_jk8du5(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_18)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_19)(void * sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1uu024u_protocolTrampoline_1em3l8z(id target, void * sel, id arg1, id arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_19)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_20)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1uu024u_protocolTrampoline_3su7tt(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_20)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef short  (^_ProtocolTrampoline_21)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
short  _1uu024u_protocolTrampoline_p984hf(id target, void * sel) {
  return ((_ProtocolTrampoline_21)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1pl9qdv : NSObject
@property (copy) id block;

@end
@implementation _1uu024u_BlockArgs_1pl9qdv
@end

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1uu024u_wrapListenerBlock_1pl9qdv(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline weakSelfBlock = nil;
  _ListenerTrampoline strongSelfBlock = [^void() {
    @autoreleasepool {
      _1uu024u_BlockArgs_1pl9qdv* args = [[_1uu024u_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1uu024u_wrapBlockingBlock_1pl9qdv(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline, ^void(), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1pl9qdv* args = [[_1uu024u_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1pl9qdv* args = [[_1uu024u_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_115kkcp : NSObject
@property (copy) id block;
@property unsigned char arg0;
@property unsigned long long arg1;
@property struct __CFError * arg2;
@end
@implementation _1uu024u_BlockArgs_115kkcp
@end

typedef void  (^_ListenerTrampoline_1)(unsigned char arg0, unsigned long long arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1uu024u_wrapListenerBlock_115kkcp(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_1 weakSelfBlock = nil;
  _ListenerTrampoline_1 strongSelfBlock = [^void(unsigned char arg0, unsigned long long arg1, struct __CFError * arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_115kkcp* args = [[_1uu024u_BlockArgs_115kkcp alloc] init];
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

typedef void  (^_BlockingTrampoline_1)(void * waiter, unsigned char arg0, unsigned long long arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1uu024u_wrapBlockingBlock_115kkcp(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_1, ^void(unsigned char arg0, unsigned long long arg1, struct __CFError * arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_115kkcp* args = [[_1uu024u_BlockArgs_115kkcp alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_115kkcp* args = [[_1uu024u_BlockArgs_115kkcp alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_9fms3g : NSObject
@property (copy) id block;
@property struct __CFArray * arg0;
@end
@implementation _1uu024u_BlockArgs_9fms3g
@end

typedef void  (^_ListenerTrampoline_2)(struct __CFArray * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1uu024u_wrapListenerBlock_9fms3g(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_2 weakSelfBlock = nil;
  _ListenerTrampoline_2 strongSelfBlock = [^void(struct __CFArray * arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_9fms3g* args = [[_1uu024u_BlockArgs_9fms3g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, struct __CFArray * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1uu024u_wrapBlockingBlock_9fms3g(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_2, ^void(struct __CFArray * arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_9fms3g* args = [[_1uu024u_BlockArgs_9fms3g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_9fms3g* args = [[_1uu024u_BlockArgs_9fms3g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_15ghdzk : NSObject
@property (copy) id block;
@property struct __CFArray * arg0;
@property struct __CFError * arg1;
@end
@implementation _1uu024u_BlockArgs_15ghdzk
@end

typedef void  (^_ListenerTrampoline_3)(struct __CFArray * arg0, struct __CFError * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1uu024u_wrapListenerBlock_15ghdzk(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_3 weakSelfBlock = nil;
  _ListenerTrampoline_3 strongSelfBlock = [^void(struct __CFArray * arg0, struct __CFError * arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_15ghdzk* args = [[_1uu024u_BlockArgs_15ghdzk alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, struct __CFArray * arg0, struct __CFError * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1uu024u_wrapBlockingBlock_15ghdzk(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_3, ^void(struct __CFArray * arg0, struct __CFError * arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_15ghdzk* args = [[_1uu024u_BlockArgs_15ghdzk alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_15ghdzk* args = [[_1uu024u_BlockArgs_15ghdzk alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1kwz7d1 : NSObject
@property (copy) id block;
@property struct __CFError * arg0;
@end
@implementation _1uu024u_BlockArgs_1kwz7d1
@end

typedef void  (^_ListenerTrampoline_4)(struct __CFError * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1uu024u_wrapListenerBlock_1kwz7d1(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_4 weakSelfBlock = nil;
  _ListenerTrampoline_4 strongSelfBlock = [^void(struct __CFError * arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1kwz7d1* args = [[_1uu024u_BlockArgs_1kwz7d1 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, struct __CFError * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1uu024u_wrapBlockingBlock_1kwz7d1(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_4, ^void(struct __CFError * arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1kwz7d1* args = [[_1uu024u_BlockArgs_1kwz7d1 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1kwz7d1* args = [[_1uu024u_BlockArgs_1kwz7d1 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1yrznn1 : NSObject
@property (copy) id block;
@property struct __CFError * arg0;
@property CGContentInfo * arg1;
@property CGBitmapParameters * arg2;
@end
@implementation _1uu024u_BlockArgs_1yrznn1
@end

typedef void  (^_ListenerTrampoline_5)(struct __CFError * arg0, CGContentInfo * arg1, CGBitmapParameters * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1uu024u_wrapListenerBlock_1yrznn1(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_5 weakSelfBlock = nil;
  _ListenerTrampoline_5 strongSelfBlock = [^void(struct __CFError * arg0, CGContentInfo * arg1, CGBitmapParameters * arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1yrznn1* args = [[_1uu024u_BlockArgs_1yrznn1 alloc] init];
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

typedef void  (^_BlockingTrampoline_5)(void * waiter, struct __CFError * arg0, CGContentInfo * arg1, CGBitmapParameters * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1uu024u_wrapBlockingBlock_1yrznn1(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_5, ^void(struct __CFError * arg0, CGContentInfo * arg1, CGBitmapParameters * arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1yrznn1* args = [[_1uu024u_BlockArgs_1yrznn1 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1yrznn1* args = [[_1uu024u_BlockArgs_1yrznn1 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_tg5tbv : NSObject
@property (copy) id block;
@property struct __CFRunLoopObserver * arg0;
@property CFRunLoopActivity arg1;
@end
@implementation _1uu024u_BlockArgs_tg5tbv
@end

typedef void  (^_ListenerTrampoline_6)(struct __CFRunLoopObserver * arg0, CFRunLoopActivity arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1uu024u_wrapListenerBlock_tg5tbv(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_6 weakSelfBlock = nil;
  _ListenerTrampoline_6 strongSelfBlock = [^void(struct __CFRunLoopObserver * arg0, CFRunLoopActivity arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_tg5tbv* args = [[_1uu024u_BlockArgs_tg5tbv alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, struct __CFRunLoopObserver * arg0, CFRunLoopActivity arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1uu024u_wrapBlockingBlock_tg5tbv(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_6, ^void(struct __CFRunLoopObserver * arg0, CFRunLoopActivity arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_tg5tbv* args = [[_1uu024u_BlockArgs_tg5tbv alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_tg5tbv* args = [[_1uu024u_BlockArgs_tg5tbv alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1dqvvol : NSObject
@property (copy) id block;
@property struct __CFRunLoopTimer * arg0;
@end
@implementation _1uu024u_BlockArgs_1dqvvol
@end

typedef void  (^_ListenerTrampoline_7)(struct __CFRunLoopTimer * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1uu024u_wrapListenerBlock_1dqvvol(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_7 weakSelfBlock = nil;
  _ListenerTrampoline_7 strongSelfBlock = [^void(struct __CFRunLoopTimer * arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1dqvvol* args = [[_1uu024u_BlockArgs_1dqvvol alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, struct __CFRunLoopTimer * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1uu024u_wrapBlockingBlock_1dqvvol(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_7, ^void(struct __CFRunLoopTimer * arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1dqvvol* args = [[_1uu024u_BlockArgs_1dqvvol alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1dqvvol* args = [[_1uu024u_BlockArgs_1dqvvol alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_b3tf6o : NSObject
@property (copy) id block;
@property void * arg0;
@property struct __CFError * arg1;
@property unsigned char arg2;
@end
@implementation _1uu024u_BlockArgs_b3tf6o
@end

typedef void  (^_ListenerTrampoline_8)(void * arg0, struct __CFError * arg1, unsigned char arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1uu024u_wrapListenerBlock_b3tf6o(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_8 weakSelfBlock = nil;
  _ListenerTrampoline_8 strongSelfBlock = [^void(void * arg0, struct __CFError * arg1, unsigned char arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_b3tf6o* args = [[_1uu024u_BlockArgs_b3tf6o alloc] init];
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

typedef void  (^_BlockingTrampoline_8)(void * waiter, void * arg0, struct __CFError * arg1, unsigned char arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1uu024u_wrapBlockingBlock_b3tf6o(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_8, ^void(void * arg0, struct __CFError * arg1, unsigned char arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_b3tf6o* args = [[_1uu024u_BlockArgs_b3tf6o alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_b3tf6o* args = [[_1uu024u_BlockArgs_b3tf6o alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_du1izn : NSObject
@property (copy) id block;
@property CGDisplayStreamFrameStatus arg0;
@property uint64_t arg1;
@property struct __IOSurface * arg2;
@property struct CGDisplayStreamUpdate * arg3;
@end
@implementation _1uu024u_BlockArgs_du1izn
@end

typedef void  (^_ListenerTrampoline_9)(CGDisplayStreamFrameStatus arg0, uint64_t arg1, struct __IOSurface * arg2, struct CGDisplayStreamUpdate * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1uu024u_wrapListenerBlock_du1izn(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_9 weakSelfBlock = nil;
  _ListenerTrampoline_9 strongSelfBlock = [^void(CGDisplayStreamFrameStatus arg0, uint64_t arg1, struct __IOSurface * arg2, struct CGDisplayStreamUpdate * arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_du1izn* args = [[_1uu024u_BlockArgs_du1izn alloc] init];
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

typedef void  (^_BlockingTrampoline_9)(void * waiter, CGDisplayStreamFrameStatus arg0, uint64_t arg1, struct __IOSurface * arg2, struct CGDisplayStreamUpdate * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1uu024u_wrapBlockingBlock_du1izn(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_9, ^void(CGDisplayStreamFrameStatus arg0, uint64_t arg1, struct __IOSurface * arg2, struct CGDisplayStreamUpdate * arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_du1izn* args = [[_1uu024u_BlockArgs_du1izn alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_du1izn* args = [[_1uu024u_BlockArgs_du1izn alloc] init];
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
@interface _1uu024u_BlockArgs_1ctgxtl : NSObject
@property (copy) id block;
@property struct CGPathElement * arg0;
@end
@implementation _1uu024u_BlockArgs_1ctgxtl
@end

typedef void  (^_ListenerTrampoline_10)(struct CGPathElement * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1uu024u_wrapListenerBlock_1ctgxtl(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_10 weakSelfBlock = nil;
  _ListenerTrampoline_10 strongSelfBlock = [^void(struct CGPathElement * arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1ctgxtl* args = [[_1uu024u_BlockArgs_1ctgxtl alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_10)(void * waiter, struct CGPathElement * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1uu024u_wrapBlockingBlock_1ctgxtl(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_10, ^void(struct CGPathElement * arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1ctgxtl* args = [[_1uu024u_BlockArgs_1ctgxtl alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1ctgxtl* args = [[_1uu024u_BlockArgs_1ctgxtl alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_rdj45r : NSObject
@property (copy) id block;
@property struct CGRenderingBufferProvider * arg0;
@property CGContentInfo * arg1;
@property CGBitmapParameters * arg2;
@end
@implementation _1uu024u_BlockArgs_rdj45r
@end

typedef void  (^_ListenerTrampoline_11)(struct CGRenderingBufferProvider * arg0, CGContentInfo * arg1, CGBitmapParameters * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1uu024u_wrapListenerBlock_rdj45r(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_11 weakSelfBlock = nil;
  _ListenerTrampoline_11 strongSelfBlock = [^void(struct CGRenderingBufferProvider * arg0, CGContentInfo * arg1, CGBitmapParameters * arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_rdj45r* args = [[_1uu024u_BlockArgs_rdj45r alloc] init];
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

typedef void  (^_BlockingTrampoline_11)(void * waiter, struct CGRenderingBufferProvider * arg0, CGContentInfo * arg1, CGBitmapParameters * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1uu024u_wrapBlockingBlock_rdj45r(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_11, ^void(struct CGRenderingBufferProvider * arg0, CGContentInfo * arg1, CGBitmapParameters * arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_rdj45r* args = [[_1uu024u_BlockArgs_rdj45r alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_rdj45r* args = [[_1uu024u_BlockArgs_rdj45r alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_pfv6jd : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property (strong) id arg1;
@end
@implementation _1uu024u_BlockArgs_pfv6jd
@end

typedef void  (^_ListenerTrampoline_12)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1uu024u_wrapListenerBlock_pfv6jd(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_12 weakSelfBlock = nil;
  _ListenerTrampoline_12 strongSelfBlock = [^void(id arg0, id arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_pfv6jd* args = [[_1uu024u_BlockArgs_pfv6jd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_12)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1uu024u_wrapBlockingBlock_pfv6jd(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_12, ^void(id arg0, id arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_pfv6jd* args = [[_1uu024u_BlockArgs_pfv6jd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_pfv6jd* args = [[_1uu024u_BlockArgs_pfv6jd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_xtuoz7 : NSObject
@property (copy) id block;
@property (strong) id arg0;
@end
@implementation _1uu024u_BlockArgs_xtuoz7
@end

typedef void  (^_ListenerTrampoline_13)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1uu024u_wrapListenerBlock_xtuoz7(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_13 weakSelfBlock = nil;
  _ListenerTrampoline_13 strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_xtuoz7* args = [[_1uu024u_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_13)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1uu024u_wrapBlockingBlock_xtuoz7(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_13, ^void(id arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_xtuoz7* args = [[_1uu024u_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_xtuoz7* args = [[_1uu024u_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_10ssdng : NSObject
@property (copy) id block;
@property NSBackgroundActivityResult arg0;
@end
@implementation _1uu024u_BlockArgs_10ssdng
@end

typedef void  (^_ListenerTrampoline_14)(NSBackgroundActivityResult arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1uu024u_wrapListenerBlock_10ssdng(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_14 weakSelfBlock = nil;
  _ListenerTrampoline_14 strongSelfBlock = [^void(NSBackgroundActivityResult arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_10ssdng* args = [[_1uu024u_BlockArgs_10ssdng alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_14)(void * waiter, NSBackgroundActivityResult arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1uu024u_wrapBlockingBlock_10ssdng(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_14, ^void(NSBackgroundActivityResult arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_10ssdng* args = [[_1uu024u_BlockArgs_10ssdng alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_10ssdng* args = [[_1uu024u_BlockArgs_10ssdng alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_r8gdi7 : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@end
@implementation _1uu024u_BlockArgs_r8gdi7
@end

typedef void  (^_ListenerTrampoline_15)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1uu024u_wrapListenerBlock_r8gdi7(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_15 weakSelfBlock = nil;
  _ListenerTrampoline_15 strongSelfBlock = [^void(id arg0, id arg1, id arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_r8gdi7* args = [[_1uu024u_BlockArgs_r8gdi7 alloc] init];
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

typedef void  (^_BlockingTrampoline_15)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1uu024u_wrapBlockingBlock_r8gdi7(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_15, ^void(id arg0, id arg1, id arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_r8gdi7* args = [[_1uu024u_BlockArgs_r8gdi7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_r8gdi7* args = [[_1uu024u_BlockArgs_r8gdi7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1a22wz : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property struct _NSRange arg1;
@property BOOL * arg2;
@end
@implementation _1uu024u_BlockArgs_1a22wz
@end

typedef void  (^_ListenerTrampoline_16)(id arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1uu024u_wrapListenerBlock_1a22wz(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_16 weakSelfBlock = nil;
  _ListenerTrampoline_16 strongSelfBlock = [^void(id arg0, struct _NSRange arg1, BOOL * arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1a22wz* args = [[_1uu024u_BlockArgs_1a22wz alloc] init];
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

typedef void  (^_BlockingTrampoline_16)(void * waiter, id arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1uu024u_wrapBlockingBlock_1a22wz(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_16, ^void(id arg0, struct _NSRange arg1, BOOL * arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1a22wz* args = [[_1uu024u_BlockArgs_1a22wz alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1a22wz* args = [[_1uu024u_BlockArgs_1a22wz alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1b3bb6a : NSObject
@property (copy) id block;
@property (copy) id arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@end
@implementation _1uu024u_BlockArgs_1b3bb6a
@end

typedef void  (^_ListenerTrampoline_17)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1uu024u_wrapListenerBlock_1b3bb6a(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_17 weakSelfBlock = nil;
  _ListenerTrampoline_17 strongSelfBlock = [^void(id arg0, id arg1, id arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1b3bb6a* args = [[_1uu024u_BlockArgs_1b3bb6a alloc] init];
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

typedef void  (^_BlockingTrampoline_17)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1uu024u_wrapBlockingBlock_1b3bb6a(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_17, ^void(id arg0, id arg1, id arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1b3bb6a* args = [[_1uu024u_BlockArgs_1b3bb6a alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1b3bb6a* args = [[_1uu024u_BlockArgs_1b3bb6a alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_lmc3p5 : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property struct _NSRange arg1;
@property struct _NSRange arg2;
@property BOOL * arg3;
@end
@implementation _1uu024u_BlockArgs_lmc3p5
@end

typedef void  (^_ListenerTrampoline_18)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_18 _1uu024u_wrapListenerBlock_lmc3p5(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_18 weakSelfBlock = nil;
  _ListenerTrampoline_18 strongSelfBlock = [^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_lmc3p5* args = [[_1uu024u_BlockArgs_lmc3p5 alloc] init];
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

typedef void  (^_BlockingTrampoline_18)(void * waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_18 _1uu024u_wrapBlockingBlock_lmc3p5(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_18, ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_lmc3p5* args = [[_1uu024u_BlockArgs_lmc3p5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_lmc3p5* args = [[_1uu024u_BlockArgs_lmc3p5 alloc] init];
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
@interface _1uu024u_BlockArgs_6jvo9y : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property NSMatchingFlags arg1;
@property BOOL * arg2;
@end
@implementation _1uu024u_BlockArgs_6jvo9y
@end

typedef void  (^_ListenerTrampoline_19)(id arg0, NSMatchingFlags arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_19 _1uu024u_wrapListenerBlock_6jvo9y(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_19 weakSelfBlock = nil;
  _ListenerTrampoline_19 strongSelfBlock = [^void(id arg0, NSMatchingFlags arg1, BOOL * arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_6jvo9y* args = [[_1uu024u_BlockArgs_6jvo9y alloc] init];
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

typedef void  (^_BlockingTrampoline_19)(void * waiter, id arg0, NSMatchingFlags arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_19 _1uu024u_wrapBlockingBlock_6jvo9y(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_19, ^void(id arg0, NSMatchingFlags arg1, BOOL * arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_6jvo9y* args = [[_1uu024u_BlockArgs_6jvo9y alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_6jvo9y* args = [[_1uu024u_BlockArgs_6jvo9y alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_n8yd09 : NSObject
@property (copy) id block;
@property NSURLSessionAuthChallengeDisposition arg0;
@property (strong) id arg1;
@end
@implementation _1uu024u_BlockArgs_n8yd09
@end

typedef void  (^_ListenerTrampoline_20)(NSURLSessionAuthChallengeDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_20 _1uu024u_wrapListenerBlock_n8yd09(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_20 weakSelfBlock = nil;
  _ListenerTrampoline_20 strongSelfBlock = [^void(NSURLSessionAuthChallengeDisposition arg0, id arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_n8yd09* args = [[_1uu024u_BlockArgs_n8yd09 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_20)(void * waiter, NSURLSessionAuthChallengeDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_20 _1uu024u_wrapBlockingBlock_n8yd09(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_20, ^void(NSURLSessionAuthChallengeDisposition arg0, id arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_n8yd09* args = [[_1uu024u_BlockArgs_n8yd09 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_n8yd09* args = [[_1uu024u_BlockArgs_n8yd09 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1otpo83 : NSObject
@property (copy) id block;
@property NSURLSessionDelayedRequestDisposition arg0;
@property (strong) id arg1;
@end
@implementation _1uu024u_BlockArgs_1otpo83
@end

typedef void  (^_ListenerTrampoline_21)(NSURLSessionDelayedRequestDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_21 _1uu024u_wrapListenerBlock_1otpo83(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_21 weakSelfBlock = nil;
  _ListenerTrampoline_21 strongSelfBlock = [^void(NSURLSessionDelayedRequestDisposition arg0, id arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1otpo83* args = [[_1uu024u_BlockArgs_1otpo83 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_21)(void * waiter, NSURLSessionDelayedRequestDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_21 _1uu024u_wrapBlockingBlock_1otpo83(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_21, ^void(NSURLSessionDelayedRequestDisposition arg0, id arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1otpo83* args = [[_1uu024u_BlockArgs_1otpo83 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1otpo83* args = [[_1uu024u_BlockArgs_1otpo83 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_16sve1d : NSObject
@property (copy) id block;
@property NSURLSessionResponseDisposition arg0;
@end
@implementation _1uu024u_BlockArgs_16sve1d
@end

typedef void  (^_ListenerTrampoline_22)(NSURLSessionResponseDisposition arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_22 _1uu024u_wrapListenerBlock_16sve1d(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_22 weakSelfBlock = nil;
  _ListenerTrampoline_22 strongSelfBlock = [^void(NSURLSessionResponseDisposition arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_16sve1d* args = [[_1uu024u_BlockArgs_16sve1d alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_22)(void * waiter, NSURLSessionResponseDisposition arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_22 _1uu024u_wrapBlockingBlock_16sve1d(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_22, ^void(NSURLSessionResponseDisposition arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_16sve1d* args = [[_1uu024u_BlockArgs_16sve1d alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_16sve1d* args = [[_1uu024u_BlockArgs_16sve1d alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_l3f29g : NSObject
@property (copy) id block;
@property int arg0;
@property AuthorizationItemSet * arg1;
@end
@implementation _1uu024u_BlockArgs_l3f29g
@end

typedef void  (^_ListenerTrampoline_23)(int arg0, AuthorizationItemSet * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_23 _1uu024u_wrapListenerBlock_l3f29g(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_23 weakSelfBlock = nil;
  _ListenerTrampoline_23 strongSelfBlock = [^void(int arg0, AuthorizationItemSet * arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_l3f29g* args = [[_1uu024u_BlockArgs_l3f29g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_23)(void * waiter, int arg0, AuthorizationItemSet * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_23 _1uu024u_wrapBlockingBlock_l3f29g(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_23, ^void(int arg0, AuthorizationItemSet * arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_l3f29g* args = [[_1uu024u_BlockArgs_l3f29g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_l3f29g* args = [[_1uu024u_BlockArgs_l3f29g alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1rz4y3 : NSObject
@property (copy) id block;
@property struct __SecKey * arg0;
@property struct __SecKey * arg1;
@property struct __CFError * arg2;
@end
@implementation _1uu024u_BlockArgs_1rz4y3
@end

typedef void  (^_ListenerTrampoline_24)(struct __SecKey * arg0, struct __SecKey * arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_24 _1uu024u_wrapListenerBlock_1rz4y3(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_24 weakSelfBlock = nil;
  _ListenerTrampoline_24 strongSelfBlock = [^void(struct __SecKey * arg0, struct __SecKey * arg1, struct __CFError * arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1rz4y3* args = [[_1uu024u_BlockArgs_1rz4y3 alloc] init];
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

typedef void  (^_BlockingTrampoline_24)(void * waiter, struct __SecKey * arg0, struct __SecKey * arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_24 _1uu024u_wrapBlockingBlock_1rz4y3(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_24, ^void(struct __SecKey * arg0, struct __SecKey * arg1, struct __CFError * arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1rz4y3* args = [[_1uu024u_BlockArgs_1rz4y3 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1rz4y3* args = [[_1uu024u_BlockArgs_1rz4y3 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_gwxhxt : NSObject
@property (copy) id block;
@property struct __SecTrust * arg0;
@property SecTrustResultType arg1;
@end
@implementation _1uu024u_BlockArgs_gwxhxt
@end

typedef void  (^_ListenerTrampoline_25)(struct __SecTrust * arg0, SecTrustResultType arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_25 _1uu024u_wrapListenerBlock_gwxhxt(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_25 weakSelfBlock = nil;
  _ListenerTrampoline_25 strongSelfBlock = [^void(struct __SecTrust * arg0, SecTrustResultType arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_gwxhxt* args = [[_1uu024u_BlockArgs_gwxhxt alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_25)(void * waiter, struct __SecTrust * arg0, SecTrustResultType arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_25 _1uu024u_wrapBlockingBlock_gwxhxt(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_25, ^void(struct __SecTrust * arg0, SecTrustResultType arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_gwxhxt* args = [[_1uu024u_BlockArgs_gwxhxt alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_gwxhxt* args = [[_1uu024u_BlockArgs_gwxhxt alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_k73ff5 : NSObject
@property (copy) id block;
@property struct __SecTrust * arg0;
@property BOOL arg1;
@property struct __CFError * arg2;
@end
@implementation _1uu024u_BlockArgs_k73ff5
@end

typedef void  (^_ListenerTrampoline_26)(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_26 _1uu024u_wrapListenerBlock_k73ff5(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_26 weakSelfBlock = nil;
  _ListenerTrampoline_26 strongSelfBlock = [^void(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_k73ff5* args = [[_1uu024u_BlockArgs_k73ff5 alloc] init];
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

typedef void  (^_BlockingTrampoline_26)(void * waiter, struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_26 _1uu024u_wrapBlockingBlock_k73ff5(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_26, ^void(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_k73ff5* args = [[_1uu024u_BlockArgs_k73ff5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_k73ff5* args = [[_1uu024u_BlockArgs_k73ff5 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_15f11yh : NSObject
@property (copy) id block;
@property uint16_t arg0;
@end
@implementation _1uu024u_BlockArgs_15f11yh
@end

typedef void  (^_ListenerTrampoline_27)(uint16_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_27 _1uu024u_wrapListenerBlock_15f11yh(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_27 weakSelfBlock = nil;
  _ListenerTrampoline_27 strongSelfBlock = [^void(uint16_t arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_15f11yh* args = [[_1uu024u_BlockArgs_15f11yh alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_27)(void * waiter, uint16_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_27 _1uu024u_wrapBlockingBlock_15f11yh(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_27, ^void(uint16_t arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_15f11yh* args = [[_1uu024u_BlockArgs_15f11yh alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_15f11yh* args = [[_1uu024u_BlockArgs_15f11yh alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1s56lr9 : NSObject
@property (copy) id block;
@property BOOL arg0;
@end
@implementation _1uu024u_BlockArgs_1s56lr9
@end

typedef void  (^_ListenerTrampoline_28)(BOOL arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_28 _1uu024u_wrapListenerBlock_1s56lr9(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_28 weakSelfBlock = nil;
  _ListenerTrampoline_28 strongSelfBlock = [^void(BOOL arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1s56lr9* args = [[_1uu024u_BlockArgs_1s56lr9 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_28)(void * waiter, BOOL arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_28 _1uu024u_wrapBlockingBlock_1s56lr9(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_28, ^void(BOOL arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1s56lr9* args = [[_1uu024u_BlockArgs_1s56lr9 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1s56lr9* args = [[_1uu024u_BlockArgs_1s56lr9 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_hk7n97 : NSObject
@property (copy) id block;
@property BOOL arg0;
@property (strong) id arg1;
@end
@implementation _1uu024u_BlockArgs_hk7n97
@end

typedef void  (^_ListenerTrampoline_29)(BOOL arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_29 _1uu024u_wrapListenerBlock_hk7n97(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_29 weakSelfBlock = nil;
  _ListenerTrampoline_29 strongSelfBlock = [^void(BOOL arg0, id arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_hk7n97* args = [[_1uu024u_BlockArgs_hk7n97 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_29)(void * waiter, BOOL arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_29 _1uu024u_wrapBlockingBlock_hk7n97(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_29, ^void(BOOL arg0, id arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_hk7n97* args = [[_1uu024u_BlockArgs_hk7n97 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_hk7n97* args = [[_1uu024u_BlockArgs_hk7n97 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_og5b6y : NSObject
@property (copy) id block;
@property BOOL arg0;
@property (strong) id arg1;
@property int arg2;
@end
@implementation _1uu024u_BlockArgs_og5b6y
@end

typedef void  (^_ListenerTrampoline_30)(BOOL arg0, id arg1, int arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_30 _1uu024u_wrapListenerBlock_og5b6y(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_30 weakSelfBlock = nil;
  _ListenerTrampoline_30 strongSelfBlock = [^void(BOOL arg0, id arg1, int arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_og5b6y* args = [[_1uu024u_BlockArgs_og5b6y alloc] init];
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

typedef void  (^_BlockingTrampoline_30)(void * waiter, BOOL arg0, id arg1, int arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_30 _1uu024u_wrapBlockingBlock_og5b6y(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_30, ^void(BOOL arg0, id arg1, int arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_og5b6y* args = [[_1uu024u_BlockArgs_og5b6y alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_og5b6y* args = [[_1uu024u_BlockArgs_og5b6y alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_18kzm6a : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property int arg1;
@end
@implementation _1uu024u_BlockArgs_18kzm6a
@end

typedef void  (^_ListenerTrampoline_31)(id arg0, int arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_31 _1uu024u_wrapListenerBlock_18kzm6a(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_31 weakSelfBlock = nil;
  _ListenerTrampoline_31 strongSelfBlock = [^void(id arg0, int arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_18kzm6a* args = [[_1uu024u_BlockArgs_18kzm6a alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_31)(void * waiter, id arg0, int arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_31 _1uu024u_wrapBlockingBlock_18kzm6a(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_31, ^void(id arg0, int arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_18kzm6a* args = [[_1uu024u_BlockArgs_18kzm6a alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_18kzm6a* args = [[_1uu024u_BlockArgs_18kzm6a alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_132rcs6 : NSObject
@property (copy) id block;
@property double arg0;
@property long arg1;
@property BOOL arg2;
@property BOOL * arg3;
@end
@implementation _1uu024u_BlockArgs_132rcs6
@end

typedef void  (^_ListenerTrampoline_32)(double arg0, long arg1, BOOL arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_32 _1uu024u_wrapListenerBlock_132rcs6(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_32 weakSelfBlock = nil;
  _ListenerTrampoline_32 strongSelfBlock = [^void(double arg0, long arg1, BOOL arg2, BOOL * arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_132rcs6* args = [[_1uu024u_BlockArgs_132rcs6 alloc] init];
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

typedef void  (^_BlockingTrampoline_32)(void * waiter, double arg0, long arg1, BOOL arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_32 _1uu024u_wrapBlockingBlock_132rcs6(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_32, ^void(double arg0, long arg1, BOOL arg2, BOOL * arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_132rcs6* args = [[_1uu024u_BlockArgs_132rcs6 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_132rcs6* args = [[_1uu024u_BlockArgs_132rcs6 alloc] init];
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
@interface _1uu024u_BlockArgs_9o8504 : NSObject
@property (copy) id block;
@property int arg0;
@end
@implementation _1uu024u_BlockArgs_9o8504
@end

typedef void  (^_ListenerTrampoline_33)(int arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_33 _1uu024u_wrapListenerBlock_9o8504(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_33 weakSelfBlock = nil;
  _ListenerTrampoline_33 strongSelfBlock = [^void(int arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_9o8504* args = [[_1uu024u_BlockArgs_9o8504 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_33)(void * waiter, int arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_33 _1uu024u_wrapBlockingBlock_9o8504(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_33, ^void(int arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_9o8504* args = [[_1uu024u_BlockArgs_9o8504 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_9o8504* args = [[_1uu024u_BlockArgs_9o8504 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_6enxqz : NSObject
@property (copy) id block;
@property size_t arg0;
@end
@implementation _1uu024u_BlockArgs_6enxqz
@end

typedef void  (^_ListenerTrampoline_34)(size_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_34 _1uu024u_wrapListenerBlock_6enxqz(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_34 weakSelfBlock = nil;
  _ListenerTrampoline_34 strongSelfBlock = [^void(size_t arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_6enxqz* args = [[_1uu024u_BlockArgs_6enxqz alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_34)(void * waiter, size_t arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_34 _1uu024u_wrapBlockingBlock_6enxqz(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_34, ^void(size_t arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_6enxqz* args = [[_1uu024u_BlockArgs_6enxqz alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_6enxqz* args = [[_1uu024u_BlockArgs_6enxqz alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_11t2oft : NSObject
@property (copy) id block;
@property size_t arg0;
@property struct CGImage * arg1;
@property BOOL * arg2;
@end
@implementation _1uu024u_BlockArgs_11t2oft
@end

typedef void  (^_ListenerTrampoline_35)(size_t arg0, struct CGImage * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_35 _1uu024u_wrapListenerBlock_11t2oft(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_35 weakSelfBlock = nil;
  _ListenerTrampoline_35 strongSelfBlock = [^void(size_t arg0, struct CGImage * arg1, BOOL * arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_11t2oft* args = [[_1uu024u_BlockArgs_11t2oft alloc] init];
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

typedef void  (^_BlockingTrampoline_35)(void * waiter, size_t arg0, struct CGImage * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_35 _1uu024u_wrapBlockingBlock_11t2oft(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_35, ^void(size_t arg0, struct CGImage * arg1, BOOL * arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_11t2oft* args = [[_1uu024u_BlockArgs_11t2oft alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_11t2oft* args = [[_1uu024u_BlockArgs_11t2oft alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_ovsamd : NSObject
@property (copy) id block;
@property void * arg0;
@end
@implementation _1uu024u_BlockArgs_ovsamd
@end

typedef void  (^_ListenerTrampoline_36)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_36 _1uu024u_wrapListenerBlock_ovsamd(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_36 weakSelfBlock = nil;
  _ListenerTrampoline_36 strongSelfBlock = [^void(void * arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_ovsamd* args = [[_1uu024u_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_36)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_36 _1uu024u_wrapBlockingBlock_ovsamd(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_36, ^void(void * arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_ovsamd* args = [[_1uu024u_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_ovsamd* args = [[_1uu024u_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_22)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((_ProtocolTrampoline_22)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_f167m6 : NSObject
@property (copy) id block;
@property (strong) id arg0;
@end
@implementation _1uu024u_BlockArgs_f167m6
@end

typedef void  (^_ListenerTrampoline_37)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_37 _1uu024u_wrapListenerBlock_f167m6(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_37 weakSelfBlock = nil;
  _ListenerTrampoline_37 strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _1uu024u_BlockArgs_f167m6* args = [[_1uu024u_BlockArgs_f167m6 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_37)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_37 _1uu024u_wrapBlockingBlock_f167m6(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_37, ^void(id arg0), {
    @autoreleasepool {
      _1uu024u_BlockArgs_f167m6* args = [[_1uu024u_BlockArgs_f167m6 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_f167m6* args = [[_1uu024u_BlockArgs_f167m6 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_fjrv01 : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@end
@implementation _1uu024u_BlockArgs_fjrv01
@end

typedef void  (^_ListenerTrampoline_38)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_38 _1uu024u_wrapListenerBlock_fjrv01(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_38 weakSelfBlock = nil;
  _ListenerTrampoline_38 strongSelfBlock = [^void(void * arg0, id arg1, id arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_fjrv01* args = [[_1uu024u_BlockArgs_fjrv01 alloc] init];
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

typedef void  (^_BlockingTrampoline_38)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_38 _1uu024u_wrapBlockingBlock_fjrv01(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_38, ^void(void * arg0, id arg1, id arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_fjrv01* args = [[_1uu024u_BlockArgs_fjrv01 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_fjrv01* args = [[_1uu024u_BlockArgs_fjrv01 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_23)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_fjrv01(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_23)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_zzthnb : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property BOOL arg2;
@end
@implementation _1uu024u_BlockArgs_zzthnb
@end

typedef void  (^_ListenerTrampoline_39)(void * arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_39 _1uu024u_wrapListenerBlock_zzthnb(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_39 weakSelfBlock = nil;
  _ListenerTrampoline_39 strongSelfBlock = [^void(void * arg0, id arg1, BOOL arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_zzthnb* args = [[_1uu024u_BlockArgs_zzthnb alloc] init];
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

typedef void  (^_BlockingTrampoline_39)(void * waiter, void * arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_39 _1uu024u_wrapBlockingBlock_zzthnb(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_39, ^void(void * arg0, id arg1, BOOL arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_zzthnb* args = [[_1uu024u_BlockArgs_zzthnb alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_zzthnb* args = [[_1uu024u_BlockArgs_zzthnb alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_24)(void * sel, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_zzthnb(id target, void * sel, id arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_24)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_18v1jvf : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@end
@implementation _1uu024u_BlockArgs_18v1jvf
@end

typedef void  (^_ListenerTrampoline_40)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_40 _1uu024u_wrapListenerBlock_18v1jvf(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_40 weakSelfBlock = nil;
  _ListenerTrampoline_40 strongSelfBlock = [^void(void * arg0, id arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_18v1jvf* args = [[_1uu024u_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_40)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_40 _1uu024u_wrapBlockingBlock_18v1jvf(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_40, ^void(void * arg0, id arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_18v1jvf* args = [[_1uu024u_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_18v1jvf* args = [[_1uu024u_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_25)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_25)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1tz5yf : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (strong) id arg3;
@end
@implementation _1uu024u_BlockArgs_1tz5yf
@end

typedef void  (^_ListenerTrampoline_41)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_41 _1uu024u_wrapListenerBlock_1tz5yf(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_41 weakSelfBlock = nil;
  _ListenerTrampoline_41 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1tz5yf* args = [[_1uu024u_BlockArgs_1tz5yf alloc] init];
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

typedef void  (^_BlockingTrampoline_41)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_41 _1uu024u_wrapBlockingBlock_1tz5yf(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_41, ^void(void * arg0, id arg1, id arg2, id arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1tz5yf* args = [[_1uu024u_BlockArgs_1tz5yf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1tz5yf* args = [[_1uu024u_BlockArgs_1tz5yf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_26)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_1tz5yf(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_26)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_8acz2h : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property BOOL arg3;
@end
@implementation _1uu024u_BlockArgs_8acz2h
@end

typedef void  (^_ListenerTrampoline_42)(void * arg0, id arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_42 _1uu024u_wrapListenerBlock_8acz2h(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_42 weakSelfBlock = nil;
  _ListenerTrampoline_42 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, BOOL arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_8acz2h* args = [[_1uu024u_BlockArgs_8acz2h alloc] init];
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

typedef void  (^_BlockingTrampoline_42)(void * waiter, void * arg0, id arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_42 _1uu024u_wrapBlockingBlock_8acz2h(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_42, ^void(void * arg0, id arg1, id arg2, BOOL arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_8acz2h* args = [[_1uu024u_BlockArgs_8acz2h alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_8acz2h* args = [[_1uu024u_BlockArgs_8acz2h alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_27)(void * sel, id arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_8acz2h(id target, void * sel, id arg1, id arg2, BOOL arg3) {
  return ((_ProtocolTrampoline_27)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1cn988u : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property unsigned long arg2;
@property (strong) id arg3;
@property (strong) id arg4;
@property (strong) id arg5;
@end
@implementation _1uu024u_BlockArgs_1cn988u
@end

typedef void  (^_ListenerTrampoline_43)(void * arg0, id arg1, unsigned long arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_43 _1uu024u_wrapListenerBlock_1cn988u(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_43 weakSelfBlock = nil;
  _ListenerTrampoline_43 strongSelfBlock = [^void(void * arg0, id arg1, unsigned long arg2, id arg3, id arg4, id arg5) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1cn988u* args = [[_1uu024u_BlockArgs_1cn988u alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_43)(void * waiter, void * arg0, id arg1, unsigned long arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_43 _1uu024u_wrapBlockingBlock_1cn988u(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_43, ^void(void * arg0, id arg1, unsigned long arg2, id arg3, id arg4, id arg5), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1cn988u* args = [[_1uu024u_BlockArgs_1cn988u alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1cn988u* args = [[_1uu024u_BlockArgs_1cn988u alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_28)(void * sel, id arg1, unsigned long arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_1cn988u(id target, void * sel, id arg1, unsigned long arg2, id arg3, id arg4, id arg5) {
  return ((_ProtocolTrampoline_28)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_zuf90e : NSObject
@property (copy) id block;
@property void * arg0;
@property unsigned long arg1;
@end
@implementation _1uu024u_BlockArgs_zuf90e
@end

typedef void  (^_ListenerTrampoline_44)(void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_44 _1uu024u_wrapListenerBlock_zuf90e(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_44 weakSelfBlock = nil;
  _ListenerTrampoline_44 strongSelfBlock = [^void(void * arg0, unsigned long arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_zuf90e* args = [[_1uu024u_BlockArgs_zuf90e alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_44)(void * waiter, void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_44 _1uu024u_wrapBlockingBlock_zuf90e(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_44, ^void(void * arg0, unsigned long arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_zuf90e* args = [[_1uu024u_BlockArgs_zuf90e alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_zuf90e* args = [[_1uu024u_BlockArgs_zuf90e alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_29)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_zuf90e(id target, void * sel, unsigned long arg1) {
  return ((_ProtocolTrampoline_29)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_15e9dqx : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property long arg2;
@property long arg3;
@property long arg4;
@end
@implementation _1uu024u_BlockArgs_15e9dqx
@end

typedef void  (^_ListenerTrampoline_45)(void * arg0, id arg1, long arg2, long arg3, long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_45 _1uu024u_wrapListenerBlock_15e9dqx(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_45 weakSelfBlock = nil;
  _ListenerTrampoline_45 strongSelfBlock = [^void(void * arg0, id arg1, long arg2, long arg3, long arg4) {
    @autoreleasepool {
      _1uu024u_BlockArgs_15e9dqx* args = [[_1uu024u_BlockArgs_15e9dqx alloc] init];
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

typedef void  (^_BlockingTrampoline_45)(void * waiter, void * arg0, id arg1, long arg2, long arg3, long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_45 _1uu024u_wrapBlockingBlock_15e9dqx(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_45, ^void(void * arg0, id arg1, long arg2, long arg3, long arg4), {
    @autoreleasepool {
      _1uu024u_BlockArgs_15e9dqx* args = [[_1uu024u_BlockArgs_15e9dqx alloc] init];
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
      _1uu024u_BlockArgs_15e9dqx* args = [[_1uu024u_BlockArgs_15e9dqx alloc] init];
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

typedef void  (^_ProtocolTrampoline_30)(void * sel, id arg1, long arg2, long arg3, long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_15e9dqx(id target, void * sel, id arg1, long arg2, long arg3, long arg4) {
  return ((_ProtocolTrampoline_30)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_9crvvv : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property long long arg2;
@property long long arg3;
@end
@implementation _1uu024u_BlockArgs_9crvvv
@end

typedef void  (^_ListenerTrampoline_46)(void * arg0, id arg1, long long arg2, long long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_46 _1uu024u_wrapListenerBlock_9crvvv(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_46 weakSelfBlock = nil;
  _ListenerTrampoline_46 strongSelfBlock = [^void(void * arg0, id arg1, long long arg2, long long arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_9crvvv* args = [[_1uu024u_BlockArgs_9crvvv alloc] init];
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

typedef void  (^_BlockingTrampoline_46)(void * waiter, void * arg0, id arg1, long long arg2, long long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_46 _1uu024u_wrapBlockingBlock_9crvvv(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_46, ^void(void * arg0, id arg1, long long arg2, long long arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_9crvvv* args = [[_1uu024u_BlockArgs_9crvvv alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_9crvvv* args = [[_1uu024u_BlockArgs_9crvvv alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_31)(void * sel, id arg1, long long arg2, long long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_9crvvv(id target, void * sel, id arg1, long long arg2, long long arg3) {
  return ((_ProtocolTrampoline_31)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1qf1qkl : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property long long arg2;
@property long long arg3;
@property long long arg4;
@end
@implementation _1uu024u_BlockArgs_1qf1qkl
@end

typedef void  (^_ListenerTrampoline_47)(void * arg0, id arg1, long long arg2, long long arg3, long long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_47 _1uu024u_wrapListenerBlock_1qf1qkl(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_47 weakSelfBlock = nil;
  _ListenerTrampoline_47 strongSelfBlock = [^void(void * arg0, id arg1, long long arg2, long long arg3, long long arg4) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1qf1qkl* args = [[_1uu024u_BlockArgs_1qf1qkl alloc] init];
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

typedef void  (^_BlockingTrampoline_47)(void * waiter, void * arg0, id arg1, long long arg2, long long arg3, long long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_47 _1uu024u_wrapBlockingBlock_1qf1qkl(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_47, ^void(void * arg0, id arg1, long long arg2, long long arg3, long long arg4), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1qf1qkl* args = [[_1uu024u_BlockArgs_1qf1qkl alloc] init];
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
      _1uu024u_BlockArgs_1qf1qkl* args = [[_1uu024u_BlockArgs_1qf1qkl alloc] init];
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

typedef void  (^_ProtocolTrampoline_32)(void * sel, id arg1, long long arg2, long long arg3, long long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_1qf1qkl(id target, void * sel, id arg1, long long arg2, long long arg3, long long arg4) {
  return ((_ProtocolTrampoline_32)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_wy9lus : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property unsigned long arg2;
@end
@implementation _1uu024u_BlockArgs_wy9lus
@end

typedef void  (^_ListenerTrampoline_48)(void * arg0, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_48 _1uu024u_wrapListenerBlock_wy9lus(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_48 weakSelfBlock = nil;
  _ListenerTrampoline_48 strongSelfBlock = [^void(void * arg0, id arg1, unsigned long arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_wy9lus* args = [[_1uu024u_BlockArgs_wy9lus alloc] init];
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

typedef void  (^_BlockingTrampoline_48)(void * waiter, void * arg0, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_48 _1uu024u_wrapBlockingBlock_wy9lus(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_48, ^void(void * arg0, id arg1, unsigned long arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_wy9lus* args = [[_1uu024u_BlockArgs_wy9lus alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_wy9lus* args = [[_1uu024u_BlockArgs_wy9lus alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_33)(void * sel, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_wy9lus(id target, void * sel, id arg1, unsigned long arg2) {
  return ((_ProtocolTrampoline_33)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_34xzuf : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property long long arg3;
@end
@implementation _1uu024u_BlockArgs_34xzuf
@end

typedef void  (^_ListenerTrampoline_49)(void * arg0, id arg1, id arg2, long long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_49 _1uu024u_wrapListenerBlock_34xzuf(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_49 weakSelfBlock = nil;
  _ListenerTrampoline_49 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, long long arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_34xzuf* args = [[_1uu024u_BlockArgs_34xzuf alloc] init];
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

typedef void  (^_BlockingTrampoline_49)(void * waiter, void * arg0, id arg1, id arg2, long long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_49 _1uu024u_wrapBlockingBlock_34xzuf(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_49, ^void(void * arg0, id arg1, id arg2, long long arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_34xzuf* args = [[_1uu024u_BlockArgs_34xzuf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_34xzuf* args = [[_1uu024u_BlockArgs_34xzuf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_34)(void * sel, id arg1, id arg2, long long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_34xzuf(id target, void * sel, id arg1, id arg2, long long arg3) {
  return ((_ProtocolTrampoline_34)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1j7coyk : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property NSURLCacheStoragePolicy arg3;
@end
@implementation _1uu024u_BlockArgs_1j7coyk
@end

typedef void  (^_ListenerTrampoline_50)(void * arg0, id arg1, id arg2, NSURLCacheStoragePolicy arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_50 _1uu024u_wrapListenerBlock_1j7coyk(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_50 weakSelfBlock = nil;
  _ListenerTrampoline_50 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, NSURLCacheStoragePolicy arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1j7coyk* args = [[_1uu024u_BlockArgs_1j7coyk alloc] init];
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

typedef void  (^_BlockingTrampoline_50)(void * waiter, void * arg0, id arg1, id arg2, NSURLCacheStoragePolicy arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_50 _1uu024u_wrapBlockingBlock_1j7coyk(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_50, ^void(void * arg0, id arg1, id arg2, NSURLCacheStoragePolicy arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1j7coyk* args = [[_1uu024u_BlockArgs_1j7coyk alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1j7coyk* args = [[_1uu024u_BlockArgs_1j7coyk alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_35)(void * sel, id arg1, id arg2, NSURLCacheStoragePolicy arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_1j7coyk(id target, void * sel, id arg1, id arg2, NSURLCacheStoragePolicy arg3) {
  return ((_ProtocolTrampoline_35)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_bklti2 : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (copy) id arg3;
@end
@implementation _1uu024u_BlockArgs_bklti2
@end

typedef void  (^_ListenerTrampoline_51)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_51 _1uu024u_wrapListenerBlock_bklti2(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_51 weakSelfBlock = nil;
  _ListenerTrampoline_51 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3) {
    @autoreleasepool {
      _1uu024u_BlockArgs_bklti2* args = [[_1uu024u_BlockArgs_bklti2 alloc] init];
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

typedef void  (^_BlockingTrampoline_51)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_51 _1uu024u_wrapBlockingBlock_bklti2(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_51, ^void(void * arg0, id arg1, id arg2, id arg3), {
    @autoreleasepool {
      _1uu024u_BlockArgs_bklti2* args = [[_1uu024u_BlockArgs_bklti2 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_bklti2* args = [[_1uu024u_BlockArgs_bklti2 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_36)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_bklti2(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_36)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_xx612k : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (strong) id arg3;
@property (copy) id arg4;
@end
@implementation _1uu024u_BlockArgs_xx612k
@end

typedef void  (^_ListenerTrampoline_52)(void * arg0, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_52 _1uu024u_wrapListenerBlock_xx612k(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_52 weakSelfBlock = nil;
  _ListenerTrampoline_52 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3, id arg4) {
    @autoreleasepool {
      _1uu024u_BlockArgs_xx612k* args = [[_1uu024u_BlockArgs_xx612k alloc] init];
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

typedef void  (^_BlockingTrampoline_52)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_52 _1uu024u_wrapBlockingBlock_xx612k(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_52, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4), {
    @autoreleasepool {
      _1uu024u_BlockArgs_xx612k* args = [[_1uu024u_BlockArgs_xx612k alloc] init];
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
      _1uu024u_BlockArgs_xx612k* args = [[_1uu024u_BlockArgs_xx612k alloc] init];
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

typedef void  (^_ProtocolTrampoline_37)(void * sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_xx612k(id target, void * sel, id arg1, id arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_37)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_ly2579 : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property int64_t arg3;
@property int64_t arg4;
@end
@implementation _1uu024u_BlockArgs_ly2579
@end

typedef void  (^_ListenerTrampoline_53)(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_53 _1uu024u_wrapListenerBlock_ly2579(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_53 weakSelfBlock = nil;
  _ListenerTrampoline_53 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4) {
    @autoreleasepool {
      _1uu024u_BlockArgs_ly2579* args = [[_1uu024u_BlockArgs_ly2579 alloc] init];
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

typedef void  (^_BlockingTrampoline_53)(void * waiter, void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_53 _1uu024u_wrapBlockingBlock_ly2579(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_53, ^void(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4), {
    @autoreleasepool {
      _1uu024u_BlockArgs_ly2579* args = [[_1uu024u_BlockArgs_ly2579 alloc] init];
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
      _1uu024u_BlockArgs_ly2579* args = [[_1uu024u_BlockArgs_ly2579 alloc] init];
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

typedef void  (^_ProtocolTrampoline_38)(void * sel, id arg1, id arg2, int64_t arg3, int64_t arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_ly2579(id target, void * sel, id arg1, id arg2, int64_t arg3, int64_t arg4) {
  return ((_ProtocolTrampoline_38)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_h68abb : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property int64_t arg3;
@property int64_t arg4;
@property int64_t arg5;
@end
@implementation _1uu024u_BlockArgs_h68abb
@end

typedef void  (^_ListenerTrampoline_54)(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_54 _1uu024u_wrapListenerBlock_h68abb(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_54 weakSelfBlock = nil;
  _ListenerTrampoline_54 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5) {
    @autoreleasepool {
      _1uu024u_BlockArgs_h68abb* args = [[_1uu024u_BlockArgs_h68abb alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_54)(void * waiter, void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_54 _1uu024u_wrapBlockingBlock_h68abb(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_54, ^void(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5), {
    @autoreleasepool {
      _1uu024u_BlockArgs_h68abb* args = [[_1uu024u_BlockArgs_h68abb alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_h68abb* args = [[_1uu024u_BlockArgs_h68abb alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_39)(void * sel, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_h68abb(id target, void * sel, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5) {
  return ((_ProtocolTrampoline_39)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_8jfq1p : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (strong) id arg3;
@property (strong) id arg4;
@end
@implementation _1uu024u_BlockArgs_8jfq1p
@end

typedef void  (^_ListenerTrampoline_55)(void * arg0, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_55 _1uu024u_wrapListenerBlock_8jfq1p(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_55 weakSelfBlock = nil;
  _ListenerTrampoline_55 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3, id arg4) {
    @autoreleasepool {
      _1uu024u_BlockArgs_8jfq1p* args = [[_1uu024u_BlockArgs_8jfq1p alloc] init];
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

typedef void  (^_BlockingTrampoline_55)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_55 _1uu024u_wrapBlockingBlock_8jfq1p(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_55, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4), {
    @autoreleasepool {
      _1uu024u_BlockArgs_8jfq1p* args = [[_1uu024u_BlockArgs_8jfq1p alloc] init];
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
      _1uu024u_BlockArgs_8jfq1p* args = [[_1uu024u_BlockArgs_8jfq1p alloc] init];
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

typedef void  (^_ProtocolTrampoline_40)(void * sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_8jfq1p(id target, void * sel, id arg1, id arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_40)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_jyim80 : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property int64_t arg3;
@property (copy) id arg4;
@end
@implementation _1uu024u_BlockArgs_jyim80
@end

typedef void  (^_ListenerTrampoline_56)(void * arg0, id arg1, id arg2, int64_t arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_56 _1uu024u_wrapListenerBlock_jyim80(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_56 weakSelfBlock = nil;
  _ListenerTrampoline_56 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, int64_t arg3, id arg4) {
    @autoreleasepool {
      _1uu024u_BlockArgs_jyim80* args = [[_1uu024u_BlockArgs_jyim80 alloc] init];
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

typedef void  (^_BlockingTrampoline_56)(void * waiter, void * arg0, id arg1, id arg2, int64_t arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_56 _1uu024u_wrapBlockingBlock_jyim80(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_56, ^void(void * arg0, id arg1, id arg2, int64_t arg3, id arg4), {
    @autoreleasepool {
      _1uu024u_BlockArgs_jyim80* args = [[_1uu024u_BlockArgs_jyim80 alloc] init];
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
      _1uu024u_BlockArgs_jyim80* args = [[_1uu024u_BlockArgs_jyim80 alloc] init];
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

typedef void  (^_ProtocolTrampoline_41)(void * sel, id arg1, id arg2, int64_t arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_jyim80(id target, void * sel, id arg1, id arg2, int64_t arg3, id arg4) {
  return ((_ProtocolTrampoline_41)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_l2g8ke : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (strong) id arg3;
@property (strong) id arg4;
@property (copy) id arg5;
@end
@implementation _1uu024u_BlockArgs_l2g8ke
@end

typedef void  (^_ListenerTrampoline_57)(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_57 _1uu024u_wrapListenerBlock_l2g8ke(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_57 weakSelfBlock = nil;
  _ListenerTrampoline_57 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5) {
    @autoreleasepool {
      _1uu024u_BlockArgs_l2g8ke* args = [[_1uu024u_BlockArgs_l2g8ke alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_57)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_57 _1uu024u_wrapBlockingBlock_l2g8ke(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_57, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5), {
    @autoreleasepool {
      _1uu024u_BlockArgs_l2g8ke* args = [[_1uu024u_BlockArgs_l2g8ke alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_l2g8ke* args = [[_1uu024u_BlockArgs_l2g8ke alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_42)(void * sel, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_l2g8ke(id target, void * sel, id arg1, id arg2, id arg3, id arg4, id arg5) {
  return ((_ProtocolTrampoline_42)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1lx650f : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property NSURLSessionWebSocketCloseCode arg3;
@property (strong) id arg4;
@end
@implementation _1uu024u_BlockArgs_1lx650f
@end

typedef void  (^_ListenerTrampoline_58)(void * arg0, id arg1, id arg2, NSURLSessionWebSocketCloseCode arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_58 _1uu024u_wrapListenerBlock_1lx650f(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_58 weakSelfBlock = nil;
  _ListenerTrampoline_58 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, NSURLSessionWebSocketCloseCode arg3, id arg4) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1lx650f* args = [[_1uu024u_BlockArgs_1lx650f alloc] init];
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

typedef void  (^_BlockingTrampoline_58)(void * waiter, void * arg0, id arg1, id arg2, NSURLSessionWebSocketCloseCode arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_58 _1uu024u_wrapBlockingBlock_1lx650f(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_58, ^void(void * arg0, id arg1, id arg2, NSURLSessionWebSocketCloseCode arg3, id arg4), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1lx650f* args = [[_1uu024u_BlockArgs_1lx650f alloc] init];
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
      _1uu024u_BlockArgs_1lx650f* args = [[_1uu024u_BlockArgs_1lx650f alloc] init];
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

typedef void  (^_ProtocolTrampoline_43)(void * sel, id arg1, id arg2, NSURLSessionWebSocketCloseCode arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_1lx650f(id target, void * sel, id arg1, id arg2, NSURLSessionWebSocketCloseCode arg3, id arg4) {
  return ((_ProtocolTrampoline_43)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_jk1ljc : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (copy) id arg2;
@end
@implementation _1uu024u_BlockArgs_jk1ljc
@end

typedef void  (^_ListenerTrampoline_59)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_59 _1uu024u_wrapListenerBlock_jk1ljc(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_59 weakSelfBlock = nil;
  _ListenerTrampoline_59 strongSelfBlock = [^void(void * arg0, id arg1, id arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_jk1ljc* args = [[_1uu024u_BlockArgs_jk1ljc alloc] init];
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

typedef void  (^_BlockingTrampoline_59)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_59 _1uu024u_wrapBlockingBlock_jk1ljc(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_59, ^void(void * arg0, id arg1, id arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_jk1ljc* args = [[_1uu024u_BlockArgs_jk1ljc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_jk1ljc* args = [[_1uu024u_BlockArgs_jk1ljc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_44)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_jk1ljc(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_44)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_m09tr7 : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (strong) id arg3;
@property (strong) id arg4;
@property (strong) id arg5;
@end
@implementation _1uu024u_BlockArgs_m09tr7
@end

typedef void  (^_ListenerTrampoline_60)(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_60 _1uu024u_wrapListenerBlock_m09tr7(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_60 weakSelfBlock = nil;
  _ListenerTrampoline_60 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5) {
    @autoreleasepool {
      _1uu024u_BlockArgs_m09tr7* args = [[_1uu024u_BlockArgs_m09tr7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_60)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_60 _1uu024u_wrapBlockingBlock_m09tr7(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_60, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5), {
    @autoreleasepool {
      _1uu024u_BlockArgs_m09tr7* args = [[_1uu024u_BlockArgs_m09tr7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_m09tr7* args = [[_1uu024u_BlockArgs_m09tr7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      args.arg5 = arg5;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_45)(void * sel, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_m09tr7(id target, void * sel, id arg1, id arg2, id arg3, id arg4, id arg5) {
  return ((_ProtocolTrampoline_45)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_10lndml : NSObject
@property (copy) id block;
@property void * arg0;
@property BOOL arg1;
@end
@implementation _1uu024u_BlockArgs_10lndml
@end

typedef void  (^_ListenerTrampoline_61)(void * arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_61 _1uu024u_wrapListenerBlock_10lndml(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_61 weakSelfBlock = nil;
  _ListenerTrampoline_61 strongSelfBlock = [^void(void * arg0, BOOL arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_10lndml* args = [[_1uu024u_BlockArgs_10lndml alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_61)(void * waiter, void * arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_61 _1uu024u_wrapBlockingBlock_10lndml(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_61, ^void(void * arg0, BOOL arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_10lndml* args = [[_1uu024u_BlockArgs_10lndml alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_10lndml* args = [[_1uu024u_BlockArgs_10lndml alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_46)(void * sel, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_10lndml(id target, void * sel, BOOL arg1) {
  return ((_ProtocolTrampoline_46)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1037nh9 : NSObject
@property (copy) id block;
@property void * arg0;
@property void * arg1;
@end
@implementation _1uu024u_BlockArgs_1037nh9
@end

typedef void  (^_ListenerTrampoline_62)(void * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_62 _1uu024u_wrapListenerBlock_1037nh9(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_62 weakSelfBlock = nil;
  _ListenerTrampoline_62 strongSelfBlock = [^void(void * arg0, void * arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1037nh9* args = [[_1uu024u_BlockArgs_1037nh9 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_62)(void * waiter, void * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_62 _1uu024u_wrapBlockingBlock_1037nh9(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_62, ^void(void * arg0, void * arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1037nh9* args = [[_1uu024u_BlockArgs_1037nh9 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1037nh9* args = [[_1uu024u_BlockArgs_1037nh9 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_47)(void * sel, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_1037nh9(id target, void * sel, void * arg1) {
  return ((_ProtocolTrampoline_47)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_1l4hxwm : NSObject
@property (copy) id block;
@property void * arg0;
@property (copy) id arg1;
@end
@implementation _1uu024u_BlockArgs_1l4hxwm
@end

typedef void  (^_ListenerTrampoline_63)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_63 _1uu024u_wrapListenerBlock_1l4hxwm(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_63 weakSelfBlock = nil;
  _ListenerTrampoline_63 strongSelfBlock = [^void(void * arg0, id arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_1l4hxwm* args = [[_1uu024u_BlockArgs_1l4hxwm alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_63)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_63 _1uu024u_wrapBlockingBlock_1l4hxwm(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_63, ^void(void * arg0, id arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_1l4hxwm* args = [[_1uu024u_BlockArgs_1l4hxwm alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_1l4hxwm* args = [[_1uu024u_BlockArgs_1l4hxwm alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_48)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1uu024u_protocolTrampoline_1l4hxwm(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_48)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_18qun1e : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property (strong) id arg1;
@property (copy) id arg2;
@end
@implementation _1uu024u_BlockArgs_18qun1e
@end

typedef void  (^_ListenerTrampoline_64)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_64 _1uu024u_wrapListenerBlock_18qun1e(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_64 weakSelfBlock = nil;
  _ListenerTrampoline_64 strongSelfBlock = [^void(id arg0, id arg1, id arg2) {
    @autoreleasepool {
      _1uu024u_BlockArgs_18qun1e* args = [[_1uu024u_BlockArgs_18qun1e alloc] init];
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

typedef void  (^_BlockingTrampoline_64)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_64 _1uu024u_wrapBlockingBlock_18qun1e(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_64, ^void(id arg0, id arg1, id arg2), {
    @autoreleasepool {
      _1uu024u_BlockArgs_18qun1e* args = [[_1uu024u_BlockArgs_18qun1e alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_18qun1e* args = [[_1uu024u_BlockArgs_18qun1e alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1uu024u_BlockArgs_o762yo : NSObject
@property (copy) id block;
@property (strong) id arg0;
@property (copy) id arg1;
@end
@implementation _1uu024u_BlockArgs_o762yo
@end

typedef void  (^_ListenerTrampoline_65)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_65 _1uu024u_wrapListenerBlock_o762yo(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_65 weakSelfBlock = nil;
  _ListenerTrampoline_65 strongSelfBlock = [^void(id arg0, id arg1) {
    @autoreleasepool {
      _1uu024u_BlockArgs_o762yo* args = [[_1uu024u_BlockArgs_o762yo alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_65)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_65 _1uu024u_wrapBlockingBlock_o762yo(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_65, ^void(id arg0, id arg1), {
    @autoreleasepool {
      _1uu024u_BlockArgs_o762yo* args = [[_1uu024u_BlockArgs_o762yo alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1uu024u_BlockArgs_o762yo* args = [[_1uu024u_BlockArgs_o762yo alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef id  (^_ProtocolTrampoline_49)(void * sel, id arg1, id arg2 __attribute__((ns_consumed)));
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_1p0fswn(id target, void * sel, id arg1, id arg2 __attribute__((ns_consumed))) {
  return ((_ProtocolTrampoline_49)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_50)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1uu024u_protocolTrampoline_wpy7aa(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_50)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef struct ppd_file_s *  (^_ProtocolTrampoline_51)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct ppd_file_s *  _1uu024u_protocolTrampoline_10vn635(id target, void * sel) {
  return ((_ProtocolTrampoline_51)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_PDEPanel(void) { return @protocol(PDEPanel); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_PDEPlugIn(void) { return @protocol(PDEPlugIn); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1uu024u_PDEPlugInCallbackProtocol(void) { return @protocol(PDEPlugInCallbackProtocol); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
