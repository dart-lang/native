#include <stdint.h>
#import <Foundation/Foundation.h>
#import "foundation.h"
#import "input_stream_adapter.h"
#import "proxy.h"

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

id objc_retain(id);
id objc_retainBlock(id);

@interface _ObjectiveCBindings_BlockDestroyer : NSObject {}
@property int64_t closure_id;
@property int64_t dispose_port;
@property void (*dtor)(int64_t, int64_t);
+ (instancetype)new:(int64_t) closure_id disposePort:(int64_t) dispose_port
    destructor:(void (*)(int64_t, int64_t)) dtor;
- (void)dealloc;
@end
@implementation _ObjectiveCBindings_BlockDestroyer
+ (instancetype)new:(int64_t) closure_id disposePort:(int64_t) dispose_port
    destructor:(void (*)(int64_t, int64_t)) dtor {
  _ObjectiveCBindings_BlockDestroyer* d = [[_ObjectiveCBindings_BlockDestroyer alloc] init];
  d.closure_id = closure_id;
  d.dispose_port = dispose_port;
  d.dtor = dtor;
  return d;
}
- (void)dealloc { self.dtor(self.dispose_port, self.closure_id); }
@end

Protocol* _ObjectiveCBindings_NSStreamDelegate(void) { return @protocol(NSStreamDelegate); }

