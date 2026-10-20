// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "input_stream_adapter.h"

#import <Foundation/Foundation.h>
#include <os/log.h>

// How often a stream that is waiting for data asks the Dart side for it again.
// Posting fails once the isolate that owns the port has exited, and the
// isolate can exit without notifying the stream, so re-posting is how a
// waiting stream notices that.
static const NSTimeInterval kRetryInterval = 0.1;

// The default amount of data to request from the Dart stream.
static const NSUInteger kScheduledRequestSize = 4096;

/// A run loop, and mode, that a stream is scheduled in.
@interface DOBJCScheduledRunLoop : NSObject
@property(nonatomic, readonly) CFRunLoopRef runLoop;
@property(nonatomic, readonly, copy) NSString *mode;
- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop mode:(NSString *)mode;
@end

@implementation DOBJCScheduledRunLoop
- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop mode:(NSString *)mode {
  self = [super init];
  if (self != nil) {
    _runLoop = (CFRunLoopRef)CFRetain(runLoop);
    _mode = [mode copy];
  }
  return self;
}

- (void)dealloc {
  CFRelease(_runLoop);
}
@end

@interface DOBJCDartInputStreamAdapter ()
/// Delivers `NSStreamEvent` events to the delegate based on the current state
/// of the stream.
///
/// Invoked on the run loops that the stream is scheduled in after
/// `signalScheduledRunLoops` signals `_runLoopSource`.
///
/// Delivers `NSStreamEventOpenCompleted` (once after `open`), followed by at
/// most one of:
/// - `NSStreamEventErrorOccurred` (once, if `_error` is set),
/// - `NSStreamEventHasBytesAvailable` (whenever `_data` is not empty), or
/// - `NSStreamEventEndEncountered` (once, when `_done` is `YES` and `_data` is
///   empty).
- (void)deliverEvents;

/// Periodically called by `_retryTimer` while the stream is scheduled in a run
/// loop.
///
/// If the stream is still active and `_data` is empty, sends a request to Dart
/// for more data:
/// - If `_sendPort` has been closed (for example, because the Dart isolate
///   exited without closing the stream), `requestData:` sets `_error` and
///   signals the scheduled run loops. This prevents a deadlock because a
///   run-loop reader waits for a stream event before calling `read:maxLength:`
///   and would otherwise wait forever.
/// - If `_sendPort` is still active, Dart will eventually respond by calling
///   `addData:`, `setError:`, or `setDone`. Any of these causes
///   `hasBytesAvailable` to return `YES` and signals the scheduled run loops so
///   `deliverEvents` delivers the appropriate event.
///
/// Does not request data when `_data` is non-empty because every request
/// resumes the Dart `StreamSubscription` (which would bypass Dart's read-ahead
/// limit), and `read:maxLength:` requests more data itself once `_data` is
/// drained.
///
/// Stops `_retryTimer` once the stream is closed, done, has an error, or is no
/// longer scheduled in any run loop.
- (void)checkDartSide;
@end

// The perform callback of the run loop source that delivers stream events.
static void DOBJCPerformRunLoopSource(void *info) {
  // The source holds the stream weakly, so that scheduling a stream doesn't
  // keep it alive. Loading the weak reference adds the stream to the current
  // autorelease pool, so use a short-lived pool.
  @autoreleasepool {
    [((__bridge DOBJCDartInputStreamAdapterWeakHolder *)info).adapter
        deliverEvents];
  }
}

@implementation DOBJCDartInputStreamAdapter {
  Dart_Port _sendPort;
  NSCondition *_dataCondition;
  NSMutableData *_data;
  NSStreamStatus _status;
  BOOL _done;
  NSError *_error;
  id<NSStreamDelegate> __weak _delegate;

  // Run loop scheduling. A reader that schedules the stream in a run loop
  // only calls `read:maxLength:` after `hasBytesAvailable` returns YES or the
  // stream sends it an event, so it never waits in `read:maxLength:`.
  NSMutableArray<DOBJCScheduledRunLoop *> *_scheduledRunLoops;
  CFRunLoopSourceRef _runLoopSource;
  BOOL _openCompletedPending;
  BOOL _endEncounteredSent;
  BOOL _errorOccurredSent;
  dispatch_source_t _retryTimer;
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
    stream->_scheduledRunLoops = [[NSMutableArray alloc] init];
  }
  return stream;
}

