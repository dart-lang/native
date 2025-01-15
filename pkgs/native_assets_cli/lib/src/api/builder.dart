// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../config.dart';
import 'linker.dart';

/// A builder to be run during a build hook.
///
/// [Builder]s should be used to build native code, download assets, and
/// transform assets. A build hook is only rerun when its declared
/// [BuildOutput.dependencies] change. ([Linker]s have access to tree-shaking
/// information in some build modes, and could potentially build or download
/// less assets. However, due to the tree-shaking information being an input to
/// link hooks, link hooks are re-run much more often.)
///
/// A package to be used in build hooks should implement this interface. The
/// typical pattern of build hooks should be a declarative specification of one
/// or more builders (constructor calls), followed by [run]ning these builders.
///
/// For example with a single builder from `package:native_toolchain_c`:
///
/// ```dart
/// import 'package:logging/logging.dart';
/// import 'package:native_assets_cli/native_assets_cli.dart';
/// import 'package:native_toolchain_c/native_toolchain_c.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     final packageName = input.packageName;
///     final cbuilder = CBuilder.library(
///       name: packageName,
///       assetName: '$packageName.dart',
///       sources: [
///         'src/$packageName.c',
///       ],
///     );
///     await cbuilder.run(
///       buildInput: input,
///       buildOutput: output,
///       logger: Logger('')
///         ..level = Level.ALL
///         ..onRecord.listen((record) => print(record.message)),
///     );
///   });
/// }
/// ```
abstract interface class Builder {
  /// Runs this build.
  ///
  /// Reads the input from [input], streams output to [output], and streams
  /// logs to [logger].
  Future<void> run({
    required BuildInput input,
    required BuildOutputBuilder output,
    required Logger? logger,
  });
}