typedef id  (^_BlockType)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_invokeBlock_1yesha9(
    _BlockType block, void * arg0)  {
  return block(arg0);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType _ObjectiveCBindings_newClosureBlock_1yesha9(
    id  (*trampoline)(id , int64_t , void * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType weakBlk;
  _BlockType blk = ^id (void * arg0) {
    return trampoline(weakBlk, obj.closure_id, arg0);
  };
  weakBlk = blk;
  return blk;
}

typedef unsigned long  (^_BlockType1)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _ObjectiveCBindings_invokeBlock_1ckyi24(
    _BlockType1 block, void * arg0)  {
  return block(arg0);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType1 _ObjectiveCBindings_newClosureBlock_1ckyi24(
    unsigned long  (*trampoline)(id , int64_t , void * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType1 weakBlk;
  _BlockType1 blk = ^unsigned long (void * arg0) {
    return trampoline(weakBlk, obj.closure_id, arg0);
  };
  weakBlk = blk;
  return blk;
}

typedef unsigned long  (^_BlockType2)(void * arg0, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _ObjectiveCBindings_invokeBlock_17ap02x(
    _BlockType2 block, void * arg0, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3)  {
  return block(arg0, arg1, arg2, arg3);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType2 _ObjectiveCBindings_newClosureBlock_17ap02x(
    unsigned long  (*trampoline)(id , int64_t , void * , NSFastEnumerationState * , id * , unsigned long ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType2 weakBlk;
  _BlockType2 blk = ^unsigned long (void * arg0, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1, arg2, arg3);
  };
  weakBlk = blk;
  return blk;
}

typedef struct _NSZone *  (^_BlockType3)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
struct _NSZone *  _ObjectiveCBindings_invokeBlock_1a8cl66(
    _BlockType3 block, void * arg0)  {
  return block(arg0);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType3 _ObjectiveCBindings_newClosureBlock_1a8cl66(
    struct _NSZone *  (*trampoline)(id , int64_t , void * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType3 weakBlk;
  _BlockType3 blk = ^struct _NSZone * (void * arg0) {
    return trampoline(weakBlk, obj.closure_id, arg0);
  };
  weakBlk = blk;
  return blk;
}

typedef BOOL  (^_BlockType4)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _ObjectiveCBindings_invokeBlock_e3qsqz(
    _BlockType4 block, void * arg0)  {
  return block(arg0);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType4 _ObjectiveCBindings_newClosureBlock_e3qsqz(
    BOOL  (*trampoline)(id , int64_t , void * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType4 weakBlk;
  _BlockType4 blk = ^BOOL (void * arg0) {
    return trampoline(weakBlk, obj.closure_id, arg0);
  };
  weakBlk = blk;
  return blk;
}

typedef BOOL  (^_BlockType5)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _ObjectiveCBindings_invokeBlock_ozkafd(
    _BlockType5 block, void * arg0, id arg1)  {
  return block(arg0, arg1);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType5 _ObjectiveCBindings_newClosureBlock_ozkafd(
    BOOL  (*trampoline)(id , int64_t , void * , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType5 weakBlk;
  _BlockType5 blk = ^BOOL (void * arg0, id arg1) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1);
  };
  weakBlk = blk;
  return blk;
}

typedef BOOL  (^_BlockType6)(void * arg0, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _ObjectiveCBindings_invokeBlock_w1e3k0(
    _BlockType6 block, void * arg0, struct objc_selector * arg1)  {
  return block(arg0, arg1);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType6 _ObjectiveCBindings_newClosureBlock_w1e3k0(
    BOOL  (*trampoline)(id , int64_t , void * , struct objc_selector * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType6 weakBlk;
  _BlockType6 blk = ^BOOL (void * arg0, struct objc_selector * arg1) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1);
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockType7)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_invokeBlock_1j2nt86(
    _BlockType7 block, id arg0, id arg1, id arg2)  {
  return block(arg0, arg1, arg2);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType7 _ObjectiveCBindings_newClosureBlock_1j2nt86(
    void  (*trampoline)(id , int64_t , id , id , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType7 weakBlk;
  _BlockType7 blk = ^void (id arg0, id arg1, id arg2) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1, arg2);
  };
  weakBlk = blk;
  return blk;
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType7 _ObjectiveCBindings_newListenerBlock_1j2nt86(
    void  (*trampoline)(id , int64_t , id , id , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType7 weakBlk;
  _BlockType7 blk = ^void (id arg0, id arg1, id arg2) {
    objc_retainBlock(weakBlk);
    return trampoline(weakBlk, obj.closure_id, objc_retainBlock(arg0), objc_retain(arg1), objc_retain(arg2));
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockingTrampoline7)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType7 _ObjectiveCBindings_newBlockingBlock_1j2nt86(
    void  (*tramp)(id , int64_t , void * , id , id , id ), void  (*listener_tramp)(id , int64_t , void * , id , id , id ),
    int64_t closure_id, int64_t dispose_port, void (*dtor)(int64_t, int64_t),
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType7 weakBlk;
  _BlockType7 blk = ^void (id arg0, id arg1, id arg2) {
    objc_retainBlock(weakBlk);
    if ([NSThread currentThread] == targetThread) {
      tramp(weakBlk, obj.closure_id, nil, objc_retainBlock(arg0), objc_retain(arg1), objc_retain(arg2));
    } else {
      void* waiter = newWaiter();
      listener_tramp(weakBlk, obj.closure_id, waiter, objc_retainBlock(arg0), objc_retain(arg1), objc_retain(arg2));
      awaitWaiter(waiter);
    }
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockType8)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_invokeBlock_ovsamd(
    _BlockType8 block, void * arg0)  {
  return block(arg0);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType8 _ObjectiveCBindings_newClosureBlock_ovsamd(
    void  (*trampoline)(id , int64_t , void * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType8 weakBlk;
  _BlockType8 blk = ^void (void * arg0) {
    return trampoline(weakBlk, obj.closure_id, arg0);
  };
  weakBlk = blk;
  return blk;
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType8 _ObjectiveCBindings_newListenerBlock_ovsamd(
    void  (*trampoline)(id , int64_t , void * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType8 weakBlk;
  _BlockType8 blk = ^void (void * arg0) {
    objc_retainBlock(weakBlk);
    return trampoline(weakBlk, obj.closure_id, arg0);
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockingTrampoline8)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType8 _ObjectiveCBindings_newBlockingBlock_ovsamd(
    void  (*tramp)(id , int64_t , void * , void * ), void  (*listener_tramp)(id , int64_t , void * , void * ),
    int64_t closure_id, int64_t dispose_port, void (*dtor)(int64_t, int64_t),
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType8 weakBlk;
  _BlockType8 blk = ^void (void * arg0) {
    objc_retainBlock(weakBlk);
    if ([NSThread currentThread] == targetThread) {
      tramp(weakBlk, obj.closure_id, nil, arg0);
    } else {
      void* waiter = newWaiter();
      listener_tramp(weakBlk, obj.closure_id, waiter, arg0);
      awaitWaiter(waiter);
    }
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockType9)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_invokeBlock_wjovn7(
    _BlockType9 block, void * arg0, id arg1)  {
  return block(arg0, arg1);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType9 _ObjectiveCBindings_newClosureBlock_wjovn7(
    void  (*trampoline)(id , int64_t , void * , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType9 weakBlk;
  _BlockType9 blk = ^void (void * arg0, id arg1) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1);
  };
  weakBlk = blk;
  return blk;
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType9 _ObjectiveCBindings_newListenerBlock_wjovn7(
    void  (*trampoline)(id , int64_t , void * , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType9 weakBlk;
  _BlockType9 blk = ^void (void * arg0, id arg1) {
    objc_retainBlock(weakBlk);
    return trampoline(weakBlk, obj.closure_id, arg0, objc_retain(arg1));
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockingTrampoline9)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType9 _ObjectiveCBindings_newBlockingBlock_wjovn7(
    void  (*tramp)(id , int64_t , void * , void * , id ), void  (*listener_tramp)(id , int64_t , void * , void * , id ),
    int64_t closure_id, int64_t dispose_port, void (*dtor)(int64_t, int64_t),
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType9 weakBlk;
  _BlockType9 blk = ^void (void * arg0, id arg1) {
    objc_retainBlock(weakBlk);
    if ([NSThread currentThread] == targetThread) {
      tramp(weakBlk, obj.closure_id, nil, arg0, objc_retain(arg1));
    } else {
      void* waiter = newWaiter();
      listener_tramp(weakBlk, obj.closure_id, waiter, arg0, objc_retain(arg1));
      awaitWaiter(waiter);
    }
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockType10)(void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_invokeBlock_18d6mda(
    _BlockType10 block, void * arg0, id arg1, NSStreamEvent arg2)  {
  return block(arg0, arg1, arg2);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType10 _ObjectiveCBindings_newClosureBlock_18d6mda(
    void  (*trampoline)(id , int64_t , void * , id , NSStreamEvent ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType10 weakBlk;
  _BlockType10 blk = ^void (void * arg0, id arg1, NSStreamEvent arg2) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1, arg2);
  };
  weakBlk = blk;
  return blk;
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType10 _ObjectiveCBindings_newListenerBlock_18d6mda(
    void  (*trampoline)(id , int64_t , void * , id , NSStreamEvent ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType10 weakBlk;
  _BlockType10 blk = ^void (void * arg0, id arg1, NSStreamEvent arg2) {
    objc_retainBlock(weakBlk);
    return trampoline(weakBlk, obj.closure_id, arg0, objc_retain(arg1), arg2);
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockingTrampoline10)(void * waiter, void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType10 _ObjectiveCBindings_newBlockingBlock_18d6mda(
    void  (*tramp)(id , int64_t , void * , void * , id , NSStreamEvent ), void  (*listener_tramp)(id , int64_t , void * , void * , id , NSStreamEvent ),
    int64_t closure_id, int64_t dispose_port, void (*dtor)(int64_t, int64_t),
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType10 weakBlk;
  _BlockType10 blk = ^void (void * arg0, id arg1, NSStreamEvent arg2) {
    objc_retainBlock(weakBlk);
    if ([NSThread currentThread] == targetThread) {
      tramp(weakBlk, obj.closure_id, nil, arg0, objc_retain(arg1), arg2);
    } else {
      void* waiter = newWaiter();
      listener_tramp(weakBlk, obj.closure_id, waiter, arg0, objc_retain(arg1), arg2);
      awaitWaiter(waiter);
    }
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockType11)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _ObjectiveCBindings_invokeBlock_wjvic9(
    _BlockType11 block, id arg0, id arg1)  {
  return block(arg0, arg1);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType11 _ObjectiveCBindings_newClosureBlock_wjvic9(
    void  (*trampoline)(id , int64_t , id , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType11 weakBlk;
  _BlockType11 blk = ^void (id arg0, id arg1) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1);
  };
  weakBlk = blk;
  return blk;
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType11 _ObjectiveCBindings_newListenerBlock_wjvic9(
    void  (*trampoline)(id , int64_t , id , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType11 weakBlk;
  _BlockType11 blk = ^void (id arg0, id arg1) {
    objc_retainBlock(weakBlk);
    return trampoline(weakBlk, obj.closure_id, objc_retain(arg0), objc_retain(arg1));
  };
  weakBlk = blk;
  return blk;
}

typedef void  (^_BlockingTrampoline11)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType11 _ObjectiveCBindings_newBlockingBlock_wjvic9(
    void  (*tramp)(id , int64_t , void * , id , id ), void  (*listener_tramp)(id , int64_t , void * , id , id ),
    int64_t closure_id, int64_t dispose_port, void (*dtor)(int64_t, int64_t),
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType11 weakBlk;
  _BlockType11 blk = ^void (id arg0, id arg1) {
    objc_retainBlock(weakBlk);
    if ([NSThread currentThread] == targetThread) {
      tramp(weakBlk, obj.closure_id, nil, objc_retain(arg0), objc_retain(arg1));
    } else {
      void* waiter = newWaiter();
      listener_tramp(weakBlk, obj.closure_id, waiter, objc_retain(arg0), objc_retain(arg1));
      awaitWaiter(waiter);
    }
  };
  weakBlk = blk;
  return blk;
}

typedef id  (^_BlockType12)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_invokeBlock_1m9h2n(
    _BlockType12 block, void * arg0, id arg1) NS_RETURNS_RETAINED {
  return block(arg0, arg1);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType12 _ObjectiveCBindings_newClosureBlock_1m9h2n(
    id  (*trampoline)(id , int64_t , void * , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType12 weakBlk;
  _BlockType12 blk = ^id (void * arg0, id arg1) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1);
  };
  weakBlk = blk;
  return blk;
}

typedef id  (^_BlockType13)(void * arg0, id arg1, id arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_invokeBlock_e2pkq8(
    _BlockType13 block, void * arg0, id arg1, id arg2, id * arg3)  {
  return block(arg0, arg1, arg2, arg3);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType13 _ObjectiveCBindings_newClosureBlock_e2pkq8(
    id  (*trampoline)(id , int64_t , void * , id , id , id * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType13 weakBlk;
  _BlockType13 blk = ^id (void * arg0, id arg1, id arg2, id * arg3) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1, arg2, arg3);
  };
  weakBlk = blk;
  return blk;
}

typedef id  (^_BlockType14)(void * arg0, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_invokeBlock_ykn0t6(
    _BlockType14 block, void * arg0, struct objc_selector * arg1)  {
  return block(arg0, arg1);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType14 _ObjectiveCBindings_newClosureBlock_ykn0t6(
    id  (*trampoline)(id , int64_t , void * , struct objc_selector * ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType14 weakBlk;
  _BlockType14 blk = ^id (void * arg0, struct objc_selector * arg1) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1);
  };
  weakBlk = blk;
  return blk;
}

typedef id  (^_BlockType15)(void * arg0, struct objc_selector * arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_invokeBlock_1c0c70u(
    _BlockType15 block, void * arg0, struct objc_selector * arg1, id arg2)  {
  return block(arg0, arg1, arg2);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType15 _ObjectiveCBindings_newClosureBlock_1c0c70u(
    id  (*trampoline)(id , int64_t , void * , struct objc_selector * , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType15 weakBlk;
  _BlockType15 blk = ^id (void * arg0, struct objc_selector * arg1, id arg2) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1, arg2);
  };
  weakBlk = blk;
  return blk;
}

typedef id  (^_BlockType16)(void * arg0, struct objc_selector * arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _ObjectiveCBindings_invokeBlock_u8b97m(
    _BlockType16 block, void * arg0, struct objc_selector * arg1, id arg2, id arg3)  {
  return block(arg0, arg1, arg2, arg3);
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType16 _ObjectiveCBindings_newClosureBlock_u8b97m(
    id  (*trampoline)(id , int64_t , void * , struct objc_selector * , id , id ), int64_t closure_id, int64_t dispose_port,
    void (*dtor)(int64_t, int64_t)) NS_RETURNS_RETAINED {
  _ObjectiveCBindings_BlockDestroyer* obj = [_ObjectiveCBindings_BlockDestroyer
      new:closure_id disposePort:dispose_port destructor:dtor];
  __weak __block _BlockType16 weakBlk;
  _BlockType16 blk = ^id (void * arg0, struct objc_selector * arg1, id arg2, id arg3) {
    return trampoline(weakBlk, obj.closure_id, arg0, arg1, arg2, arg3);
  };
  weakBlk = blk;
  return blk;
}
