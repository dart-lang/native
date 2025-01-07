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

Protocol* _ObjectiveCBindings_NSStreamDelegate(void) { return @protocol(NSStreamDelegate); }

typedef id  (^_BlockType)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType _ObjectiveCBindings_newClosureBlock_1yesha9(
    id  (*trampoline)(void * , void * ), void* target) NS_RETURNS_RETAINED {
  return ^id (void * arg0) {
    return trampoline(target, arg0);
  };
}

typedef unsigned long  (^_BlockType1)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType1 _ObjectiveCBindings_newClosureBlock_1ckyi24(
    unsigned long  (*trampoline)(void * , void * ), void* target) NS_RETURNS_RETAINED {
  return ^unsigned long (void * arg0) {
    return trampoline(target, arg0);
  };
}

typedef unsigned long  (^_BlockType2)(void * arg0, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType2 _ObjectiveCBindings_newClosureBlock_17ap02x(
    unsigned long  (*trampoline)(void * , void * , NSFastEnumerationState * , id * , unsigned long ), void* target) NS_RETURNS_RETAINED {
  return ^unsigned long (void * arg0, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3) {
    return trampoline(target, arg0, arg1, arg2, arg3);
  };
}

typedef struct _NSZone *  (^_BlockType3)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType3 _ObjectiveCBindings_newClosureBlock_1a8cl66(
    struct _NSZone *  (*trampoline)(void * , void * ), void* target) NS_RETURNS_RETAINED {
  return ^struct _NSZone * (void * arg0) {
    return trampoline(target, arg0);
  };
}

typedef BOOL  (^_BlockType4)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType4 _ObjectiveCBindings_newClosureBlock_e3qsqz(
    BOOL  (*trampoline)(void * , void * ), void* target) NS_RETURNS_RETAINED {
  return ^BOOL (void * arg0) {
    return trampoline(target, arg0);
  };
}

typedef BOOL  (^_BlockType5)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType5 _ObjectiveCBindings_newClosureBlock_ozkafd(
    BOOL  (*trampoline)(void * , void * , id ), void* target) NS_RETURNS_RETAINED {
  return ^BOOL (void * arg0, id arg1) {
    return trampoline(target, arg0, arg1);
  };
}

typedef BOOL  (^_BlockType6)(void * arg0, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType6 _ObjectiveCBindings_newClosureBlock_w1e3k0(
    BOOL  (*trampoline)(void * , void * , struct objc_selector * ), void* target) NS_RETURNS_RETAINED {
  return ^BOOL (void * arg0, struct objc_selector * arg1) {
    return trampoline(target, arg0, arg1);
  };
}

typedef void  (^_BlockType7)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType7 _ObjectiveCBindings_newClosureBlock_1j2nt86(
    void  (*trampoline)(void * , id , id , id ), void* target) NS_RETURNS_RETAINED {
  return ^void (id arg0, id arg1, id arg2) {
    return trampoline(target, arg0, arg1, arg2);
  };
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType7 _ObjectiveCBindings_wrapListenerBlock_1j2nt86(_BlockType7 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(objc_retainBlock(arg0), objc_retain(arg1), objc_retain(arg2));
  };
}

typedef void  (^_BlockingTrampoline7)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType7 _ObjectiveCBindings_wrapBlockingBlock_1j2nt86(
    _BlockingTrampoline7 block, _BlockingTrampoline7 listenerBlock,
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  return ^void(id arg0, id arg1, id arg2) {
    if ([NSThread currentThread] == targetThread) {
      objc_retainBlock(block);
      block(nil, objc_retainBlock(arg0), objc_retain(arg1), objc_retain(arg2));
    } else {
      void* waiter = newWaiter();
      objc_retainBlock(listenerBlock);
      listenerBlock(waiter, objc_retainBlock(arg0), objc_retain(arg1), objc_retain(arg2));
      awaitWaiter(waiter);
    }
  };
}

typedef void  (^_BlockType8)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType8 _ObjectiveCBindings_newClosureBlock_ovsamd(
    void  (*trampoline)(void * , void * ), void* target) NS_RETURNS_RETAINED {
  return ^void (void * arg0) {
    return trampoline(target, arg0);
  };
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType8 _ObjectiveCBindings_wrapListenerBlock_ovsamd(_BlockType8 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline8)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType8 _ObjectiveCBindings_wrapBlockingBlock_ovsamd(
    _BlockingTrampoline8 block, _BlockingTrampoline8 listenerBlock,
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  return ^void(void * arg0) {
    if ([NSThread currentThread] == targetThread) {
      objc_retainBlock(block);
      block(nil, arg0);
    } else {
      void* waiter = newWaiter();
      objc_retainBlock(listenerBlock);
      listenerBlock(waiter, arg0);
      awaitWaiter(waiter);
    }
  };
}

typedef void  (^_BlockType9)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType9 _ObjectiveCBindings_newClosureBlock_wjovn7(
    void  (*trampoline)(void * , void * , id ), void* target) NS_RETURNS_RETAINED {
  return ^void (void * arg0, id arg1) {
    return trampoline(target, arg0, arg1);
  };
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType9 _ObjectiveCBindings_wrapListenerBlock_wjovn7(_BlockType9 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, objc_retain(arg1));
  };
}

typedef void  (^_BlockingTrampoline9)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType9 _ObjectiveCBindings_wrapBlockingBlock_wjovn7(
    _BlockingTrampoline9 block, _BlockingTrampoline9 listenerBlock,
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  return ^void(void * arg0, id arg1) {
    if ([NSThread currentThread] == targetThread) {
      objc_retainBlock(block);
      block(nil, arg0, objc_retain(arg1));
    } else {
      void* waiter = newWaiter();
      objc_retainBlock(listenerBlock);
      listenerBlock(waiter, arg0, objc_retain(arg1));
      awaitWaiter(waiter);
    }
  };
}

typedef void  (^_BlockType10)(void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType10 _ObjectiveCBindings_newClosureBlock_18d6mda(
    void  (*trampoline)(void * , void * , id , NSStreamEvent ), void* target) NS_RETURNS_RETAINED {
  return ^void (void * arg0, id arg1, NSStreamEvent arg2) {
    return trampoline(target, arg0, arg1, arg2);
  };
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType10 _ObjectiveCBindings_wrapListenerBlock_18d6mda(_BlockType10 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, NSStreamEvent arg2) {
    objc_retainBlock(block);
    block(arg0, objc_retain(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline10)(void * waiter, void * arg0, id arg1, NSStreamEvent arg2);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType10 _ObjectiveCBindings_wrapBlockingBlock_18d6mda(
    _BlockingTrampoline10 block, _BlockingTrampoline10 listenerBlock,
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  return ^void(void * arg0, id arg1, NSStreamEvent arg2) {
    if ([NSThread currentThread] == targetThread) {
      objc_retainBlock(block);
      block(nil, arg0, objc_retain(arg1), arg2);
    } else {
      void* waiter = newWaiter();
      objc_retainBlock(listenerBlock);
      listenerBlock(waiter, arg0, objc_retain(arg1), arg2);
      awaitWaiter(waiter);
    }
  };
}

typedef void  (^_BlockType11)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType11 _ObjectiveCBindings_newClosureBlock_wjvic9(
    void  (*trampoline)(void * , id , id ), void* target) NS_RETURNS_RETAINED {
  return ^void (id arg0, id arg1) {
    return trampoline(target, arg0, arg1);
  };
}

__attribute__((visibility("default"))) __attribute__((used))
_BlockType11 _ObjectiveCBindings_wrapListenerBlock_wjvic9(_BlockType11 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block(objc_retain(arg0), objc_retain(arg1));
  };
}

typedef void  (^_BlockingTrampoline11)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType11 _ObjectiveCBindings_wrapBlockingBlock_wjvic9(
    _BlockingTrampoline11 block, _BlockingTrampoline11 listenerBlock,
    void* (*newWaiter)(), void (*awaitWaiter)(void*)) NS_RETURNS_RETAINED {
  NSThread *targetThread = [NSThread currentThread];
  return ^void(id arg0, id arg1) {
    if ([NSThread currentThread] == targetThread) {
      objc_retainBlock(block);
      block(nil, objc_retain(arg0), objc_retain(arg1));
    } else {
      void* waiter = newWaiter();
      objc_retainBlock(listenerBlock);
      listenerBlock(waiter, objc_retain(arg0), objc_retain(arg1));
      awaitWaiter(waiter);
    }
  };
}

typedef id  (^_BlockType12)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType12 _ObjectiveCBindings_newClosureBlock_1m9h2n(
    id  (*trampoline)(void * , void * , id ), void* target) NS_RETURNS_RETAINED {
  return ^id (void * arg0, id arg1) {
    return trampoline(target, arg0, arg1);
  };
}

typedef id  (^_BlockType13)(void * arg0, id arg1, id arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType13 _ObjectiveCBindings_newClosureBlock_e2pkq8(
    id  (*trampoline)(void * , void * , id , id , id * ), void* target) NS_RETURNS_RETAINED {
  return ^id (void * arg0, id arg1, id arg2, id * arg3) {
    return trampoline(target, arg0, arg1, arg2, arg3);
  };
}

typedef id  (^_BlockType14)(void * arg0, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType14 _ObjectiveCBindings_newClosureBlock_ykn0t6(
    id  (*trampoline)(void * , void * , struct objc_selector * ), void* target) NS_RETURNS_RETAINED {
  return ^id (void * arg0, struct objc_selector * arg1) {
    return trampoline(target, arg0, arg1);
  };
}

typedef id  (^_BlockType15)(void * arg0, struct objc_selector * arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType15 _ObjectiveCBindings_newClosureBlock_1c0c70u(
    id  (*trampoline)(void * , void * , struct objc_selector * , id ), void* target) NS_RETURNS_RETAINED {
  return ^id (void * arg0, struct objc_selector * arg1, id arg2) {
    return trampoline(target, arg0, arg1, arg2);
  };
}

typedef id  (^_BlockType16)(void * arg0, struct objc_selector * arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_BlockType16 _ObjectiveCBindings_newClosureBlock_u8b97m(
    id  (*trampoline)(void * , void * , struct objc_selector * , id , id ), void* target) NS_RETURNS_RETAINED {
  return ^id (void * arg0, struct objc_selector * arg1, id arg2, id arg3) {
    return trampoline(target, arg0, arg1, arg2, arg3);
  };
}
