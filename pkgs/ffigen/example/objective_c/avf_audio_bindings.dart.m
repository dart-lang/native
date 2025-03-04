#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <AVFAudio/AVAudioPlayer.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

id objc_retainBlock(id);

Protocol* _AVFAudio_AVAudioPlayerDelegate(void) { return @protocol(AVAudioPlayerDelegate); }

typedef id  (^ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _AVFAudio_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}
