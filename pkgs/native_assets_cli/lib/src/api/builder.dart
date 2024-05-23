import 'package:logging/logging.dart';

import 'build_config.dart';
import 'build_output.dart';
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
///   await build(args, (config, output) async {
///     final packageName = config.packageName;
///     final cbuilder = CBuilder.library(
///       name: packageName,
///       assetName: '$packageName.dart',
///       sources: [
///         'src/$packageName.c',
///       ],
///       dartBuildFiles: ['hook/build.dart'],
///     );
///     await cbuilder.run(
///       buildConfig: config,
///       buildOutput: output,
///       logger: Logger('')
///         ..level = Level.ALL
///         ..onRecord.listen((record) => print(record.message)),
///     );
///   });
/// }
/// ```
///
/// The builder is designed to immediately operate on [BuildConfig]. If a
/// builder should deviate behavior from the build config, this should be
/// configurable through a constructor parameter. For example, if a native
/// compiler should output a static library to be sent to a linker, but the
/// [BuildConfig.linkModePreference] is set to dynamic linking, the builder
/// should have its own `linkModePreference` parameter in the constructor.
///
/// The builder is designed to immediately operate on [BuildOutput]. If a
/// builder should output something else than standard, it should be
/// configurable through a constructor parameter. For example to send an asset
/// for linking to the output ([BuildOutput.addAsset] with `linkInPackage` set),
/// the builder should have a constructor parameter. (Instead of capturing the
/// BuildOutput as a return value and manually manipulating it in the build
/// hook.) This ensures that builder is in control of what combination of build
/// outputs are valid.
abstract interface class Builder {
  /// Runs this build.
  ///
  /// Reads the config from [config], streams output to [output], and streams
  /// logs to [logger].
  // TODO(dacoharkes): Should this be `build` instead of `run`?
  Future<void> run({
    required BuildConfig config,
    required BuildOutput output,
    required Logger? logger,
  });
}
