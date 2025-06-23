// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Optimization level for code compilation.
///
/// For more information refer to compiler documentation:
/// * https://clang.llvm.org/docs/CommandGuide/clang.html#code-generation-options
/// * https://learn.microsoft.com/en-us/cpp/build/reference/o-options-optimize-code?view=msvc-170
final class OptimizationLevel {
  /// The optimization level.
  final String _level;

  const OptimizationLevel._(this._level);

  /// No optimization; prioritize fast compilation.
  static const OptimizationLevel o0 = OptimizationLevel._('O0');

  /// Basic optimizations; balance compilation speed and code size.
  static const OptimizationLevel o1 = OptimizationLevel._('O1');

  /// More aggressive optimizations; prioritize code size reduction.
  static const OptimizationLevel o2 = OptimizationLevel._('O2');

  /// The most aggressive optimizations; prioritize runtime performance.
  ///
  /// Not supported in MSVC, defaults to [o2] for MSVC.
  static const OptimizationLevel o3 = OptimizationLevel._('O3');

  /// Optimize for code size, even if it impacts runtime performance.
  static const OptimizationLevel oS = OptimizationLevel._('Os');

  /// Unspecified optimization level; the default or compiler-chosen level.
  static const OptimizationLevel unspecified = OptimizationLevel._(
    'unspecified',
  );

  /// Returns the string representation of the optimization level.
  @override
  String toString() => _level;

  String clangFlag() => '-$_level';

  String msvcFlag() => switch (this) {
    o3 => o2.msvcFlag(),
    _ => '/$_level',
  };

  static const List<OptimizationLevel> values = [
    o0,
    o1,
    o2,
    o3,
    oS,
    unspecified,
  ];
}
