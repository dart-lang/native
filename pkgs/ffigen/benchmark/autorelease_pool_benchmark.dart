// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:objective_c/objective_c.dart' as objc;

import 'method_with_pool_bindings.dart' as with_pool;
import 'method_without_pool_bindings.dart' as no_pool;

void _ensureDylibLoaded() {
  final candidates = [
    Uri.file('${Directory.current.path}/.dart_tool/lib/objc_test.dylib'),
    Platform.script.resolve('../.dart_tool/lib/objc_test.dylib'),
    Platform.script.resolve('../test/native_objc_test/objc_test.dylib'),
  ];
  for (final candidate in candidates) {
    final file = File.fromUri(candidate);
    if (file.existsSync()) {
      DynamicLibrary.open(file.path);
      return;
    }
  }
  try {
    DynamicLibrary.open('objc_test.dylib');
  } catch (_) {
    throw StateError(
      'Could not find objc_test.dylib. Run '
      '"dart test test/native_objc_test/method_test.dart" first to build native '
      'assets.',
    );
  }
}

class BenchmarkResult {
  final String name;
  final int iterations;
  final List<double> noPoolNsPerCall;
  final List<double> withPoolNsPerCall;

  BenchmarkResult({
    required this.name,
    required this.iterations,
    required this.noPoolNsPerCall,
    required this.withPoolNsPerCall,
  });

  double get noPoolMean =>
      noPoolNsPerCall.reduce((a, b) => a + b) / noPoolNsPerCall.length;
  double get withPoolMean =>
      withPoolNsPerCall.reduce((a, b) => a + b) / withPoolNsPerCall.length;

  double get noPoolMedian {
    final sorted = List<double>.from(noPoolNsPerCall)..sort();
    return sorted[sorted.length ~/ 2];
  }

  double get withPoolMedian {
    final sorted = List<double>.from(withPoolNsPerCall)..sort();
    return sorted[sorted.length ~/ 2];
  }

  double get noPoolStdDev {
    final mean = noPoolMean;
    final variance =
        noPoolNsPerCall.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
        noPoolNsPerCall.length;
    return sqrt(variance);
  }

  double get withPoolStdDev {
    final mean = withPoolMean;
    final variance =
        withPoolNsPerCall.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
        withPoolNsPerCall.length;
    return sqrt(variance);
  }

  double get overheadNs => withPoolMean - noPoolMean;
  double get overheadMultiplier => withPoolMean / noPoolMean;
  double get percentIncrease =>
      ((withPoolMean - noPoolMean) / noPoolMean) * 100;
}

@pragma('vm:never-inline')
int runNoPoolInstanceAdd(no_pool.MethodInterface target, int count) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    sum += target.add();
  }
  return sum;
}

@pragma('vm:never-inline')
int runWithPoolInstanceAdd(with_pool.MethodInterface target, int count) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    sum += target.add();
  }
  return sum;
}

@pragma('vm:never-inline')
int runNoPoolClassSub(int count) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    sum += no_pool.MethodInterface.sub();
  }
  return sum;
}

@pragma('vm:never-inline')
int runWithPoolClassSub(int count) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    sum += with_pool.MethodInterface.sub();
  }
  return sum;
}

@pragma('vm:never-inline')
int runNoPoolInstanceAddArg(no_pool.MethodInterface target, int count) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    sum += target.add$1(i & 0x7F);
  }
  return sum;
}

@pragma('vm:never-inline')
int runWithPoolInstanceAddArg(with_pool.MethodInterface target, int count) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    sum += target.add$1(i & 0x7F);
  }
  return sum;
}

@pragma('vm:never-inline')
int runPureDartBaseline(int count) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    sum += 5;
  }
  return sum;
}

@pragma('vm:never-inline')
int runPureAutoReleasePoolClosure(int count) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    sum += objc.autoReleasePool(() => 5);
  }
  return sum;
}

@pragma('vm:never-inline')
int runNoPoolInstanceConcat(
  no_pool.MethodInterface target,
  objc.NSString inputStr,
  int count,
) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    final res = target.concat(inputStr);
    sum += res.ref.pointer.address & 0x7F;
  }
  return sum;
}

@pragma('vm:never-inline')
int runWithPoolInstanceConcat(
  with_pool.MethodInterface target,
  objc.NSString inputStr,
  int count,
) {
  var sum = 0;
  for (var i = 0; i < count; i++) {
    final res = target.concat(inputStr);
    sum += res.ref.pointer.address & 0x7F;
  }
  return sum;
}

