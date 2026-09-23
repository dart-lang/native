# FFIgen Autorelease Pool Benchmark

Measures the performance impact and overhead of wrapping Objective-C method invocations in autorelease pools (`autoReleasePool`).

## Overview

FFIgen wraps Objective-C method calls in `objc.autoReleasePool(() { ... })` (`objc_autoreleasePoolPush` / `objc_autoreleasePoolPop`). This cleans up autoreleased temporary objects created during the method call, but introduces additional overhead per invocation.

This benchmark measures:
1. Baseline without autorelease pools (`_objc_msgSend` direct dispatch).
2. Wrapped in `objc.autoReleasePool`.
3. Pure `objc.autoReleasePool` baseline to isolate closure and pool push/pop costs.
4. Non-trivial method `concat(str)` taking an `NSString *` parameter, performing string concatenation, and returning a new autoreleased `NSString *` to measure real-world ObjC work, return object conversion (`NSString.fromPointer`), and inner vs outer autorelease pool behavior.

## Running the Benchmark

1. Ensure native assets are built:
   ```shell
   dart test test/native_objc_test/method_test.dart
   ```

2. Generate or update benchmark bindings (optional, bindings are pre-generated):
   ```shell
   dart run benchmark/generate_bindings.dart
   ```

3. Run the benchmark:
   ```shell
   dart run benchmark/autorelease_pool_benchmark.dart
   ```
