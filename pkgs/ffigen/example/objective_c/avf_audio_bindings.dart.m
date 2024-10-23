#include <stdint.h>
#import <AVFAudio/AVAudioPlayer.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

id objc_retain(id);
id objc_retainBlock(id);

typedef void  (^_ListenerTrampoline)();
_ListenerTrampoline _AVFAudio_wrapListenerBlock_ksby9f(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void() {
    objc_retainBlock(block);
    block();
  };
}

typedef void  (^_ListenerTrampoline1)(id arg0, id arg1, BOOL * arg2);
_ListenerTrampoline1 _AVFAudio_wrapListenerBlock_1k41wmu(_ListenerTrampoline1 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block(objc_retain(arg0), objc_retain(arg1), arg2);
  };
}

typedef void  (^_ListenerTrampoline2)(void * arg0, id arg1);
_ListenerTrampoline2 _AVFAudio_wrapListenerBlock_sjfpmz(_ListenerTrampoline2 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, objc_retain(arg1));
  };
}

typedef void  (^_ListenerTrampoline3)(id arg0, struct _NSRange arg1, BOOL * arg2);
_ListenerTrampoline3 _AVFAudio_wrapListenerBlock_1j7ar3u(_ListenerTrampoline3 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block(objc_retain(arg0), arg1, arg2);
  };
}

typedef void  (^_ListenerTrampoline4)(id arg0, BOOL arg1, BOOL * arg2);
_ListenerTrampoline4 _AVFAudio_wrapListenerBlock_rvgf02(_ListenerTrampoline4 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block(objc_retain(arg0), arg1, arg2);
  };
}

typedef void  (^_ListenerTrampoline5)(id arg0);
_ListenerTrampoline5 _AVFAudio_wrapListenerBlock_ukcdfq(_ListenerTrampoline5 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block(objc_retain(arg0));
  };
}

typedef void  (^_ListenerTrampoline6)(id arg0, id arg1);
_ListenerTrampoline6 _AVFAudio_wrapListenerBlock_1tjlcwl(_ListenerTrampoline6 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block(objc_retain(arg0), objc_retain(arg1));
  };
}

typedef void  (^_ListenerTrampoline7)(void * arg0);
_ListenerTrampoline7 _AVFAudio_wrapListenerBlock_hepzs(_ListenerTrampoline7 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_ListenerTrampoline8)(BOOL arg0);
_ListenerTrampoline8 _AVFAudio_wrapListenerBlock_117qins(_ListenerTrampoline8 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_ListenerTrampoline9)(id arg0, NSMatchingFlags arg1, BOOL * arg2);
_ListenerTrampoline9 _AVFAudio_wrapListenerBlock_9w6y6n(_ListenerTrampoline9 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, NSMatchingFlags arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block(objc_retain(arg0), arg1, arg2);
  };
}

typedef void  (^_ListenerTrampoline10)(id arg0, id arg1, id arg2);
_ListenerTrampoline10 _AVFAudio_wrapListenerBlock_tenbla(_ListenerTrampoline10 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(objc_retain(arg0), objc_retain(arg1), objc_retain(arg2));
  };
}

typedef void  (^_ListenerTrampoline11)(id arg0, BOOL arg1, id arg2);
_ListenerTrampoline11 _AVFAudio_wrapListenerBlock_hfhq9m(_ListenerTrampoline11 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, id arg2) {
    objc_retainBlock(block);
    block(objc_retain(arg0), arg1, objc_retain(arg2));
  };
}

typedef void  (^_ListenerTrampoline12)(BOOL arg0, id arg1);
_ListenerTrampoline12 _AVFAudio_wrapListenerBlock_1ej8563(_ListenerTrampoline12 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, objc_retain(arg1));
  };
}
