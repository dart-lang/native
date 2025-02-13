#include <stdint.h>
#import <Foundation/Foundation.h>
#import <AVFAudio/AVAudioPlayer.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

id objc_retainBlock(id);

Protocol* _AVFAudio_AVAudioPlayerDelegate(void) { return @protocol(AVAudioPlayerDelegate); }
