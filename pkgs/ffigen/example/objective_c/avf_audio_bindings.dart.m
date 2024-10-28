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

typedef void  (^_ListenerTrampoline1)(unsigned long arg0, BOOL * arg1);
_ListenerTrampoline1 _AVFAudio_wrapListenerBlock_l9klhe(_ListenerTrampoline1 block) NS_RETURNS_RETAINED {
  return ^void(unsigned long arg0, BOOL * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_ListenerTrampoline2)(id arg0);
_ListenerTrampoline2 _AVFAudio_wrapListenerBlock_ukcdfq(_ListenerTrampoline2 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block(objc_retain(arg0));
  };
}

typedef void  (^_ListenerTrampoline3)(id arg0, id arg1);
_ListenerTrampoline3 _AVFAudio_wrapListenerBlock_1tjlcwl(_ListenerTrampoline3 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block(objc_retain(arg0), objc_retain(arg1));
  };
}

typedef void  (^_ListenerTrampoline4)(void * arg0, id arg1);
_ListenerTrampoline4 _AVFAudio_wrapListenerBlock_sjfpmz(_ListenerTrampoline4 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, objc_retain(arg1));
  };
}
