# Crash Reproduction Guide — Issue #3209

## What is the bug?

When Dart calls an FFI function (a native ObjC method), the Dart thread enters **native mode** — it is blocked waiting for the native call to return. During this window, the Dart GC may run using a precise "stack map" snapshot of which Dart objects are still reachable.

The AOT/JIT optimizer tracks **liveness** of local variables. If a local variable's last use was before the FFI call, the optimizer marks it **dead** in the stack map. A GC event during the native call will then collect that object, even though the native code is still holding a raw pointer to it (obtained just before the call).

In `ObjCProtocolMethod.implementWithBlock`, the calling code looks roughly like:

```dart
final block = ObjCBlock_....fromFunction(...);   // Dart wrapper created
final ptr = block.ref.pointer;                   // raw pointer extracted — last Dart use of `block`
implementMethod(sel, ptr, trampoline, signature); // NON-LEAF FFI call
//              ↑ if ObjCBlockBase is NOT Finalizable, `block` is dead here
//                GC fires inside this native call → block finalizer → objc_release → retain count = 0
//                ObjC then does [methods setObject:block forKey:key] → objc_retain → EXC_BAD_ACCESS
```

**The fix**: Add `implements Finalizable` to `ObjCBlockBase`. The Dart compiler then inserts `reachabilityFence(block)` at the end of the calling scope, which keeps `block` in the GC stack map across the FFI safepoint.

**Why not `ObjCObject`?** `Finalizable` objects are non-sendable across Dart isolates. `ObjCObject` instances (e.g. `NSInputStream`) are sent across isolates, so they must stay sendable. Blocks capture Dart closures and are never sent across isolates — Finalizable is safe for them.

---

## File map

| File | Purpose |
|------|---------|
| `lib/src/internal.dart` | **The fix** — `ObjCBlockBase implements Finalizable` |
| `test/gc_inject.m` | ObjC swizzle that injects GC at the exact crash window |
| `test/finalizable_test.dart` | Regression tests — type checks, GC-pressure, and the swizzle-based reproduction |
| `test/util.dart` | Dart bindings for the native test helpers |
| `hook/build.dart` | Compiles `gc_inject.m` into the test dylib |
| `test/desymbolize.py` | Script to symbolize AOT crash dumps using `atos` |

---

## How the GC injection works

`test/gc_inject.m` swizzles `-[DOBJCDartProtocolBuilder implementMethod:withBlock:withTrampoline:withSignature:]` at runtime. The replacement (`gc_inject_imp`) runs **instead** of the real method:

```
Dart ──FFI──► gc_inject_imp
                 │
                 ├─ Dart_ExecuteInternalCommand("gc-now")  ← forces GC right here
                 │   (Dart thread is blocked at a safepoint — precise stack map used)
                 │   WITHOUT Finalizable: `block` dead in map → GC collects it
                 │   WITH Finalizable:    `block` alive in map → GC skips it
                 │
                 ├─ check retain count: if 0, block was freed → record flag
                 │
                 └─ call real implementMethod
                       └─ [methods setObject:block forKey:key]
                             └─ objc_retain(block)  ← CRASH if block already freed
```

`Dart_ExecuteInternalCommand` is an internal Dart VM API discovered via `dlsym`. Calling it from inside a non-leaf FFI call is valid because the Dart thread is already at a proper native-mode safepoint.

### Why non-leaf matters

A `@Native` binding with `isLeaf: true` does **not** create a proper safepoint — the GC cannot run safely. The Dart binding for `callGCNowFromNative` and `gcAndGetRetainCount` must NOT have `isLeaf: true`:

```dart
// test/util.dart
@Native<Void Function()>(symbol: 'callGCNowFromNative')  // no isLeaf: true
external void callGCNowFromNative();
```

---

## How to reproduce the crash

### Step 1 — Remove the fix

In `lib/src/internal.dart`, change:

```dart
class ObjCBlockBase extends _ObjCRefHolder<c.ObjCBlockImpl, ObjCBlockRef>
    implements Finalizable {
```

to:

```dart
class ObjCBlockBase extends _ObjCRefHolder<c.ObjCBlockImpl, ObjCBlockRef> {
```

Also comment out the compile-time guard in `test/finalizable_test.dart` (otherwise the AOT compile fails with a type error):

```dart
// ignore: unused_element
// void _checkObjCBlockBaseIsFinalizable(ObjCBlockBase b) =>
//     _requireFinalizable(b);
```

In the committed code the fix is already applied and the guard is **enabled** — you must comment it out only when temporarily removing the fix to reproduce the crash.

### Step 2 — AOT compile

All commands in steps 2–4 must be run from `pkgs/objective_c/`.

```bash
cd pkgs/objective_c
mkdir -p /tmp/ft
dart compile exe test/finalizable_test.dart -o /tmp/ft/finalizable_test
```

(`fvm dart` works too if you use Flutter Version Manager; otherwise plain `dart` is fine.)

