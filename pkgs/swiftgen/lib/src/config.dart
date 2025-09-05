// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' as ffigen;
import 'package:swift2objc/swift2objc.dart' as swift2objc;

/// Config options for swiftgen. Takes a Swift API as input, and generates Dart
/// bindings to interop with that API.
///
/// Dart's interop with Swift is built on Objective-C interop. Swift APIs can be
/// accessed through Objective-C, and Dart can access Objective-C using ffigen.
///
/// Swift -> Objective-C -> Dart
///
/// The Swift -> Objective-C step requires that the Swift API is compatible with
/// Objective-C. If your API is compatible, you can use
/// [ObjCCompatibleSwiftFileInput]. Otherwise, you'll need a wrapper layer that
/// is compatible. This wrapper will be automatically generated if you use
/// [SwiftFileInput] or [SwiftModuleInput]. The generated wrapper must be
/// compiled into your final app or plugin, along with any bindings generated
/// by ffigen.
class SwiftGenerator {
  /// The target OS and SDK version to compile against.
  final Target target;

  /// The input Swift APIs.
  final List<SwiftGenInput> inputs;

  /// Determines whether a Swift API included in the generated bindings.
  final bool Function(swift2objc.Declaration declaration) include;

  /// Configuration for the output files.
  final Output output;

  /// Configuration for the ffigen pass.
  final FfiGeneratorOptions ffigen;

  static bool _defaultInclude(swift2objc.Declaration _) => true;

  const SwiftGenerator({
    required this.target,
    required this.inputs,
    this.include = _defaultInclude,
    required this.output,
    required this.ffigen,
  });
}

/// Configuration for the output files.
class Output {
  /// Configuration for the Objective-C compatible wrapper API.
  ///
  /// This must be present if the original Swift API is not Objective-C
  /// compatible. That is, if you're using [SwiftFileInput] or
  /// [SwiftModuleInput]. If all your inputs are [ObjCCompatibleSwiftFileInput]
  /// you do not need to set this field.
  final SwiftWrapperFile? swiftWrapperFile;

  /// The name of the output Swift module.
  ///
  /// The Dart bindings use this to look up the Swift symbols. So it's important
  /// that this matches the name of module that the Swift source code, including
  /// the wrapper API, is compiled into. For a Flutter plugin, this is simply
  /// the plugin name.
  final String module;

  /// The output Dart file for the generated bindings.
  final Uri dartFile;

  /// The output Objective-C file for the generated Objective-C bindings.
  final Uri objectiveCFile;

  /// Extra code inserted at the top of the generated Dart bindings.
  final String? preamble;

  /// The asset id to use for the @Native annotations.
  ///
  /// If omitted, it will not be generated.
  final String? assetId;

  const Output({
    this.swiftWrapperFile,
    required this.module,
    required this.dartFile,
    required this.objectiveCFile,
    this.preamble,
    this.assetId,
  });
}

/// Configuration for the Objective-C compatible wrapper API.
///
/// This is a generated Swift API that wraps another Swift API and makes it
/// Objective-C compatible.
class SwiftWrapperFile {
  /// The output path for the wrapper API.
  final Uri path;

  /// Extra code inserted at the top of the generated Swift file.
  final String? preamble;

  const SwiftWrapperFile({required this.path, this.preamble});
}

/// The target defines the OS (ie macOS or iOS), SDK version, and architecture
/// being targeted by the bindings.
///
/// The architecture almost never matters for the purposes of generating Dart
/// bindings. Also, since the bindings include OS version checks, it's usually
/// fine to just target the latest SDK version.
///
/// Typically the only thing to decide is whether you're targeting iOS or macOS.
/// So for most use cases you can simply use either [iOSArm64Latest] or
/// [macOSArm64Latest].
class Target {
  /// The target triple, eg x86_64-apple-ios17.0.
  final String triple;

  /// The path to the iOS/macOS SDK.
  final Uri sdk;

  const Target({required this.triple, required this.sdk});

  /// Returns the [Target] corresponding to the host OS.
  static Future<Target> host() async => Target(
    triple: await swift2objc.hostTargetTriple,
    sdk: await swift2objc.hostSdk,
  );

  /// Returns the [Target] for the latest installed iOS SDK on arm.
  static Future<Target> iOSArmLatest() async => Target(
    triple: await swift2objc.iOSArmTargetTripleLatest,
    sdk: await swift2objc.iOSSdk,
  );

