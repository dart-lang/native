// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'syntax.g.dart';

/// A compiler sanitizer.
///
/// Sanitizers instrument binaries to perform runtime analysis and detect
/// various bugs (such as invalid memory accesses or data races).
///
/// Clang, GCC, and MSVC support compiling and linking with different
/// sanitizers using compiler-specific flags.
final class Sanitizer {
  /// The name of this sanitizer.
  final String name;

  const Sanitizer._(this.name);

  /// AddressSanitizer (ASan) to detect memory errors (e.g. out-of-bounds).
  ///
  /// Supported flags:
  /// * Clang/GCC: `-fsanitize=address`
  /// * MSVC: `/fsanitize=address`
  ///
  /// Documentation:
  /// * Clang: <https://clang.llvm.org/docs/AddressSanitizer.html>
  /// * MSVC: <https://learn.microsoft.com/en-us/cpp/sanitizers/asan>
  static const Sanitizer asan = Sanitizer._('asan');

  /// MemorySanitizer (MSan) to detect uninitialized memory reads.
  ///
  /// Supported flags:
  /// * Clang/GCC: `-fsanitize=memory` (not supported in MSVC)
  ///
  /// Documentation:
  /// * Clang: <https://clang.llvm.org/docs/MemorySanitizer.html>
  static const Sanitizer msan = Sanitizer._('msan');

  /// ThreadSanitizer (TSan) to detect data races between threads.
  ///
  /// Supported flags:
  /// * Clang/GCC: `-fsanitize=thread` (not supported in MSVC)
  ///
  /// Documentation:
  /// * Clang: <https://clang.llvm.org/docs/ThreadSanitizer.html>
  static const Sanitizer tsan = Sanitizer._('tsan');

  /// Known values for [Sanitizer].
  static const List<Sanitizer> values = [asan, msan, tsan];

  /// The name of this [Sanitizer].
  ///
  /// This returns a stable string that can be used to construct a
  /// [Sanitizer] via [Sanitizer.fromString].
  @override
  String toString() => name;

  /// Creates a [Sanitizer] from the given [name].
  ///
  /// The name can be obtained from [Sanitizer.name] or [Sanitizer.toString].
  factory Sanitizer.fromString(String name) =>
      values.firstWhere((e) => e.name == name, orElse: () => Sanitizer._(name));

  @override
  bool operator ==(Object other) => other is Sanitizer && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// Extension methods for [Sanitizer] to convert to and from the syntax model.
extension SanitizerSyntaxExtension on Sanitizer {
  /// Converts this [Sanitizer] to its corresponding [SanitizerSyntax].
  SanitizerSyntax toSyntax() => SanitizerSyntax.fromJson(name);

  /// Converts an [SanitizerSyntax] to its corresponding [Sanitizer].
  static Sanitizer fromSyntax(SanitizerSyntax syntax) =>
      Sanitizer.fromString(syntax.name);
}
