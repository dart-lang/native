// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "input_stream_adapter.h"

#import <Foundation/Foundation.h>
#include <os/log.h>

@implementation DOBJCDartInputStreamAdapter {
  Dart_Port _sendPort;
  NSCondition *_dataCondition;
  NSMutableData *_data;
  NSStreamStatus _status;
  BOOL _done;
  NSError *_error;
  id<NSStreamDelegate> __weak _delegate;
}

+ (instancetype)inputStreamWithPort:(Dart_Port)sendPort {
  DOBJCDartInputStreamAdapter *stream = [[DOBJCDartInputStreamAdapter alloc] init];
  if (stream != nil) {
    stream->_sendPort = sendPort;
    stream->_dataCondition = [[NSCondition alloc] init];
    stream->_data = [[NSMutableData alloc] init];
    stream->_done = NO;
    stream->_status = NSStreamStatusNotOpen;
    stream->_error = nil;
    // From https://developer.apple.com/documentation/foundation/nsstream:
    // "...by a default, a stream object must be its own delegate..."
    stream->_delegate = stream;
  }
  return stream;
}

- (void)dealloc {
  if (_status != NSStreamStatusClosed) {
    Dart_PostInteger_DL(_sendPort, -1);
  }
}

- (NSUInteger)addData:(NSData *)data {
  [_dataCondition lock];
  [_data appendData:data];
  [_dataCondition broadcast];
  [_dataCondition unlock];
  return [_data length];
}

- (void)setDone {
  [_dataCondition lock];
  _done = YES;
  [_dataCondition broadcast];
  [_dataCondition unlock];
}

- (void)setError:(NSError *)error {
  [_dataCondition lock];
  _error = error;
  [_dataCondition broadcast];
  [_dataCondition unlock];
}

#pragma mark - NSStream

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
}

- (void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
}

- (void)open {
  [_dataCondition lock];
  _status = NSStreamStatusOpen;
  [_dataCondition unlock];
}

- (void)close {
  [_dataCondition lock];
  if (_status == NSStreamStatusClosed) {
    // Already closed. NSURLSession closes the body stream it was handed when
    // the task finishes, independently of the Dart owner closing it (e.g.
    // cupertino_http closes the stream as soon as the request completes or
    // is cancelled); the second close must be a no-op, not a second message
    // to a port that the first close already told to shut down.
    [_dataCondition unlock];
    return;
  }
  _status = NSStreamStatusClosed;
  if (!_done && _error == nil) {
    // A failed post means the Dart side has already closed its port — there
    // is nobody left to notify, which is fine for a close.
    if (!Dart_PostInteger_DL(_sendPort, -1)) {
      os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEBUG,
                       "DartInputStreamAdapter: close after the Dart port was closed");
    }
  }
  [_dataCondition unlock];
}

- (id)propertyForKey:(NSStreamPropertyKey)key {
  return nil;
}

- (BOOL)setProperty:(id)property forKey:(NSStreamPropertyKey)key {
  return NO;
}

- (id<NSStreamDelegate>)delegate {
  return _delegate;
}

- (void)setDelegate:(id<NSStreamDelegate>)delegate {
  // From https://developer.apple.com/documentation/foundation/nsstream:
  // "...so a delegate message with an argument of nil should restore this
  // delegate..."
  if (delegate == nil) {
    _delegate = self;
  } else {
    _delegate = delegate;
  }
}

- (NSError *)streamError {
  return _error;
}

- (NSStreamStatus)streamStatus {
  return _status;
}

#pragma mark - NSInputStream

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
  if (_status == NSStreamStatusNotOpen) {
    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEBUG,
                     "DartInputStreamAdapter: read before open");
    return -1;
  }

  [_dataCondition lock];

  if (_status == NSStreamStatusClosed) {
    // NSURLSession can still issue a read for a body stream after the Dart
    // owner closed it (a request completed with an error or cancelled while
    // the loader thread was about to resume the body). Closing sent the -1
    // to Dart, so its port is gone: asking it for data would fail.
    [_dataCondition unlock];
    return -1;
  }

  while (([_data length] == 0) && !_done && _error == nil) {
    if (!Dart_PostInteger_DL(_sendPort, len)) {
      // The Dart port is closed, so no data can ever arrive: fail the read
      // instead of waiting forever (or aborting the process).
      _error = [NSError
          errorWithDomain:@"DartInputStreamAdapter"
                     code:0
                 userInfo:@{
                   NSLocalizedDescriptionKey :
                       @"The Dart side of the stream is no longer available."
                 }];
      break;
    }

    [_dataCondition wait];
  }

  NSInteger copySize;
  if (_error == nil) {
    copySize = MIN(len, [_data length]);
    NSRange readRange = NSMakeRange(0, copySize);
    [_data getBytes:(void *)buffer range:readRange];
    // Shift the remaining data over to the beginning of the buffer.
    // NOTE: this makes small reads expensive!
    [_data replaceBytesInRange:readRange withBytes:NULL length:0];

    if (_done && [_data length] == 0) {
      _status = NSStreamStatusAtEnd;
    }
  } else {
    _status = NSStreamStatusError;
    copySize = -1;
  }

  [_dataCondition unlock];
  return copySize;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len {
  return NO;
}

- (BOOL)hasBytesAvailable {
  return _status == NSStreamStatusOpen;
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
  id<NSStreamDelegate> delegate = _delegate;
  if (delegate != self) {
    [delegate stream:self handleEvent:streamEvent];
  }
}

@end

@implementation DOBJCDartInputStreamAdapterWeakHolder
+ (instancetype)holderWithInputStreamAdapter:(DOBJCDartInputStreamAdapter *)adapter {
  DOBJCDartInputStreamAdapterWeakHolder * holder = [[DOBJCDartInputStreamAdapterWeakHolder alloc] init]; 
  if (holder != nil) {
    holder->adapter = adapter;
  }
  return holder;
}

@synthesize adapter;

@end
