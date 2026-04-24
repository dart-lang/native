// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// GC injection infrastructure for regression-testing issue #3209.
//
// Swizzles DOBJCDartProtocolBuilder's implementMethod:withBlock:... to force
// a Dart GC immediately before ObjC retains the block pointer. This makes the
// use-after-free deterministically observable via the block's retain count:
//
//   WITHOUT fix (ObjCBlockBase NOT Finalizable):
//     The Dart compiler marks `block` dead after extracting the raw pointer.
//     gc-now collects the Dart wrapper → objc_release fires → retain count = 0.
//     wasBlockFreedBeforeRetain() returns true  → test FAILS.
//
//   WITH fix (ObjCBlockBase implements Finalizable):
//     reachabilityFence keeps `block` alive through the native call.
//     gc-now finds `block` reachable → retain count stays 1.
//     wasBlockFreedBeforeRetain() returns false → test PASSES.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <stdbool.h>
#include <stdint.h>

// Dart_ExecuteInternalCommand signature (internal VM API, found via dlsym).
typedef void* (*DartGCNow_t)(const char*, void*);
static DartGCNow_t g_dart_gc_now = NULL;

static IMP g_original_imp = NULL;
static bool g_swizzle_active = false;
// Thread-safety note: g_block_freed_before_retain is written only from
// gc_inject_imp and read only from wasBlockFreedBeforeRetain(). Both are
// called from the same Dart thread (the Dart thread enters native mode for
// the FFI call, gc_inject_imp runs inline, then control returns to Dart).
// No cross-thread access occurs in the test design, so a plain bool is safe.
static bool g_block_freed_before_retain = false;

// Minimal block struct to read the retain count from the flags field.
// The retain count occupies the lower 16 bits of flags, shifted left by 1
// (bit 0 is reserved). Matches the ABI used by getBlockRetainCount in util.c.
typedef struct {
  void* isa;
  int flags;
} BlockHeader;

// The swizzled replacement for
// -[DOBJCDartProtocolBuilder implementMethod:withBlock:withTrampoline:withSignature:].
// Injects a full Dart GC before calling the original, then checks the block's
// retain count to detect premature release.
static void gc_inject_imp(
    id self, SEL _cmd, SEL sel, void* block,
    void* trampoline, const char* signature) {
  if (g_swizzle_active && g_dart_gc_now != NULL) {
    // Force a full Dart GC while the Dart thread is at an FFI safepoint.
    // At this point the raw block pointer has been extracted from the Dart
    // wrapper but ObjC has not yet retained it. Without Finalizable, the
    // Dart wrapper is dead from the optimizer's perspective and can be
    // collected here.
    g_dart_gc_now("gc-now", NULL);

    // Retain count = (flags & 0xFFFF) >> 1.
    // A count of 0 means the block was released by the GC finalizer.
    int count = (((BlockHeader*)block)->flags & 0xFFFF) >> 1;
    if (count == 0) {
      g_block_freed_before_retain = true;
    }
  }
  // Always call the original implementation so the protocol builder remains
  // in a consistent state even when the bug is triggered.
  ((void (*)(id, SEL, SEL, void*, void*, const char*))g_original_imp)(
      self, _cmd, sel, block, trampoline, signature);
}

// Look up Dart_ExecuteInternalCommand at runtime so we can call gc-now from
// native code. Must be called once before installing the swizzle.
void initGCInject(void) {
  g_dart_gc_now =
      (DartGCNow_t)dlsym(RTLD_DEFAULT, "Dart_ExecuteInternalCommand");
}

// Returns true if Dart_ExecuteInternalCommand was found via dlsym.
bool gcNowAvailableFromNative(void) {
  return g_dart_gc_now != NULL;
}

// Calls Dart_ExecuteInternalCommand("gc-now", NULL) directly from native code
// (i.e. from inside an FFI call from Dart). Used to verify whether GC can be
// triggered from native mode on the Dart thread.
void callGCNowFromNative(void) {
  if (g_dart_gc_now != NULL) {
    g_dart_gc_now("gc-now", NULL);
  }
}

// Forces a Dart GC at an FFI safepoint, then reads and returns the block's
// retain count from its flags field.
//
// This is the key primitive for the deterministic Finalizable test:
//   - Called via a NON-LEAF FFI call, so the Dart thread enters native mode
//     and the JIT's precise stack map is snapshotted at the call site.
//   - If the caller's `block` local is eliminated from the stack map (because
//     ObjCBlockBase does NOT implement Finalizable and the JIT marks `block`
//     dead after its last use), GC will collect the Dart wrapper, fire the
//     Dart_FinalizableHandle, call objc_release, and drop the count to 0.
//   - If ObjCBlockBase implements Finalizable, reachabilityFence(block) is
//     inserted at the end of the caller's scope, keeping `block` in the stack
//     map → count stays >= 1.
//
// IMPORTANT: This function must be called from a non-leaf @Native binding
// (no isLeaf:true) so that the Dart runtime establishes a proper native-mode
// safepoint with the precise JIT stack map before entering this function.
int gcAndGetRetainCount(void* block) {
  if (g_dart_gc_now != NULL) {
    g_dart_gc_now("gc-now", NULL);
  }
  return (((BlockHeader*)block)->flags & 0xFFFF) >> 1;
}

// Install the swizzle. Resets the freed-before-retain flag.
// If the class or method is not found (e.g. library not loaded), the swizzle
// is not installed and g_original_imp stays NULL — gc_inject_imp will never
// be called. Tests that depend on the swizzle should check gcNowAvailableFromNative()
// and wasBlockFreedBeforeRetain() to detect a no-op install.
void installGCInjectSwizzle(void) {
  g_block_freed_before_retain = false;
  Class cls = NSClassFromString(@"DOBJCDartProtocolBuilder");
  if (cls == nil) {
    fprintf(stderr, "gc_inject: DOBJCDartProtocolBuilder class not found — swizzle not installed\n");
    return;
  }
  SEL sel =
      @selector(implementMethod:withBlock:withTrampoline:withSignature:);
  Method m = class_getInstanceMethod(cls, sel);
  if (m == NULL) {
    fprintf(stderr, "gc_inject: implementMethod:withBlock:... not found on DOBJCDartProtocolBuilder — swizzle not installed\n");
    return;
  }
  g_original_imp = method_setImplementation(m, (IMP)gc_inject_imp);
}

// Remove the swizzle and restore the original implementation.
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

// Enable or disable GC injection. When disabled the swizzle is still installed
// but acts as a no-op passthrough, so other tests are unaffected.
void setGCInjectActive(bool active) {
  g_swizzle_active = active;
}

// Returns true if any invocation of the swizzle observed the block's retain
// count drop to 0 before ObjC retained it.
bool wasBlockFreedBeforeRetain(void) {
  return g_block_freed_before_retain;
}
