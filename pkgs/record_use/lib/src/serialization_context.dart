// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library defines the context objects used to manage reference pools
/// during serialization and deserialization of normalized JSON.
///
/// A **pool** is a deduplicated collection of semantic objects (such as
/// [Constant]s) that are represented as a list at the top level of the JSON.
/// Other objects reference these by their integer index into the pool.
///
/// ### Layer Responsibilities
///
/// The **Syntax Layer** ([ConstantSyntax], [RecordedUsesSyntax], etc.) is
/// designed to be context-free, acting as a thin wrapper around JSON data. This
/// aligns with the capabilities of standard JSON Schema. The syntax defines how
/// pools are physically encoded in JSON as flat, top-level arrays (e.g.,
/// [RecordedUsesSyntax.constants]). It uses integer indices to represent
/// relationships, keeping the JSON structure normalized and deduplicated.
///
/// The **Semantic Layer** ([Constant]s, [Recordings], etc.) translates these
/// flat indices into rich, interconnected semantic objects. It uses
/// [DeserializationContext] and [SerializationContext] to map between the
/// integer indices in the JSON and deduplicated [Constant] objects, ensuring
/// identity is preserved across the system.
///
/// ### (De)serialization Order
///
/// The order of operations ensures that all dependencies are available at each
/// step:
///
/// 1. **Loading Units**: Loading unit identifiers are deserialized from or
///    serialized to the [RecordedUsesSyntax.loadingUnits] pool first.
/// 2. **Definitions**: [Definition] objects are deserialized from or
///    serialized to the [RecordedUsesSyntax.definitions] pool second.
/// 3. **Constants**: [Constant] objects are deserialized from or serialized
///    to the [RecordedUsesSyntax.constants] pool third. They may contain
///    references to the definitions pool (e.g. for [InstanceConstant]) and the
///    constants pool (for recursive collections).
/// 4. **Recordings**: Recordings are (de)serialized last from or to
///    [RecordedUsesSyntax.uses] as they depend on loading units,
///    [Constant]s, and [Definition]s.
library;

import 'package:meta/meta.dart';

import 'constant.dart';
import 'definition.dart';
import 'loading_unit.dart';
import 'recordings.dart';
import 'syntax.g.dart';

/// Context providing access to the loading unit pool during deserialization.
@immutable
base class LoadingUnitDeserializationContext {
  final List<LoadingUnit> loadingUnits;

  const LoadingUnitDeserializationContext(this.loadingUnits);
}

/// Context providing access to the [Definition] pool during deserialization.
@immutable
base class DefinitionDeserializationContext
    extends LoadingUnitDeserializationContext {
  final List<Definition> definitions;

  DefinitionDeserializationContext.fromPrevious(
    LoadingUnitDeserializationContext previous,
    this.definitions,
  ) : super(previous.loadingUnits);
}

/// The final deserialization state where all pools are resolved.
@immutable
final class DeserializationContext extends DefinitionDeserializationContext {
  /// The mapping from the unique integer index in
  /// [RecordedUsesSyntax.constants] to the semantic [Constant]s.
  final List<Constant> constants;

  DeserializationContext.fromPrevious(
    DefinitionDeserializationContext previous,
    this.constants,
  ) : super.fromPrevious(previous, previous.definitions);
}

/// Context providing access to the loading unit index map during serialization.
@immutable
base class LoadingUnitSerializationContext {
  final Map<LoadingUnit, int> loadingUnits;

  const LoadingUnitSerializationContext(this.loadingUnits);
}

/// Context providing access to the [Definition] index map during serialization.
@immutable
base class DefinitionSerializationContext
    extends LoadingUnitSerializationContext {
  final Map<Definition, int> definitions;

  DefinitionSerializationContext.fromPrevious(
    LoadingUnitSerializationContext previous,
    this.definitions,
  ) : super(previous.loadingUnits);
}

/// The final serialization state where all index maps are available.
@immutable
final class SerializationContext extends DefinitionSerializationContext {
  /// The mapping from semantic [Constant] objects to their unique integer index
  /// within the constants pool ([RecordedUsesSyntax.constants]).
  final Map<Constant, int> constants;

  SerializationContext.fromPrevious(
    DefinitionSerializationContext previous,
    this.constants,
  ) : super.fromPrevious(previous, previous.definitions);
}
