#include <stdint.h>

#import <AVFAudio/AVAudioPlayer.h>
typedef void  (^ListenerBlock)(NSDictionary* , struct _NSRange , BOOL * );
ListenerBlock wrapListenerBlock_ObjCBlock_ffiVoid_NSDictionary_NSRange_bool(ListenerBlock block) {
  ListenerBlock wrapper = [^void(NSDictionary* arg0, struct _NSRange arg1, BOOL * arg2) {
    block([arg0 retain], arg1, arg2);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock1)(id , struct _NSRange , BOOL * );
ListenerBlock1 wrapListenerBlock_ObjCBlock_ffiVoid_objcObjCObject_NSRange_bool(ListenerBlock1 block) {
  ListenerBlock1 wrapper = [^void(id arg0, struct _NSRange arg1, BOOL * arg2) {
    block([arg0 retain], arg1, arg2);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock2)(NSDate* , BOOL , BOOL * );
ListenerBlock2 wrapListenerBlock_ObjCBlock_ffiVoid_NSDate_bool_bool(ListenerBlock2 block) {
  ListenerBlock2 wrapper = [^void(NSDate* arg0, BOOL arg1, BOOL * arg2) {
    block([arg0 retain], arg1, arg2);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock3)(NSTimer* );
ListenerBlock3 wrapListenerBlock_ObjCBlock_ffiVoid_NSTimer(ListenerBlock3 block) {
  ListenerBlock3 wrapper = [^void(NSTimer* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock4)(NSFileHandle* );
ListenerBlock4 wrapListenerBlock_ObjCBlock_ffiVoid_NSFileHandle(ListenerBlock4 block) {
  ListenerBlock4 wrapper = [^void(NSFileHandle* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock5)(NSError* );
ListenerBlock5 wrapListenerBlock_ObjCBlock_ffiVoid_NSError(ListenerBlock5 block) {
  ListenerBlock5 wrapper = [^void(NSError* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock6)(NSDictionary* , NSError* );
ListenerBlock6 wrapListenerBlock_ObjCBlock_ffiVoid_NSDictionary_NSError(ListenerBlock6 block) {
  ListenerBlock6 wrapper = [^void(NSDictionary* arg0, NSError* arg1) {
    block([arg0 retain], [arg1 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock7)(NSArray* );
ListenerBlock7 wrapListenerBlock_ObjCBlock_ffiVoid_NSArray(ListenerBlock7 block) {
  ListenerBlock7 wrapper = [^void(NSArray* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock8)(NSTextCheckingResult* , NSMatchingFlags , BOOL * );
ListenerBlock8 wrapListenerBlock_ObjCBlock_ffiVoid_NSTextCheckingResult_NSMatchingFlags_bool(ListenerBlock8 block) {
  ListenerBlock8 wrapper = [^void(NSTextCheckingResult* arg0, NSMatchingFlags arg1, BOOL * arg2) {
    block([arg0 retain], arg1, arg2);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock9)(NSCachedURLResponse* );
ListenerBlock9 wrapListenerBlock_ObjCBlock_ffiVoid_NSCachedURLResponse(ListenerBlock9 block) {
  ListenerBlock9 wrapper = [^void(NSCachedURLResponse* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock10)(NSURLResponse* , NSData* , NSError* );
ListenerBlock10 wrapListenerBlock_ObjCBlock_ffiVoid_NSURLResponse_NSData_NSError(ListenerBlock10 block) {
  ListenerBlock10 wrapper = [^void(NSURLResponse* arg0, NSData* arg1, NSError* arg2) {
    block([arg0 retain], [arg1 retain], [arg2 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock11)(NSDictionary* );
ListenerBlock11 wrapListenerBlock_ObjCBlock_ffiVoid_NSDictionary(ListenerBlock11 block) {
  ListenerBlock11 wrapper = [^void(NSDictionary* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock12)(NSURLCredential* );
ListenerBlock12 wrapListenerBlock_ObjCBlock_ffiVoid_NSURLCredential(ListenerBlock12 block) {
  ListenerBlock12 wrapper = [^void(NSURLCredential* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock13)(NSArray* , NSArray* , NSArray* );
ListenerBlock13 wrapListenerBlock_ObjCBlock_ffiVoid_NSArray_NSArray_NSArray(ListenerBlock13 block) {
  ListenerBlock13 wrapper = [^void(NSArray* arg0, NSArray* arg1, NSArray* arg2) {
    block([arg0 retain], [arg1 retain], [arg2 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock14)(NSArray* );
ListenerBlock14 wrapListenerBlock_ObjCBlock_ffiVoid_NSArray1(ListenerBlock14 block) {
  ListenerBlock14 wrapper = [^void(NSArray* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock15)(NSData* );
ListenerBlock15 wrapListenerBlock_ObjCBlock_ffiVoid_NSData(ListenerBlock15 block) {
  ListenerBlock15 wrapper = [^void(NSData* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock16)(NSData* , BOOL , NSError* );
ListenerBlock16 wrapListenerBlock_ObjCBlock_ffiVoid_NSData_bool_NSError(ListenerBlock16 block) {
  ListenerBlock16 wrapper = [^void(NSData* arg0, BOOL arg1, NSError* arg2) {
    block([arg0 retain], arg1, [arg2 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock17)(NSURLSessionWebSocketMessage* , NSError* );
ListenerBlock17 wrapListenerBlock_ObjCBlock_ffiVoid_NSURLSessionWebSocketMessage_NSError(ListenerBlock17 block) {
  ListenerBlock17 wrapper = [^void(NSURLSessionWebSocketMessage* arg0, NSError* arg1) {
    block([arg0 retain], [arg1 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock18)(NSData* , NSURLResponse* , NSError* );
ListenerBlock18 wrapListenerBlock_ObjCBlock_ffiVoid_NSData_NSURLResponse_NSError(ListenerBlock18 block) {
  ListenerBlock18 wrapper = [^void(NSData* arg0, NSURLResponse* arg1, NSError* arg2) {
    block([arg0 retain], [arg1 retain], [arg2 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock19)(NSURL* , NSURLResponse* , NSError* );
ListenerBlock19 wrapListenerBlock_ObjCBlock_ffiVoid_NSURL_NSURLResponse_NSError(ListenerBlock19 block) {
  ListenerBlock19 wrapper = [^void(NSURL* arg0, NSURLResponse* arg1, NSError* arg2) {
    block([arg0 retain], [arg1 retain], [arg2 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock20)(NSTask* );
ListenerBlock20 wrapListenerBlock_ObjCBlock_ffiVoid_NSTask(ListenerBlock20 block) {
  ListenerBlock20 wrapper = [^void(NSTask* arg0) {
    block([arg0 retain]);
  } copy];
  [block release];
  return wrapper;
}

typedef void  (^ListenerBlock21)(BOOL , NSError* );
ListenerBlock21 wrapListenerBlock_ObjCBlock_ffiVoid_bool_NSError(ListenerBlock21 block) {
  ListenerBlock21 wrapper = [^void(BOOL arg0, NSError* arg1) {
    block(arg0, [arg1 retain]);
  } copy];
  [block release];
  return wrapper;
}
