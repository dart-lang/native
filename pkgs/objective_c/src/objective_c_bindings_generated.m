#include <stdint.h>
#import "foundation.h"
#import "input_stream_adapter.h"
#import "proxy.h"

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

id objc_retain(id);
id objc_retainBlock(id);

Protocol* _ObjectiveCBindings_NSStreamDelegate() { return @protocol(NSStreamDelegate); }

typedef void  (^_ListenerTrampoline)(void * arg0);
_ListenerTrampoline _ObjectiveCBindings_wrapListenerBlock_hepzs(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_ListenerTrampoline1)(void * arg0, id arg1);
_ListenerTrampoline1 _ObjectiveCBindings_wrapListenerBlock_sjfpmz(_ListenerTrampoline1 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, objc_retain(arg1));
  };
}

typedef void  (^_ListenerTrampoline2)(void * arg0, id arg1, NSStreamEvent arg2);
_ListenerTrampoline2 _ObjectiveCBindings_wrapListenerBlock_m1viep(_ListenerTrampoline2 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, NSStreamEvent arg2) {
    objc_retainBlock(block);
    block(arg0, objc_retain(arg1), arg2);
  };
}
