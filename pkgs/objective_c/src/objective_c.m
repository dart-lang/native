// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSThread.h>
#import <dispatch/dispatch.h>

int _noMainThread = 0;
int _dispatching = 0;
int _mainThread = 0;

void runOnMainThread(void (*fn)(void*), void* arg) {
#ifdef NO_MAIN_THREAD_DISPATCH
  ++_noMainThread;
  fn(arg);
#else
  if ([NSThread isMainThread]) {
    ++_mainThread;
    fn(arg);
  } else {
    dispatch_queue_main_t q = dispatch_get_main_queue();
    dispatch_async(q, ^{
      ++_dispatching;
      fn(arg);
    });
  }
#endif
}

int getNoMainThread() { return _noMainThread; }
int getDispatch() { return _dispatching; }
int getMainThread() { return _mainThread; }
