// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../record_use_internal.dart';

/// Holds all information recorded during compilation.
///
/// This can be queried using the methods provided, which each take an
/// [Definition] which must be annotated with `@RecordUse` from `package:meta`.
///
/// The definition annotated with `@RecordUse` must be inside the `lib/`
/// directory of the package. If the definition is a member of a class (e.g. a
/// static method), the class must be in the `lib/` directory.
extension type RecordedUsages._(Recordings _recordings) {
  RecordedUsages.fromJson(Map<String, Object?> json)
    : this._(Recordings.fromJson(json));

  /// Show the metadata for this recording of usages.
  Metadata get metadata => _recordings.metadata;

  /// Finds all recorded arguments for calls to the [definition].
  ///
  /// The definition must be annotated with `@RecordUse()`. The definition (and
  /// its enclosing class, if any) must be in the `lib/` directory of the
  /// package. If there are no calls to the definition, either because it was
  /// treeshaken, because it was not annotated, or because it does not exist,
  /// this method returns an empty iterable.
  ///
  /// Returns an empty iterable if the arguments were not collected.
  ///
  /// Example:
  /// <!-- file://./../../example/api/usage.dart#static-call -->
  /// ```dart
  /// abstract class PirateTranslator {
  ///   @RecordUse()
  ///   static String speak(String english) => 'Ahoy $english';
  /// }
  /// ```
  ///
  /// To retrieve the recorded const arguments:
  ///
  /// <!-- file://./../../example/api/usage_link.dart#static-call -->
  /// ```dart
  /// final args = uses.constArgumentsFor(methodId);
  /// for (final arg in args) {
  ///   if (arg.positional[0] case StringConstant(value: final english)) {
  ///     print('Translating to pirate: $english');
  ///     // Shrink a translations file based on all the different translation
  ///     // keys.
  ///   }
  /// }
  /// ```
  // TODO(https://github.com/dart-lang/native/issues/2718): Make tearoffs more
  // front and center.
  Iterable<
    ({
      Map<String, MaybeConstant> named,
      List<MaybeConstant> positional,
      MaybeConstant? receiver,
    })
  >
  constArgumentsFor(Definition definition) =>
      _recordings.calls[definition]?.whereType<CallWithArguments>().map(
        (call) => (
          named: call.namedArguments,
          positional: call.positionalArguments,
          receiver: call.receiver,
        ),
      ) ??
      [];

  /// Finds all constant instances of the class [definition].
  ///
  /// The definition must be annotated with `@RecordUse()`. The definition (and
  /// its enclosing class, if any) must be in the `lib/` directory of the
  /// package. If there are no instances of the definition, either because it
  /// was treeshaken, because it was not annotated, or because it does not
  /// exist, this method returns an empty iterable.
  ///
  /// Example:
  /// <!-- file://./../../example/api/usage.dart#const-instance -->
  /// ```dart
  /// @RecordUse()
  /// class PirateShip {
  ///   final String name;
  ///   final int cannons;
  ///
  ///   const PirateShip(this.name, this.cannons);
  /// }
  /// ```
  ///
  /// To retrieve the constant instances:
  ///
  /// <!-- file://./../../example/api/usage_link.dart#const-instance -->
  /// ```dart
  /// final ships = uses.constantsOf(classId);
  /// for (final ship in ships) {
  ///   if (ship.fields['name'] case StringConstant(value: final name)) {
  ///     print('Pirate ship found: $name');
  ///     // Include the 3d model for this ship in the application but not
  ///     // bundle the other ships.
  ///   }
  /// }
  /// ```
  // TODO(https://github.com/dart-lang/native/issues/2718): Make non-consts more
  // front and center.
  Iterable<InstanceConstant> constantsOf(Definition definition) =>
      _recordings.instances[definition]
          ?.whereType<InstanceConstantReference>()
          .map((reference) => reference.instanceConstant) ??
      [];

  /// Checks if any call to [definition] has non-const arguments, or if any
  /// tear-off was recorded.
  ///
  /// The definition must be annotated with `@RecordUse()`. The definition (and
  /// its enclosing class, if any) must be in the `lib/` directory of the
  /// package. If there are no calls to the definition, either because it was
  /// treeshaken, because it was not annotated, or because it does not exist,
  /// this method returns `false`.
  // TODO(https://github.com/dart-lang/native/issues/2718): Make non-consts more
  // front and center.
  bool hasNonConstArguments(Definition definition) =>
      (_recordings.calls[definition] ?? []).any(
        (element) => switch (element) {
          CallTearoff() => true,
          final CallWithArguments call =>
            call.positionalArguments.any((a) => a is NonConstant) ||
                call.namedArguments.values.any((a) => a is NonConstant),
        },
      );
}