- (void)dealloc {
  [self unscheduleAll];
  if (_status != NSStreamStatusClosed) {
    Dart_PostInteger_DL(_sendPort, -1);
  }
}

- (NSUInteger)addData:(NSData *)data {
  [_dataCondition lock];
  [_data appendData:data];
  NSUInteger length = [_data length];
  [_dataCondition broadcast];
  [self signalScheduledRunLoops];
  [_dataCondition unlock];
  return length;
}

- (void)setDone {
  [_dataCondition lock];
  _done = YES;
  [self stopRetryTimer];
  [_dataCondition broadcast];
  [self signalScheduledRunLoops];
  [_dataCondition unlock];
}

- (void)setError:(NSError *)error {
  [_dataCondition lock];
  _error = error;
  [self stopRetryTimer];
  [_dataCondition broadcast];
  [self signalScheduledRunLoops];
  [_dataCondition unlock];
}

#pragma mark - Private, called with _dataCondition locked

// Asks the Dart side for more data. If the isolate that owns the port has
// exited, sets `_error` and returns NO.
- (BOOL)requestData:(NSUInteger)len {
  if (Dart_PostInteger_DL(_sendPort, len)) {
    return YES;
  }
  // The Dart port is closed, so no data can ever arrive.
  _error = [NSError
      errorWithDomain:@"DartInputStreamAdapter"
                 code:0
             userInfo:@{
               NSLocalizedDescriptionKey :
                   @"The Dart side of the stream is no longer available."
             }];
  [self stopRetryTimer];
  [_dataCondition broadcast];
  [self signalScheduledRunLoops];
  return NO;
}

// Asks the run loops that the stream is scheduled in to call `deliverEvents`.
- (void)signalScheduledRunLoops {
  if (_runLoopSource == NULL) {
    return;
  }
  CFRunLoopSourceSignal(_runLoopSource);
  for (DOBJCScheduledRunLoop *scheduled in _scheduledRunLoops) {
    CFRunLoopWakeUp(scheduled.runLoop);
  }
}

// Called when the stream becomes both open and scheduled. From then on, the
// reader waits for `NSStreamEventHasBytesAvailable` before reading, so the
// stream asks the Dart side for data itself instead of in `read:maxLength:`.
- (void)startScheduledReading {
  if (_status != NSStreamStatusOpen || _scheduledRunLoops.count == 0) {
    return;
  }
  // Delivers `NSStreamEventOpenCompleted` and any data that is already here.
  [self signalScheduledRunLoops];
  if (_done || _error != nil) {
    return;
  }
  // The stream may have been read without being scheduled, which doesn't ask
  // for more data when it empties the buffer, so ask now if there is no data.
  if ([_data length] > 0 || [self requestData:kScheduledRequestSize]) {
    [self startRetryTimer];
  }
}

// While a scheduled stream waits for data, nothing waits in
// `read:maxLength:` to notice that the Dart side is gone, so a timer does it.
- (void)startRetryTimer {
  if (_retryTimer != nil) {
    return;
  }
  DOBJCDartInputStreamAdapterWeakHolder *holder =
      [DOBJCDartInputStreamAdapterWeakHolder holderWithInputStreamAdapter:self];
  const uint64_t interval = (uint64_t)(kRetryInterval * NSEC_PER_SEC);
  _retryTimer = dispatch_source_create(
      DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
      dispatch_get_global_queue(QOS_CLASS_UTILITY, 0));
  dispatch_source_set_timer(_retryTimer,
                            dispatch_time(DISPATCH_TIME_NOW, interval),
                            interval, interval / 10);
  dispatch_source_set_event_handler(_retryTimer, ^{
    @autoreleasepool {
      [holder.adapter checkDartSide];
    }
  });
  dispatch_resume(_retryTimer);
}