void main(List<String> args) {
  _ensureDylibLoaded();

  final objNoPool = no_pool.MethodInterface.alloc().init();
  final objWithPool = with_pool.MethodInterface.alloc().init();

  // Pre-allocate NSString inputs outside the benchmark timing loops so
  // Dart string -> NSString conversion is not measured.
  final preallocatedInput = objc.NSString('benchmark_input_string_12345');

  // Sanity check correctness
  assert(objNoPool.add() == 5);
  assert(objWithPool.add() == 5);
  assert(no_pool.MethodInterface.sub() == -5);
  assert(with_pool.MethodInterface.sub() == -5);
  assert(objNoPool.add$1(42) == 42);
  assert(objWithPool.add$1(42) == 42);
  assert(
    objNoPool.concat(preallocatedInput).toDartString() ==
        'benchmark_input_string_12345_benchmark_suffix',
  );
  assert(
    objWithPool.concat(preallocatedInput).toDartString() ==
        'benchmark_input_string_12345_benchmark_suffix',
  );

  const warmupIterations = 1000000;
  const benchmarkIterations = 5000000;
  const concatWarmupIterations = 50000;
  const concatBenchmarkIterations = 200000;
  const rounds = 5;

  print('===============================================================');
  print('FFIgen autoReleasePool Performance Benchmark');
  print('===============================================================');
  print('OS: ${Platform.operatingSystem} (${Platform.operatingSystemVersion})');
  print('Architecture: ${Platform.version.split(' ').last}');
  print('Dart Version: ${Platform.version.split(' ').first}');
  print('Warmup Iterations (tiny): $warmupIterations');
  print('Benchmark Iterations per trial (tiny): $benchmarkIterations');
  print('Warmup Iterations (concat): $concatWarmupIterations');
  print('Benchmark Iterations per trial (concat): $concatBenchmarkIterations');
  print('Trials per benchmark: $rounds');
  print('---------------------------------------------------------------\n');

  // Benchmark 1: Instance method -(int32_t)add (0 args, returns 5)
  print('Benchmarking 1: Instance method `add()` (no args, returns int)...');
  final addResults = _runBenchmark(
    name: 'Instance method add()',
    warmupIterations: warmupIterations,
    iterations: benchmarkIterations,
    rounds: rounds,
    runNoPool: () => runNoPoolInstanceAdd(objNoPool, benchmarkIterations),
    runWithPool: () => runWithPoolInstanceAdd(objWithPool, benchmarkIterations),
    warmupNoPool: () => runNoPoolInstanceAdd(objNoPool, warmupIterations),
    warmupWithPool: () => runWithPoolInstanceAdd(objWithPool, warmupIterations),
  );

  // Benchmark 2: Class method +(int32_t)sub (0 args, returns -5)
  print('\nBenchmarking 2: Class method `sub()` (static, returns int)...');
  final subResults = _runBenchmark(
    name: 'Class method sub()',
    warmupIterations: warmupIterations,
    iterations: benchmarkIterations,
    rounds: rounds,
    runNoPool: () => runNoPoolClassSub(benchmarkIterations),
    runWithPool: () => runWithPoolClassSub(benchmarkIterations),
    warmupNoPool: () => runNoPoolClassSub(warmupIterations),
    warmupWithPool: () => runWithPoolClassSub(warmupIterations),
  );

  // Benchmark 3: Instance method -(int32_t)add:(int32_t)x (1 arg, returns x)
  print(
    '\nBenchmarking 3: Instance method `add\\\$1(x)` (1 arg, returns int)...',
  );
  final addArgResults = _runBenchmark(
    name: 'Instance method add(x)',
    warmupIterations: warmupIterations,
    iterations: benchmarkIterations,
    rounds: rounds,
    runNoPool: () => runNoPoolInstanceAddArg(objNoPool, benchmarkIterations),
    runWithPool: () =>
        runWithPoolInstanceAddArg(objWithPool, benchmarkIterations),
    warmupNoPool: () => runNoPoolInstanceAddArg(objNoPool, warmupIterations),
    warmupWithPool: () =>
        runWithPoolInstanceAddArg(objWithPool, warmupIterations),
  );

  // Benchmark 4: Raw autoReleasePool baseline without msgSend
  print('\nBenchmarking 4: Pure autoReleasePool overhead (closure only)...');
  final rawPoolResults = _runBenchmark(
    name: 'Pure autoReleasePool(() => 5)',
    warmupIterations: warmupIterations,
    iterations: benchmarkIterations,
    rounds: rounds,
    runNoPool: () => runPureDartBaseline(benchmarkIterations),
    runWithPool: () => runPureAutoReleasePoolClosure(benchmarkIterations),
    warmupNoPool: () => runPureDartBaseline(warmupIterations),
    warmupWithPool: () => runPureAutoReleasePoolClosure(warmupIterations),
  );

  // Benchmark 5: Instance method -(NSString *)concat:(NSString *)str
  // (1 NSString arg, returns NSString)
  print(
    '\nBenchmarking 5: Instance method `concat(str)` '
    '(NSString arg, returns NSString)...',
  );
  final concatResults = _runBenchmark(
    name: 'Instance method concat(str)',
    warmupIterations: concatWarmupIterations,
    iterations: concatBenchmarkIterations,
    rounds: rounds,
    runNoPool: () => runNoPoolInstanceConcat(
      objNoPool,
      preallocatedInput,
      concatBenchmarkIterations,
    ),
    runWithPool: () => runWithPoolInstanceConcat(
      objWithPool,
      preallocatedInput,
      concatBenchmarkIterations,
    ),
    warmupNoPool: () => runNoPoolInstanceConcat(
      objNoPool,
      preallocatedInput,
      concatWarmupIterations,
    ),
    warmupWithPool: () => runWithPoolInstanceConcat(
      objWithPool,
      preallocatedInput,
      concatWarmupIterations,
    ),
  );

  _printSummaryTable([
    addResults,
    subResults,
    addArgResults,
    rawPoolResults,
    concatResults,
  ]);
}

