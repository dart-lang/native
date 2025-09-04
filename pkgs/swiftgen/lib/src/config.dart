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
  final Target target;
  final List<SwiftGenInput> inputs;
  final bool Function(swift2objc.Declaration declaration)? include;

  final FfiGeneratorOptions ffigen;

  const SwiftGenerator({
    required this.target,
    required this.inputs,
    this.include,
    this.objcSwiftPreamble,
    required this.objcSwiftFile,
    required this.outputModule,
    required this.ffigen,
  });
}

class Output {
  final SwiftWrapperFile? wrapperFile;
  final String outputModule;
}

class SwiftWrapperFile {
  final Uri path;
  final String? preamble;

  const SwiftWrapperFile({this.path, this.preamble});
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
    triple: await swift2objc.hostTarget,
    sdk: await swift2objc.hostSdk,
  );

  /// Returns the [Target] for the latest iOS varsion on arm.
  static Future<Target> iOSArmLatest() async =>
    Target(await iOSArmTargetTripleLatest, await iOSSdk);

  /// Returns the [Target] for the latest iOS varsion on arm64.
  static Future<Target> iOSArm64Latest() async =>
    Target(await iOSArm64TargetTripleLatest, await iOSSdk);

  /// Returns the [Target] for the latest iOS varsion on x64.
  static Future<Target> iOSX64Latest() async =>
    Target(await iOSX64TargetTripleLatest, await iOSSdk);

  /// Returns the [Target] for the latest macOS varsion on arm64.
  static Future<Target> macOSArm64Latest() async =>
    Target(await macOSArm64TargetTripleLatest, await macOSSdk);

  /// Returns the [Target] for the latest macOS varsion on x64.
  static Future<Target> macOSX64Latest() async =>
    Target(await macOSX64TargetTripleLatest, await macOSSdk);
}

/// Describes the inputs to the swiftgen pipeline.
abstract interface class SwiftGenInput {
  swift2objc.InputConfig? get swift2ObjCConfig;
  Iterable<Uri> get files;
}

/// Input swift files that are already annotated with @objc.
class ObjCCompatibleSwiftFileInput implements SwiftGenInput {
  @override
  final List<Uri> files;

  @override
  swift2objc.InputConfig? get swift2ObjCConfig => null;

  const ObjCCompatibleSwiftFileInput({required this.files});
}

/// Input swift files that are not necessarily Objective C compatible.
class SwiftFileInput implements SwiftGenInput {
  final String module;

  @override
  final List<Uri> files;

  const SwiftFileInput({required this.module, required this.files});

  @override
  swift2objc.InputConfig? get swift2ObjCConfig =>
      swift2objc.FilesInputConfig(files: files, generatedModuleName: module);
}

/// A precompiled swift module input.
class SwiftModuleInput implements SwiftGenInput {
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
  /// [ffigen.FfiGenerator.output]
  final Uri output;

  final Uri outputObjC;

  final String? wrapperName;

  final String? wrapperDocComment;

  final String? preamble;

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

  /// Objective-C specific configuration.
  final ffigen.ObjectiveC objectiveC;

  const FfiGeneratorOptions({
    required this.output,
    required this.outputObjC,
    this.wrapperName,
    this.wrapperDocComment,
    this.preamble,
    this.enums = ffigen.Enums.excludeAll,
    this.functions = ffigen.Functions.excludeAll,
    this.globals = ffigen.Globals.excludeAll,
    this.integers = const ffigen.Integers(),
    this.macros = ffigen.Macros.excludeAll,
    this.structs = ffigen.Structs.excludeAll,
    this.typedefs = ffigen.Typedefs.excludeAll,
    this.unions = ffigen.Unions.excludeAll,
    this.unnamedEnums = ffigen.UnnamedEnums.excludeAll,
    this.objectiveC = const ffigen.ObjectiveC(),
  });
}