  /// Returns the [Target] for the latest installed iOS SDK on arm64.
  static Future<Target> iOSArm64Latest() async => Target(
    triple: await swift2objc.iOSArm64TargetTripleLatest,
    sdk: await swift2objc.iOSSdk,
  );

  /// Returns the [Target] for the latest installed iOS SDK on x64.
  static Future<Target> iOSX64Latest() async => Target(
    triple: await swift2objc.iOSX64TargetTripleLatest,
    sdk: await swift2objc.iOSSdk,
  );

  /// Returns the [Target] for the latest installed macOS SDK on arm64.
  static Future<Target> macOSArm64Latest() async => Target(
    triple: await swift2objc.macOSArm64TargetTripleLatest,
    sdk: await swift2objc.macOSSdk,
  );

  /// Returns the [Target] for the latest installed macOS SDK on x64.
  static Future<Target> macOSX64Latest() async => Target(
    triple: await swift2objc.macOSX64TargetTripleLatest,
    sdk: await swift2objc.macOSSdk,
  );
}

/// Describes the inputs to the swiftgen pipeline.
abstract interface class SwiftGenInput {
  swift2objc.InputConfig? get swift2ObjCConfig;
  Iterable<Uri> get files;
}

/// Input swift files that are already annotated with @objc.
class ObjCCompatibleSwiftFileInput implements SwiftGenInput {
  /// A list of paths to the Objective-C compatible Swift files to generate
  /// bindings for.
  @override
  final List<Uri> files;

  @override
  swift2objc.InputConfig? get swift2ObjCConfig => null;

  const ObjCCompatibleSwiftFileInput({required this.files});
}

/// Input swift files that are not necessarily Objective C compatible.
class SwiftFileInput implements SwiftGenInput {
  /// A list of paths to the Swift files to generate bindings for.
  @override
  final List<Uri> files;

  /// The name of the temporary module generated while analyzing the input
  /// files. The name doesn't matter, and won't appear in generated code. But if
  /// your project involves multiple Swift modules, their names must be unique.
  final String tempModuleName;

  const SwiftFileInput({
    required this.files,
    this.tempModuleName = 'symbolgraph_module',
  });

  @override
  swift2objc.InputConfig? get swift2ObjCConfig =>
      swift2objc.FilesInputConfig(files: files, tempModuleName: tempModuleName);
}

/// A precompiled swift module input.
class SwiftModuleInput implements SwiftGenInput {
  /// The name of the module to generate bindings for.
  final String module;

  const SwiftModuleInput({required this.module});

  @override
  swift2objc.InputConfig? get swift2ObjCConfig =>
      swift2objc.ModuleInputConfig(module: module);

  @override
  Iterable<Uri> get files => const <Uri>[];
}

/// Selected options from [ffigen.FfiGenerator].
class FfiGeneratorOptions {
  /// [ffigen.FfiGenerator.functions]
  final ffigen.Functions functions;

  /// [ffigen.FfiGenerator.structs]
  final ffigen.Structs structs;

  /// [ffigen.FfiGenerator.unions]
  final ffigen.Unions unions;

  /// [ffigen.FfiGenerator.enums]
  final ffigen.Enums enums;

  /// [ffigen.FfiGenerator.unnamedEnums]
  final ffigen.UnnamedEnums unnamedEnums;

  /// [ffigen.FfiGenerator.globals]
  final ffigen.Globals globals;

  /// Configuration for integer types.
  final ffigen.Integers integers;

  /// [ffigen.FfiGenerator.macros]
  final ffigen.Macros macros;

  /// [ffigen.FfiGenerator.typedefs]
  final ffigen.Typedefs typedefs;

  /// [ffigen.FfiGenerator.objectiveC]
  final ffigen.ObjectiveC objectiveC;

  const FfiGeneratorOptions({
    this.functions = ffigen.Functions.excludeAll,
    this.structs = ffigen.Structs.excludeAll,
    this.unions = ffigen.Unions.excludeAll,
    this.enums = ffigen.Enums.excludeAll,
    this.unnamedEnums = ffigen.UnnamedEnums.excludeAll,
    this.globals = ffigen.Globals.excludeAll,
    this.integers = const ffigen.Integers(),
    this.macros = ffigen.Macros.excludeAll,
    this.typedefs = ffigen.Typedefs.excludeAll,
    this.objectiveC = const ffigen.ObjectiveC(),
  });
}
