// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'architecture.dart';
import 'config.dart';
import 'native_library_headers.dart';
import 'os.dart';

/// The input supplied to a [NativeLibraryValidator].
final class NativeLibraryValidationContext {
  /// The dynamic library to validate.
  final Uri file;

  /// The configuration of the hook invocation that produced [file].
  final CodeConfig config;

  /// Creates a native library validation context.
  const NativeLibraryValidationContext({
    required this.file,
    required this.config,
  });
}

/// Validates a bundled dynamic library produced by a build or link hook.
///
/// Validators are trusted extensions supplied by the hook invoker. They must
/// return [NativeLibraryValidation.notRecognized] for files outside their
/// domain. A validator may return [NativeLibraryValidation.matched] only when
/// it covers the current contract: the expected container family for the
/// target operating system and the target architecture family in [CodeConfig].
abstract interface class NativeLibraryValidator {
  /// Validates the library described by [context].
  Future<NativeLibraryValidation> validate(
    NativeLibraryValidationContext context,
  );
}

/// The result of running a [NativeLibraryValidator].
sealed class NativeLibraryValidation {
  const NativeLibraryValidation._();

  /// The validator does not recognize the file or target.
  const factory NativeLibraryValidation.notRecognized() = _NotRecognized;

  /// The validator recognizes the file but cannot validate the whole contract.
  factory NativeLibraryValidation.inconclusive(String reason) {
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'Must not be empty.');
    }
    return _Inconclusive(reason);
  }

  /// The file matches every target dimension understood by the validator.
  const factory NativeLibraryValidation.matched() = _Matched;

  /// The file is invalid for one or more reasons.
  factory NativeLibraryValidation.rejected(Iterable<String> errors) {
    final snapshot = List<String>.unmodifiable(errors);
    if (snapshot.isEmpty || snapshot.any((error) => error.trim().isEmpty)) {
      throw ArgumentError.value(
        errors,
        'errors',
        'Must contain only non-empty errors.',
      );
    }
    return _Rejected(snapshot);
  }
}

final class _NotRecognized extends NativeLibraryValidation {
  const _NotRecognized() : super._();
}

final class _Inconclusive extends NativeLibraryValidation {
  const _Inconclusive(this.reason) : super._();

  final String reason;
}

final class _Matched extends NativeLibraryValidation {
  const _Matched() : super._();
}

final class _Rejected extends NativeLibraryValidation {
  const _Rejected(this.errors) : super._();

  final List<String> errors;
}

/// Runs the built-in validator and [additionalValidators] in registration
/// order, without allowing one validator to bypass a rejection from another.
Future<({List<String> errors, List<String> warnings})> validateNativeLibrary(
  NativeLibraryValidationContext context,
  Iterable<NativeLibraryValidator> additionalValidators,
) async {
  final errors = <String>[];
  final inconclusiveReasons = <String>[];
  var matched = false;

  for (final validator in <NativeLibraryValidator>[
    const _NativeLibraryHeaderValidator(),
    ...additionalValidators,
  ]) {
    final NativeLibraryValidation result;
    try {
      result = await validator.validate(context);
    } catch (error) {
      errors.add('${validator.runtimeType} failed: $error');
      continue;
    }
    switch (result) {
      case _NotRecognized():
        break;
      case _Inconclusive(:final reason):
        inconclusiveReasons.add(reason);
      case _Matched():
        matched = true;
      case _Rejected(errors: final validatorErrors):
        errors.addAll(validatorErrors);
    }
  }

  if (errors.isNotEmpty || matched) {
    return (errors: errors, warnings: const <String>[]);
  }
  if (inconclusiveReasons.isNotEmpty) {
    return (errors: const <String>[], warnings: inconclusiveReasons);
  }
  return (
    errors: const <String>[],
    warnings: const ['No registered validator recognized the file and target.'],
  );
}

final class _NativeLibraryHeaderValidator implements NativeLibraryValidator {
  const _NativeLibraryHeaderValidator();

  @override
  Future<NativeLibraryValidation> validate(
    NativeLibraryValidationContext context,
  ) async {
    final header = readNativeLibraryHeader(File.fromUri(context.file));
    if (header is UnrecognizedHeader) {
      return const NativeLibraryValidation.notRecognized();
    }

    final recognized = header as RecognizedHeader;
    if (recognized.format == BinaryFormat.machO &&
        recognized.architectureCount > 1) {
      return NativeLibraryValidation.rejected([
        'is a multi-architecture Mach-O binary. Hooks run once per target '
            'architecture and must output a thin Mach-O binary.',
      ]);
    }

    final expectedFormat = _expectedFormat(context.config.targetOS);
    if (expectedFormat == null) {
      return NativeLibraryValidation.inconclusive(
        'The built-in validator does not know the binary format for target '
        'OS ${context.config.targetOS}.',
      );
    }
    if (recognized.format != expectedFormat) {
      return NativeLibraryValidation.rejected([
        'is a ${recognized.format.displayName} binary, but '
            '${context.config.targetOS} expects ${expectedFormat.displayName}.',
      ]);
    }

    final targetArchitecture = context.config.targetArchitecture;
    if (!Architecture.values.contains(targetArchitecture)) {
      return NativeLibraryValidation.inconclusive(
        'The built-in validator does not know target architecture '
        '$targetArchitecture.',
      );
    }

    if (recognized.architectures.contains(targetArchitecture)) {
      return const NativeLibraryValidation.matched();
    }
    final known = recognized.architectures.whereType<Architecture>().toList();
    if (known.isEmpty) {
      final machineValues = recognized.machineValues.map(
        (value) => '0x${value.toRadixString(16)}',
      );
      return NativeLibraryValidation.inconclusive(
        'The built-in validator does not recognize machine value(s) '
        '${machineValues.join(', ')}.',
      );
    }
    return NativeLibraryValidation.rejected([
      'is built for ${known.join(', ')}, but the target architecture is '
          '$targetArchitecture.',
    ]);
  }
}

BinaryFormat? _expectedFormat(OS targetOS) => switch (targetOS) {
  OS.android || OS.fuchsia || OS.linux => BinaryFormat.elf,
  OS.iOS || OS.macOS => BinaryFormat.machO,
  OS.windows => BinaryFormat.pe,
  _ => null,
};