- (void)stopRetryTimer {
  if (_retryTimer != nil) {
    dispatch_source_cancel(_retryTimer);
    _retryTimer = nil;
  }
}

- (void)unscheduleAll {
  [self stopRetryTimer];
  if (_runLoopSource != NULL) {
    // Removes the source from every run loop that it was added to.
    CFRunLoopSourceInvalidate(_runLoopSource);
    CFRelease(_runLoopSource);
    _runLoopSource = NULL;
  }
  [_scheduledRunLoops removeAllObjects];
}

#pragma mark - Private, called without _dataCondition locked

- (void)checkDartSide {
  [_dataCondition lock];
  if (_status != NSStreamStatusOpen || _done || _error != nil ||
      _scheduledRunLoops.count == 0) {
    [self stopRetryTimer];
  } else if ([_data length] == 0) {
    [self requestData:kScheduledRequestSize];
  }
  [_dataCondition unlock];
}

- (void)deliverEvents {
  [_dataCondition lock];
  if (_status == NSStreamStatusNotOpen || _status == NSStreamStatusClosed) {
    [_dataCondition unlock];
    return;
  }
  const BOOL openCompleted = _openCompletedPending;
  _openCompletedPending = NO;
  NSStreamEvent event = NSStreamEventNone;
  if (_error != nil) {
    if (!_errorOccurredSent) {
      _errorOccurredSent = YES;
      event = NSStreamEventErrorOccurred;
    }
  } else if ([_data length] > 0) {
    event = NSStreamEventHasBytesAvailable;
  } else if (_done && !_endEncounteredSent) {
    _endEncounteredSent = YES;
    event = NSStreamEventEndEncountered;
  }
  id<NSStreamDelegate> delegate = _delegate;
  [_dataCondition unlock];

  // The delegate will probably call `hasBytesAvailable` and
  // `read:maxLength:`, so call it without holding the lock.
  if (delegate == self ||
      ![delegate respondsToSelector:@selector(stream:handleEvent:)]) {
    return;
  }
  if (openCompleted) {
    [delegate stream:self handleEvent:NSStreamEventOpenCompleted];
  }
  if (event != NSStreamEventNone) {
    [delegate stream:self handleEvent:event];
  }
}

#pragma mark - NSStream

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
  if (runLoop == nil || mode == nil) {
    return;
  }
  [_dataCondition lock];
  if (_status == NSStreamStatusClosed) {
    [_dataCondition unlock];
    return;
  }
  if (_runLoopSource == NULL) {
    DOBJCDartInputStreamAdapterWeakHolder *holder =
        [DOBJCDartInputStreamAdapterWeakHolder
            holderWithInputStreamAdapter:self];
    CFRunLoopSourceContext context = {
        .version = 0,
        .info = (__bridge void *)holder,
        .retain = CFRetain,
        .release = CFRelease,
        .perform = DOBJCPerformRunLoopSource,
    };
    _runLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
  }
  // This may be called on a thread other than the run loop's, so use the CF
  // run loop, which can be used from any thread.
  CFRunLoopRef cfRunLoop = [runLoop getCFRunLoop];
  [_scheduledRunLoops
      addObject:[[DOBJCScheduledRunLoop alloc] initWithRunLoop:cfRunLoop
                                                          mode:mode]];
  CFRunLoopAddSource(cfRunLoop, _runLoopSource, (__bridge CFStringRef)mode);
  [self startScheduledReading];
  [_dataCondition unlock];
}