BenchmarkResult _runBenchmark({
  required String name,
  required int warmupIterations,
  required int iterations,
  required int rounds,
  required int Function() runNoPool,
  required int Function() runWithPool,
  required int Function() warmupNoPool,
  required int Function() warmupWithPool,
}) {
  // Warm-up (wrapped in autorelease pool to clean up any warmup allocations)
  var dummy = 0;
  objc.autoReleasePool(() {
    dummy += warmupNoPool();
    dummy += warmupWithPool();
    dummy += warmupNoPool();
    dummy += warmupWithPool();
  });

  final noPoolTimes = <double>[];
  final withPoolTimes = <double>[];

  final stopwatch = Stopwatch();

  for (var round = 1; round <= rounds; round++) {
    // Alternate ordering to avoid warming / ordering bias.
    // Wrap each trial in an outer autorelease pool that pushes before timing
    // starts and pops after timing stops, ensuring autoreleased objects are
    // cleaned up between trials without affecting the measured execution time.
    if (round.isOdd) {
      objc.autoReleasePool(() {
        stopwatch.reset();
        stopwatch.start();
        dummy += runNoPool();
        stopwatch.stop();
      });
      final noPoolNs = (stopwatch.elapsedMicroseconds * 1000.0) / iterations;
      noPoolTimes.add(noPoolNs);

      objc.autoReleasePool(() {
        stopwatch.reset();
        stopwatch.start();
        dummy += runWithPool();
        stopwatch.stop();
      });
      final withPoolNs = (stopwatch.elapsedMicroseconds * 1000.0) / iterations;
      withPoolTimes.add(withPoolNs);
    } else {
      objc.autoReleasePool(() {
        stopwatch.reset();
        stopwatch.start();
        dummy += runWithPool();
        stopwatch.stop();
      });
      final withPoolNs = (stopwatch.elapsedMicroseconds * 1000.0) / iterations;
      withPoolTimes.add(withPoolNs);

      objc.autoReleasePool(() {
        stopwatch.reset();
        stopwatch.start();
        dummy += runNoPool();
        stopwatch.stop();
      });
      final noPoolNs = (stopwatch.elapsedMicroseconds * 1000.0) / iterations;
      noPoolTimes.add(noPoolNs);
    }

    print(
      '  Trial $round: no_pool=${noPoolTimes.last.toStringAsFixed(2)} ns/call, '
      'with_pool=${withPoolTimes.last.toStringAsFixed(2)} ns/call '
      '(+${(withPoolTimes.last - noPoolTimes.last).toStringAsFixed(2)} ns, '
      '${(withPoolTimes.last / noPoolTimes.last).toStringAsFixed(2)}x)',
    );
  }

  // Prevent dead code elimination
  if (dummy == -123456789) print(dummy);

  return BenchmarkResult(
    name: name,
    iterations: iterations,
    noPoolNsPerCall: noPoolTimes,
    withPoolNsPerCall: withPoolTimes,
  );
}

void _printSummaryTable(List<BenchmarkResult> results) {
  print('\n===============================================================');
  print('BENCHMARK RESULTS SUMMARY');
  print('===============================================================');
  print(
    '${'Benchmark Name'.padRight(32)} | '
    '${'wrap: false'.padLeft(14)} | '
    '${'wrap: true'.padLeft(14)} | '
    '${'Overhead (delta)'.padLeft(18)} | '
    '${'Multiplier'.padLeft(10)}',
  );
  print(
    '${''.padRight(32, '-')}-+-'
    '${''.padRight(14, '-')}-+-'
    '${''.padRight(14, '-')}-+-'
    '${''.padRight(18, '-')}-+-'
    '${''.padRight(10, '-')}',
  );

  for (final r in results) {
    final noPoolStr =
        '${r.noPoolMean.toStringAsFixed(2)} ± '
        '${r.noPoolStdDev.toStringAsFixed(2)} ns';
    final withPoolStr =
        '${r.withPoolMean.toStringAsFixed(2)} ± '
        '${r.withPoolStdDev.toStringAsFixed(2)} ns';
    final overheadStr =
        '+${r.overheadNs.toStringAsFixed(2)} ns '
        '(+${r.percentIncrease.toStringAsFixed(1)}%)';
    final multStr = '${r.overheadMultiplier.toStringAsFixed(2)}x';

    print(
      '${r.name.padRight(32)} | '
      '${noPoolStr.padLeft(14)} | '
      '${withPoolStr.padLeft(14)} | '
      '${overheadStr.padLeft(18)} | '
      '${multStr.padLeft(10)}',
    );
    print(
      '  (Medians: no_pool=${r.noPoolMedian.toStringAsFixed(2)} ns, '
      'with_pool=${r.withPoolMedian.toStringAsFixed(2)} ns, '
      'iterations=${r.iterations})',
    );
  }
  print('===============================================================');
}