AOT is required. In JIT mode the optimizer is conservative and keeps local variables alive longer than necessary, so the bug rarely triggers.

### Step 3 — Run and capture the crash

Run from `pkgs/objective_c/` so the relative dylib path resolves:

```bash
DYLD_INSERT_LIBRARIES=.dart_tool/lib/objective_c.dylib \
  /tmp/ft/finalizable_test 2>&1 | tee /tmp/ft/crash.txt
```

`DYLD_INSERT_LIBRARIES` is needed because `dart compile exe` does not copy the native asset dylib alongside the executable. If you run from a different directory, prefix the dylib path with the full repo path to `pkgs/objective_c/.dart_tool/lib/objective_c.dylib`.

**Expected output:**

```
===== CRASH =====
si_signo=Segmentation fault: 11(11), si_code=SEGV_ACCERR(2)
...
  pc 0x... objc_retain+0x10
  pc 0x... -[DOBJCDartProtocolBuilder implementMethod:withBlock:...]+0x90
  pc 0x... gc_inject_imp+0xf4
  ...
  [Optimized] ObjCProtocolBuilder.implementMethod
  [Optimized] ObjCProtocolMethod.implementWithBlock
  [Optimized] main.<anonymous closure>.<anonymous closure>
```

### Step 4 — Desymbolize (optional)

The crash contains raw addresses for Dart AOT frames. The `desymbolize.py` script resolves them using `atos`:

```bash
python3 test/desymbolize.py /tmp/ft/crash.txt /tmp/ft/finalizable_test
```

The script computes the ASLR slide automatically — first from the `Dart_UnloadMachODylib` annotation (present in `dart compile exe` output), with a fallback to the `(in binary_name)` format used by macOS crash reporter. Architecture is auto-detected from the binary via `lipo`. Already-annotated frames (`objc_retain`, `[Optimized] ...`) are passed through unchanged; only `Unknown symbol` frames are sent to `atos`.

Note: `Dart_ExecuteInternalCommand` must be exported by the running Dart VM. Standard release builds of the Dart SDK include it. If the symbol is absent (stripped build), the GC injection swizzle becomes a no-op and the crash will not trigger.

---

## How to verify the fix

### Step 5 — Re-apply the fix

Restore `implements Finalizable` on `ObjCBlockBase` in `lib/src/internal.dart`.

### Step 6 — Recompile and run

From `pkgs/objective_c/`:

```bash
dart compile exe test/finalizable_test.dart -o /tmp/ft/finalizable_test_fixed
DYLD_INSERT_LIBRARIES=.dart_tool/lib/objective_c.dylib \
  /tmp/ft/finalizable_test_fixed 2>&1
```

**Expected output:**

```
+6: All tests passed!
```

All 6 tests pass, no crash.

---

## What the tests check

| Test | What it verifies |
|------|-----------------|
| `ObjCBlockBase implements Finalizable` | Runtime `is Finalizable` check — PRIMARY guard |
| `ObjCObject is NOT Finalizable` | Confirms ObjCObject stays isolate-sendable |
| `protocol object survives GC after build` | GC pressure on a protocol builder object |
| `gc-now from native code collects unreachable objects` | Diagnostic: confirms the GC injection mechanism works |
| `block survives GC injected inside implementMethod` | **Swizzle test** — 1000 iterations, detects bug in optimized code |
| `block local NOT freed at non-leaf FFI safepoint` | Direct liveness probe using WeakReference |

### Why 1000 iterations in the swizzle test?

In JIT mode, Dart functions start unoptimized and are compiled to optimized code after a threshold of calls. Below that threshold the JIT is conservative (keeps all locals alive). After enough calls the JIT applies liveness analysis and may mark `block` dead — only then does the injected GC collect it. The 1000-iteration loop forces the JIT to optimize the hot path.

For guaranteed reproduction on the very first call, run:

```bash
fvm dart --optimization-counter-threshold=0 test test/finalizable_test.dart
```

---

## Crash stack explained

```
objc_retain+0x10
  ↑ crash: raw pointer is invalid (retain count already 0)
-[DOBJCDartProtocolBuilder implementMethod:withBlock:...]+0x90
  ↑ calls [methods setObject:block forKey:key] → objc_retain
gc_inject_imp+0xf4
  ↑ our swizzle: called gc-now here, then called the real implementMethod
[Optimized] init:_objc_msgSend_...#ffiClosure
  ↑ FFI trampoline — Dart → native boundary
[Optimized] DartProtocolBuilder$Methods|implementMethod
[Optimized] ObjCProtocolBuilder.implementMethod
[Optimized] ObjCProtocolMethod.implementWithBlock
  ↑ `block` was a local here; JIT marked it dead after block.ref.pointer
[Optimized] main.<anonymous closure>.<anonymous closure>
  ↑ the test code
```

`gc_inject_imp+0xf4` is the byte offset within `gc_inject_imp` where the call to `g_original_imp` (the real `implementMethod`) happens — i.e. the moment the already-freed block pointer was passed to ObjC.