- (void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
  if (runLoop == nil || mode == nil) {
    return;
  }
  [_dataCondition lock];
  CFRunLoopRef cfRunLoop = [runLoop getCFRunLoop];
  BOOL (^matches)(DOBJCScheduledRunLoop *, NSUInteger, BOOL *) =
      ^BOOL(DOBJCScheduledRunLoop *scheduled, NSUInteger index, BOOL *stop) {
        return scheduled.runLoop == cfRunLoop &&
               [scheduled.mode isEqualToString:mode];
      };
  NSUInteger index = [_scheduledRunLoops indexOfObjectPassingTest:matches];
  if (index != NSNotFound) {
    [_scheduledRunLoops removeObjectAtIndex:index];
    // The source is only in the run loop once, however many times the stream
    // was scheduled in it.
    if ([_scheduledRunLoops indexOfObjectPassingTest:matches] == NSNotFound) {
      CFRunLoopRemoveSource(cfRunLoop, _runLoopSource,
                            (__bridge CFStringRef)mode);
    }
    if (_scheduledRunLoops.count == 0) {
      [self stopRetryTimer];
    }
  }
  [_dataCondition unlock];
}

- (void)open {
  [_dataCondition lock];
  _status = NSStreamStatusOpen;
  _openCompletedPending = YES;
  [self startScheduledReading];
  [_dataCondition unlock];
}

- (void)close {
  [_dataCondition lock];
  if (_status == NSStreamStatusClosed) {
    // The close message has already been sent, there is no reason to send
    // another message to a port that was already shutdown.
    [_dataCondition unlock];
    return;
  }
  _status = NSStreamStatusClosed;
  // A closed stream is no longer scheduled in any run loop. Readers can close
  // the stream without calling `removeFromRunLoop:forMode:`.
  [self unscheduleAll];
  if (!_done && _error == nil) {
    // A failed post means the Dart side has already closed its port — there
    // is nobody left to notify, which is fine for a close.
    if (!Dart_PostInteger_DL(_sendPort, -1)) {
      os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEBUG,
                       "DartInputStreamAdapter: close after the Dart port was closed");
    }
  }
  // `read:maxLength:` could be waiting for data, wake it up.
  [_dataCondition broadcast];
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
    // Behave like Foundation's own streams: a read on a closed stream fails
    // with -1 but leaves streamStatus at NSStreamStatusClosed and streamError
    // nil, because being closed is the stream's normal final state, not an
    // error.
    [_dataCondition unlock];
    return -1;
  }

  while (([_data length] == 0) && !_done && _error == nil &&
         _status != NSStreamStatusClosed) {
    // Posting fails once the isolate that owns the port has exited. The
    // isolate can exit without notifying this stream, so re-posting after
    // each timed wait below is how a waiting read notices that.
    if (![self requestData:len]) {
      // No data can ever arrive: fail the read instead of waiting forever (or
      // aborting the process).
      break;
    }

    [_dataCondition
        waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:kRetryInterval]];
  }

  if (_status == NSStreamStatusClosed) {
    // `close` was called while this read was waiting.
    [_dataCondition unlock];
    return -1;
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

    if (_scheduledRunLoops.count > 0) {
      if ([_data length] > 0 || _done) {
        // There is more to read, or the end to report.
        [self signalScheduledRunLoops];
      } else {
        // The reader won't read again until it gets
        // `NSStreamEventHasBytesAvailable`, so ask the Dart side for more data
        // now.
        [self requestData:len];
      }
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
  [_dataCondition lock];
  BOOL hasBytesAvailable;
  if (_scheduledRunLoops.count == 0) {
    // NSInputStream allows returning `YES` when "a read must be attempted in
    // order to determine the availability of bytes". When the stream is not
    // scheduled in a run loop, the reader must call `read:maxLength:` to
    // request and wait for data.
    hasBytesAvailable = _status == NSStreamStatusOpen;
  } else {
    // When the stream is scheduled in a run loop, `hasBytesAvailable`
    // indicates whether `read:maxLength:` can return without blocking:
    // 1. buffered data is available (`read:maxLength:` returns > 0),
    // 2. the stream is done (`read:maxLength:` returns 0), or
    // 3. an error occurred (`read:maxLength:` returns -1).
    hasBytesAvailable = _status == NSStreamStatusOpen &&
                        ([_data length] > 0 || _done || _error != nil);
  }
  [_dataCondition unlock];
  return hasBytesAvailable;
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
