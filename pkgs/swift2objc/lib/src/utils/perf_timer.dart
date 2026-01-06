// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

/// Performance profiling utilities for swift2objc codegen.
///
/// This module provides timing instrumentation to identify bottlenecks
/// in the swift2objc generation pipeline.
///
/// Usage:
///   final timer = PerfTimer.start('parsing');
///   // ... do work ...
///   timer.stop();  // Prints: ✓ parsing: 1.23s
///

class PerfTimer {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();
  final Logger _logger;

  PerfTimer._(this.name, this._logger) {
    _stopwatch.start();
  }

  /// Start a performance timer with the given name.
  factory PerfTimer.start(String name, [Logger? logger]) {
    return PerfTimer._(name, logger ?? Logger.detached('perf'));
  }

  /// Stop the timer and log the result.
  void stop({String? suffix}) {
    _stopwatch.stop();
    final elapsed = _stopwatch.elapsed.inMilliseconds / 1000.0;
    final display = suffix != null ? '$name: $suffix' : name;
    _logger.info('✓ $display: ${elapsed.toStringAsFixed(2)}s');
  }

  /// Stop and return the elapsed time in milliseconds.
  int stopMs() {
    _stopwatch.stop();
    return _stopwatch.elapsedMilliseconds;
  }

  /// Get current elapsed time without stopping.
  Duration get elapsed => _stopwatch.elapsed;
}

/// Scope-based performance tracking.
class PerfScope {
  final String name;
  final Logger logger;
  late final PerfTimer _timer;
  final List<PerfScope> _children = [];

  PerfScope(this.name, {Logger? logger})
    : logger = logger ?? Logger.detached('perf') {
    _timer = PerfTimer.start(name, this.logger);
  }

  /// Create a child scope.
  PerfScope child(String name) {
    final scope = PerfScope(name, logger: logger);
    _children.add(scope);
    return scope;
  }

  /// Close this scope and log results.
  void close() {
    _timer.stop();
    if (_children.isNotEmpty) {
      final totalChild = _children.fold<int>(
        0,
        (sum, c) => sum + c._timer.stopMs(),
      );
      logger.info(
        '  └─ children: ${totalChild}ms / ${_timer.stopMs()}ms total',
      );
    }
  }

  /// Close and return elapsed milliseconds.
  int closeMs() {
    final ms = _timer.stopMs();
    return ms;
  }
}
