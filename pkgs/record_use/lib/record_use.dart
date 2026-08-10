// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'src/recordings.dart';

/// Dart API to access `@RecordUse()` recorded usages in link hooks.
///
/// During compilation, usages of declarations annotated with `@RecordUse()` in
/// reachable code are recorded, and information about these usages is made
/// available to post-compile steps (such as link hooks). Usages in unreachable
/// code are not recorded.
///
/// The main entrypoint for recorded usages is [Recordings].
///
/// - If placed on a statically resolved function or member (such as a top-level
///   function, static method, non-redirecting factory constructor, getter,
///   setter, operator, extension method, or extension type method), all calls
///   to or tear-offs of that member in reachable code will be recorded, along
///   with arguments passed to the call as far as they can be evaluated as
///   constant expressions at compile time. These can be found in
///   [Recordings.calls]. Generative constructors and redirecting factory
///   constructors cannot be annotated directly.
/// - If placed on a `final class` or `enum`:
///   - For a `final class`: any constant instance of the class (including
///     instances created via `const` redirecting factory constructors), any
///     non-const generative constructor invocation, and any generative
///     constructor tear-off in reachable code will be recorded. These can be
///     found in [Recordings.instances]. Calls to non-const factory constructors
///     are not recorded directly by annotating the class; rather, any
///     generative constructor invocation within the factory body will be
///     recorded.
///   - For an `enum`: any constant enum element in reachable code will be
///     recorded in [Recordings.instances].
///   - The `@RecordUse()` annotation cannot be placed directly on an
///     `extension type` to record instances.
///
/// Only usages in executable code are recorded. Usages appearing within
/// metadata (annotations) are ignored.
///
/// The `@RecordUse()` annotation is only allowed on declarations within a
/// package's `lib/` directory.
///
/// ## Example
///
/// <!-- file://./../example/api/usage.dart#usage -->
/// ```dart
/// void main() {
///   PirateTranslator.speak('Hello');
///   print(const PirateShip('Black Pearl', 50));
/// }
///
/// abstract class PirateTranslator {
///   @RecordUse()
///   static String speak(String english) => 'Ahoy $english';
/// }
///
/// @RecordUse()
/// final class PirateShip {
///   final String name;
///   final int cannons;
///
///   const PirateShip(this.name, this.cannons);
/// }
/// ```
/// This code will generate a data file that contains both the field values of
/// the `PirateShip` instances, as well as the arguments for the `speak` method
/// annotated with `@RecordUse()`.
///
/// This information can then be accessed in a link hook as follows:
/// <!-- file://./../example/api/usage_link.dart#link -->
/// ```dart
/// void main(List<String> arguments) {
///   link(arguments, (input, output) async {
///     final uses = input.recordedUses;
///     if (uses == null) return;
///
///     final calls = uses.calls[methodId] ?? [];
///     for (final call in calls) {
///       switch (call) {
///         case CallWithArguments(
///           positionalArguments: [StringConstant(value: final english), ...],
///         ):
///           // Shrink a translations file based on all the different translation
///           // keys.
///           print('Translating to pirate: $english');
///         case _:
///           print('Cannot determine which translations are used.');
///       }
///     }
///
///     final ships = uses.instances[classId] ?? [];
///     for (final ship in ships) {
///       switch (ship) {
///         case InstanceConstantReference(
///           instanceConstant: InstanceConstant(
///             fields: {'name': StringConstant(value: final name)},
///           ),
///         ):
///           // Include the 3d model for this ship in the application but not
///           // bundle the other ships.
///           print('Pirate ship found: $name');
///         case _:
///           print('Cannot determine which ships are used.');
///       }
///     }
///   });
/// }
/// ```
library;

export 'src/constant.dart'
    show
        BoolConstant,
        Constant,
        DoubleConstant,
        EnumConstant,
        InstanceConstant,
        IntConstant,
        ListConstant,
        MapConstant,
        MaybeConstant,
        NonConstant,
        NullConstant,
        RecordConstant,
        SetConstant,
        StringConstant,
        SymbolConstant,
        UnsupportedConstant;
export 'src/definition.dart'
    show
        Class,
        Constructor,
        Definition,
        DefinitionWithInstances,
        DefinitionWithMembers,
        DefinitionWithStaticCalls,
        Enum,
        Extension,
        ExtensionType,
        Getter,
        Library,
        Member,
        Method,
        Mixin,
        Operator,
        ScopeWithMembers,
        Setter;
export 'src/loading_unit.dart' show LoadingUnit;
export 'src/recordings.dart' show Recordings;
export 'src/reference.dart'
    show
        CallReference,
        CallTearoff,
        CallWithArguments,
        ConstructorTearoffReference,
        InstanceConstantReference,
        InstanceCreationReference,
        InstanceReference;
