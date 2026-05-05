// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// GC injection helpers for regression-testing issue #3209.
//
// Swizzles DOBJCDartProtocolBuilder's implementMethod:withBlock:... to inject
// a Dart GC at the FFI safepoint between Dart extracting the raw block pointer
// and Objective-C retaining it — the exact window where premature GC can
// release the block before the handover completes.
//
// Run AOT to reproduce under production-like conditions — GC liveness issues
// like this are unreliable in JIT (from pkgs/objective_c/).
// Native assets must be enabled; stable from Dart 3.10.0:
//   dart compile exe test/gc_safepoint_test.dart -o /tmp/gc_test
//   DYLD_INSERT_LIBRARIES=.dart_tool/lib/objective_c.dylib /tmp/gc_test

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <stdbool.h>
#include <stdint.h>

// From util.c — reads the block ABI flags field for the retain count.
extern uint64_t getBlockRetainCount(void*);

typedef void* (*DartGCNow_t)(const char*, void*);
static DartGCNow_t g_dart_gc_now = NULL;

static IMP g_original_imp = NULL;
static bool g_swizzle_active = false;
// Written and read from the same Dart thread (native-mode FFI call), so a
// plain bool is safe.
static bool g_block_freed_before_retain = false;

// Replacement for -[DOBJCDartProtocolBuilder implementMethod:withBlock:...].
// Forces GC before calling the original, then checks the retain count.
static void gc_inject_imp(
    id self, SEL _cmd, SEL sel, void* block,
    void* trampoline, const char* signature) {
  if (g_swizzle_active && g_dart_gc_now != NULL) {
    g_dart_gc_now("gc-now", NULL);
    // Use the same util as the Dart side (util.c:getBlockRetainCount).
    int count = (int)getBlockRetainCount(block);
    if (count == 0) {
      g_block_freed_before_retain = true;
    }
  }
  ((void (*)(id, SEL, SEL, void*, void*, const char*))g_original_imp)(
      self, _cmd, sel, block, trampoline, signature);
}

// Look up Dart_ExecuteInternalCommand via dlsym. Must be called once before
// installing the swizzle.
void initGCInject(void) {
  g_dart_gc_now =
      (DartGCNow_t)dlsym(RTLD_DEFAULT, "Dart_ExecuteInternalCommand");
}

bool gcNowAvailableFromNative(void) {
  return g_dart_gc_now != NULL;
}

// Triggers gc-now from inside a non-leaf FFI call (Dart thread is at a
// safepoint), used to verify GC can actually fire from native mode.
void callGCNowFromNative(void) {
  if (g_dart_gc_now != NULL) {
    g_dart_gc_now("gc-now", NULL);
  }
}

void installGCInjectSwizzle(void) {
  g_block_freed_before_retain = false;
  Class cls = NSClassFromString(@"DOBJCDartProtocolBuilder");
  if (cls == nil) return;
  SEL sel =
      @selector(implementMethod:withBlock:withTrampoline:withSignature:);
  Method m = class_getInstanceMethod(cls, sel);
  if (m == NULL) return;
  g_original_imp = method_setImplementation(m, (IMP)gc_inject_imp);
}

void removeGCInjectSwizzle(void) {
  if (g_original_imp == NULL) return;
  Class cls = NSClassFromString(@"DOBJCDartProtocolBuilder");
  SEL sel =
      @selector(implementMethod:withBlock:withTrampoline:withSignature:);
  Method m = class_getInstanceMethod(cls, sel);
  if (m != NULL) {
    method_setImplementation(m, g_original_imp);
  }
  g_original_imp = NULL;
}

void setGCInjectActive(bool active) {
  g_swizzle_active = active;
}

// Sticky flag: once true it stays true even after setGCInjectActive(false).
bool wasBlockFreedBeforeRetain(void) {
  return g_block_freed_before_retain;
}
