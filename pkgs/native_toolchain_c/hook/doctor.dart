// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(dcharkes): Remove `hook/doctor.dart` before merging/publishing
// `package:native_toolchain_c`, because `pub publish` will prevent publishing a
// package version with `hook/doctor.dart` until pub is updated.

// ignore_for_file: experimental_member_use

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/src/cbuilder/logger.dart';
import 'package:native_toolchain_c/src/native_toolchain/android_ndk.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/gcc.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/native_toolchain/recognizer.dart';
import 'package:native_toolchain_c/src/native_toolchain/xcode.dart';
import 'package:native_toolchain_c/src/tool/tool.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';

void main(List<String> args) async {
  await doctor(args, (input, output) async {
    final context = ToolResolvingContext(logger: createDefaultLogger());
    final configs = input.config.buildCodeAssets
        ? input.config.code.configs
        : null;
    final validations = await runNativeToolchainCDoctor(
      context: context,
      hostOS: .current,
      configs: configs,
    );
    output.addValidations(validations);
  });
}

/// Runs C toolchain diagnostics for [hostOS] using [context].
///
/// When [configs] is non-empty, only toolchains for the target platforms in
/// [configs] are validated, custom [CCompilerConfig] paths are inspected, and
/// missing required target toolchains are reported as
/// [DoctorValidationType.missing].
Future<List<DoctorValidationResult>> runNativeToolchainCDoctor({
  required ToolResolvingContext context,
  required OS hostOS,
  List<DoctorCodeConfig>? configs,
}) async {
  final hasConfigs = configs != null && configs.isNotEmpty;
  final macosConfigs = configs?.where((c) => c.targetOS == .macOS).toList();
  final iosConfigs = configs?.where((c) => c.targetOS == .iOS).toList();
  final linuxConfigs = configs?.where((c) => c.targetOS == .linux).toList();
  final windowsConfigs = configs?.where((c) => c.targetOS == .windows).toList();
  final androidConfigs = configs?.where((c) => c.targetOS == .android).toList();

  return [
    switch (hostOS) {
      .macOS
          when !hasConfigs ||
              macosConfigs!.isNotEmpty ||
              iosConfigs!.isNotEmpty =>
        await _validateMacOSToolchain(
          context,
          macosConfigs: hasConfigs ? macosConfigs : null,
          iosConfigs: hasConfigs ? iosConfigs : null,
        ),
      .linux when !hasConfigs || linuxConfigs!.isNotEmpty =>
        await _validateLinuxToolchain(
          context,
          linuxConfigs: hasConfigs ? linuxConfigs : null,
        ),
      .windows when !hasConfigs || windowsConfigs!.isNotEmpty =>
        await _validateWindowsToolchain(
          context,
          windowsConfigs: hasConfigs ? windowsConfigs : null,
        ),
      .macOS || .linux || .windows => null,
      _ => DoctorValidationResult(
        title: 'C Toolchain ($hostOS)',
        type: .notAvailable,
        statusInfo: 'unsupported host OS $hostOS',
        messages: [
          DoctorValidationMessage.error(
            'Host OS $hostOS is not supported for compiling C code.',
          ),
        ],
      ),
    },
    if (!hasConfigs || androidConfigs!.isNotEmpty)
      await _validateAndroidNdkToolchain(
        context,
        androidConfigs: hasConfigs ? androidConfigs : null,
        required: hasConfigs,
      ),
  ].nonNulls.toList();
}

Future<DoctorValidationResult> _validateMacOSToolchain(
  ToolResolvingContext context, {
  List<DoctorCodeConfig>? macosConfigs,
  List<DoctorCodeConfig>? iosConfigs,
}) async {
  const title = 'C Toolchain (Apple Clang / Xcode)';
  final configuredCCompiler = [
    ...?macosConfigs,
    ...?iosConfigs,
  ].map((c) => c.cCompiler).nonNulls.firstOrNull;

  final (
    appleClangInstances,
    clangInstances,
    arInstances,
    ldInstances,
    otoolInstances,
    sdkInstances,
  ) = await (
    configuredCCompiler != null
        ? _resolveAll(CompilerRecognizer(configuredCCompiler.compiler), context)
        : _resolveTool(appleClang, context),
    configuredCCompiler != null
        ? Future.value(const <ToolInstance>[])
        : _resolveTool(clang, context),
    configuredCCompiler != null
        ? _resolveAll(ArchiverRecognizer(configuredCCompiler.archiver), context)
        : _resolveTool(appleAr, context),
    configuredCCompiler != null
        ? _resolveAll(LinkerRecognizer(configuredCCompiler.linker), context)
        : _resolveTool(appleLd, context),
    _resolveTool(otool, context),
    _resolveAll(macosxSdk.defaultResolver!, context),
  ).wait;

  final compiler =
      appleClangInstances.firstOrNull ?? clangInstances.firstOrNull;
  final ar = arInstances.firstOrNull;
  final ld = ldInstances.firstOrNull;
  final otoolInstance = otoolInstances.firstOrNull;
  final macosSdkInstance = sdkInstances
      .where((i) => i.tool == macosxSdk)
      .firstOrNull;
  final iosSdkInstance = sdkInstances
      .where((i) => i.tool == iPhoneOSSdk)
      .firstOrNull;
  final iosSimSdkInstance = sdkInstances
      .where((i) => i.tool == iPhoneSimulatorSdk)
      .firstOrNull;

  final messages = <DoctorValidationMessage>[];

  if (compiler == null) {
    messages.addAll([
      if (configuredCCompiler != null)
        DoctorValidationMessage.error(
          'Configured C compiler not found or not recognized at '
          '${configuredCCompiler.compiler.toFilePath()}.',
        )
      else
        DoctorValidationMessage.error(
          'No C compiler (Apple Clang or Clang) found on PATH.',
        ),
      DoctorValidationMessage.hint(
        'Install Xcode or Xcode Command Line Tools (`xcode-select --install`).',
      ),
    ]);
    return DoctorValidationResult(
      title: title,
      type: .missing,
      statusInfo: 'not installed',
      messages: messages,
    );
  }

  messages.add(DoctorValidationMessage(_formatToolInstance(compiler)));

  var hasMissingHostTool = false;
  if (ar != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(ar)));
  } else {
    hasMissingHostTool = true;
    messages.add(
      DoctorValidationMessage.error(
        configuredCCompiler != null
            ? 'Configured archiver not found or not recognized at '
                  '${configuredCCompiler.archiver.toFilePath()}.'
            : 'Apple archiver (ar) not found.',
      ),
    );
  }

  if (ld != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(ld)));
  } else {
    hasMissingHostTool = true;
    messages.add(
      DoctorValidationMessage.error(
        configuredCCompiler != null
            ? 'Configured linker not found or not recognized at '
                  '${configuredCCompiler.linker.toFilePath()}.'
            : 'Apple linker (ld) not found.',
      ),
    );
  }

  if (otoolInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(otoolInstance)));
  }

  final targetsMacOS = macosConfigs == null || macosConfigs.isNotEmpty;
  if (macosSdkInstance != null) {
    messages.add(
      DoctorValidationMessage(_formatToolInstance(macosSdkInstance)),
    );
  } else if (targetsMacOS) {
    hasMissingHostTool = true;
    messages.add(
      DoctorValidationMessage.error('MacOSX SDK not found via xcrun.'),
    );
  }

  final targetsIOS = iosConfigs == null || iosConfigs.isNotEmpty;
  final targetsIOSDevice =
      iosConfigs == null || iosConfigs.any((c) => c.iOS.targetSdk == .iPhoneOS);
  final targetsIOSSim =
      iosConfigs == null ||
      iosConfigs.any((c) => c.iOS.targetSdk == .iPhoneSimulator);

  if (iosSdkInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(iosSdkInstance)));
  }
  if (iosSimSdkInstance != null) {
    messages.add(
      DoctorValidationMessage(_formatToolInstance(iosSimSdkInstance)),
    );
  }

  final missingRequiredIosSdk =
      targetsIOS &&
      ((targetsIOSDevice && iosSdkInstance == null) ||
          (targetsIOSSim && iosSimSdkInstance == null));
  if (missingRequiredIosSdk) {
    if (iosConfigs != null) {
      messages.add(
        DoctorValidationMessage.error(
          'iPhoneOS / iPhoneSimulator SDKs not found.',
        ),
      );
    }
    messages.add(
      DoctorValidationMessage.hint(
        'iPhoneOS / iPhoneSimulator SDKs not found. Install full Xcode if '
        'building for iOS.',
      ),
    );
  }

  final compilerVersion = compiler.version != null
      ? '${compiler.tool.name} ${compiler.version}'
      : compiler.tool.name;

  if (hasMissingHostTool) {
    return DoctorValidationResult(
      title: title,
      type: .partial,
      statusInfo: '$compilerVersion (missing host tools/SDK)',
      messages: messages,
    );
  }

  if (missingRequiredIosSdk) {
    return DoctorValidationResult(
      title: title,
      type: !targetsMacOS ? .missing : .partial,
      statusInfo: !targetsMacOS
          ? '$compilerVersion (missing iOS SDK)'
          : '$compilerVersion (macOS only)',
      messages: messages,
    );
  }

  return DoctorValidationResult(
    title: title,
    type: .success,
    statusInfo: compilerVersion,
    messages: messages,
  );
}

Future<DoctorValidationResult> _validateLinuxToolchain(
  ToolResolvingContext context, {
  List<DoctorCodeConfig>? linuxConfigs,
}) async {
  const title = 'C Toolchain (Clang / GCC)';
  final configuredCCompiler = linuxConfigs
      ?.map((c) => c.cCompiler)
      .nonNulls
      .firstOrNull;
  final (clangInstances, arInstances, lldInstances, gccInstances) = await (
    configuredCCompiler != null
        ? _resolveAll(CompilerRecognizer(configuredCCompiler.compiler), context)
        : _resolveTool(clang, context),
    configuredCCompiler != null
        ? _resolveAll(ArchiverRecognizer(configuredCCompiler.archiver), context)
        : _resolveTool(llvmAr, context),
    configuredCCompiler != null
        ? _resolveAll(LinkerRecognizer(configuredCCompiler.linker), context)
        : _resolveTool(lld, context),
    configuredCCompiler != null
        ? Future.value(const <ToolInstance>[])
        : _resolveTool(gcc, context),
  ).wait;

  final clangInstance = clangInstances.firstOrNull;
  final arInstance = arInstances.firstOrNull;
  final lldInstance = lldInstances.firstOrNull;
  final gccInstance = gccInstances.firstOrNull;

  final messages = <DoctorValidationMessage>[];

  if (clangInstance == null && gccInstance == null) {
    return DoctorValidationResult(
      title: title,
      type: .missing,
      statusInfo: 'not installed',
      messages: [
        if (configuredCCompiler != null)
          DoctorValidationMessage.error(
            'Configured C compiler not found or not recognized at '
            '${configuredCCompiler.compiler.toFilePath()}.',
          )
        else
          DoctorValidationMessage.error(
            'Neither Clang nor GCC was found on PATH.',
          ),
        DoctorValidationMessage.hint(
          'Install clang, llvm, and lld '
          '(e.g., `sudo apt install clang llvm lld`).',
        ),
      ],
    );
  }

  if (clangInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(clangInstance)));
  } else {
    messages.add(DoctorValidationMessage.error('Clang not found on PATH.'));
  }

  if (arInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(arInstance)));
  } else {
    messages.add(
      DoctorValidationMessage.error(
        configuredCCompiler != null
            ? 'Configured archiver not found or not recognized at '
                  '${configuredCCompiler.archiver.toFilePath()}.'
            : 'LLVM archiver (llvm-ar) not found.',
      ),
    );
  }

  if (lldInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(lldInstance)));
  } else {
    messages.add(
      DoctorValidationMessage.error(
        configuredCCompiler != null
            ? 'Configured linker not found or not recognized at '
                  '${configuredCCompiler.linker.toFilePath()}.'
            : 'LLVM linker (ld.lld) not found.',
      ),
    );
  }

  if (gccInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(gccInstance)));
  }

  if (clangInstance != null && arInstance != null && lldInstance != null) {
    final versionInfo = clangInstance.version != null
        ? '${clangInstance.tool.name} ${clangInstance.version}'
        : clangInstance.tool.name;
    return DoctorValidationResult(
      title: title,
      type: .success,
      statusInfo: versionInfo,
      messages: messages,
    );
  }

  messages.add(
    DoctorValidationMessage.hint(
      'Install clang, llvm, and lld (e.g., `sudo apt install clang llvm lld`).',
    ),
  );
  return DoctorValidationResult(
    title: title,
    type: .partial,
    statusInfo: 'missing LLVM tools',
    messages: messages,
  );
}

Future<DoctorValidationResult> _validateWindowsToolchain(
  ToolResolvingContext context, {
  List<DoctorCodeConfig>? windowsConfigs,
}) async {
  const title = 'C Toolchain (Visual Studio / MSVC)';
  final configuredCCompiler = windowsConfigs
      ?.map((c) => c.cCompiler)
      .nonNulls
      .firstOrNull;
  final (
    vswhereInstances,
    vsX64Instances,
    clInstances,
    libInstances,
    linkInstances,
    clangInstances,
  ) = await (
    _resolveTool(vswhere, context),
    _resolveTool(visualStudioX64, context),
    configuredCCompiler != null
        ? _resolveAll(CompilerRecognizer(configuredCCompiler.compiler), context)
        : _resolveTool(cl, context),
    configuredCCompiler != null
        ? _resolveAll(ArchiverRecognizer(configuredCCompiler.archiver), context)
        : _resolveTool(lib, context),
    configuredCCompiler != null
        ? _resolveAll(LinkerRecognizer(configuredCCompiler.linker), context)
        : _resolveTool(msvcLink, context),
    configuredCCompiler != null
        ? Future.value(const <ToolInstance>[])
        : _resolveTool(clang, context),
  ).wait;

  final vsInstance = vsX64Instances.firstOrNull;
  final clInstance = clInstances.firstOrNull;
  final libInstance = libInstances.firstOrNull;
  final linkInstance = linkInstances.firstOrNull;
  final clangInstance = clangInstances.firstOrNull;

  final messages = <DoctorValidationMessage>[];

  if (vsInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(vsInstance)));
  }
  if (clInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(clInstance)));
  }
  if (libInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(libInstance)));
  }
  if (linkInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(linkInstance)));
  }
  if (clangInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(clangInstance)));
  }

  if (clInstance != null && libInstance != null && linkInstance != null) {
    final version = clInstance.version ?? vsInstance?.version;
    return DoctorValidationResult(
      title: title,
      type: .success,
      statusInfo: version != null ? 'MSVC $version' : 'MSVC',
      messages: messages,
    );
  }

  if (configuredCCompiler != null && clInstance == null) {
    messages.add(
      DoctorValidationMessage.error(
        'Configured C compiler not found or not recognized at '
        '${configuredCCompiler.compiler.toFilePath()}.',
      ),
    );
  } else if (vswhereInstances.isNotEmpty && vsInstance == null) {
    messages.add(
      DoctorValidationMessage.error(
        'Visual Studio Locator found, but no Visual Studio installation has '
        'the Microsoft.VisualStudio.Component.VC.Tools.x86.x64 component.',
      ),
    );
  } else if (clInstance == null) {
    messages.add(
      DoctorValidationMessage.error('MSVC compiler (cl.exe) not found.'),
    );
  }

  messages.add(
    DoctorValidationMessage.hint(
      'Install Visual Studio with the "Desktop development with C++" workload.',
    ),
  );

  return DoctorValidationResult(
    title: title,
    type: clangInstance != null ? .partial : .missing,
    statusInfo: clangInstance != null ? 'Clang only (MSVC missing)' : 'missing',
    messages: messages,
  );
}

Future<DoctorValidationResult> _validateAndroidNdkToolchain(
  ToolResolvingContext context, {
  List<DoctorCodeConfig>? androidConfigs,
  bool required = false,
}) async {
  const title = 'Android NDK C Toolchain';
  final configuredCCompiler = androidConfigs
      ?.map((c) => c.cCompiler)
      .nonNulls
      .firstOrNull;
  if (configuredCCompiler != null) {
    final (clangInstances, arInstances, lldInstances) = await (
      _resolveAll(CompilerRecognizer(configuredCCompiler.compiler), context),
      _resolveAll(ArchiverRecognizer(configuredCCompiler.archiver), context),
      _resolveAll(LinkerRecognizer(configuredCCompiler.linker), context),
    ).wait;
    final clangInstance = clangInstances.firstOrNull;
    final arInstance = arInstances.firstOrNull;
    final lldInstance = lldInstances.firstOrNull;
    final messages = <DoctorValidationMessage>[
      if (clangInstance != null)
        DoctorValidationMessage(_formatToolInstance(clangInstance))
      else
        DoctorValidationMessage.error(
          'Configured Android C compiler not found or not recognized at '
          '${configuredCCompiler.compiler.toFilePath()}.',
        ),
      if (arInstance != null)
        DoctorValidationMessage(_formatToolInstance(arInstance))
      else
        DoctorValidationMessage.error(
          'Configured Android archiver not found or not recognized at '
          '${configuredCCompiler.archiver.toFilePath()}.',
        ),
      if (lldInstance != null)
        DoctorValidationMessage(_formatToolInstance(lldInstance))
      else
        DoctorValidationMessage.error(
          'Configured Android linker not found or not recognized at '
          '${configuredCCompiler.linker.toFilePath()}.',
        ),
    ];
    if (clangInstance != null && arInstance != null && lldInstance != null) {
      final version = clangInstance.version != null
          ? '${clangInstance.tool.name} ${clangInstance.version}'
          : clangInstance.tool.name;
      return DoctorValidationResult(
        title: title,
        type: .success,
        statusInfo: version,
        messages: messages,
      );
    }
    return DoctorValidationResult(
      title: title,
      type: clangInstance == null && arInstance == null && lldInstance == null
          ? .missing
          : .partial,
      statusInfo: 'configured compiler missing/invalid',
      messages: messages,
    );
  }

  final resolved = await _resolveAll(androidNdk.defaultResolver!, context);
  final ndkInstances = resolved.where((i) => i.tool == androidNdk).toList()
    ..sort();
  final clangInstances =
      resolved.where((i) => i.tool == androidNdkClang).toList()..sort();
  final arInstances = resolved.where((i) => i.tool == androidNdkLlvmAr).toList()
    ..sort();
  final lldInstances = resolved.where((i) => i.tool == androidNdkLld).toList()
    ..sort();

  final ndk = ndkInstances.firstOrNull;
  if (ndk == null) {
    return DoctorValidationResult(
      title: title,
      type: required ? .missing : .notAvailable,
      statusInfo: required
          ? 'not installed'
          : 'not installed (optional unless targeting Android)',
      messages: [
        if (required)
          DoctorValidationMessage.error('Android NDK not found.')
        else
          DoctorValidationMessage('Android NDK not found.'),
        DoctorValidationMessage.hint(
          'Install the Android NDK via Android Studio SDK Manager or set '
          'ANDROID_NDK_HOME if targeting Android.',
        ),
      ],
    );
  }

  final clangInstance = clangInstances.firstOrNull;
  final arInstance = arInstances.firstOrNull;
  final lldInstance = lldInstances.firstOrNull;

  final messages = <DoctorValidationMessage>[
    DoctorValidationMessage(_formatToolInstance(ndk)),
    if (clangInstance != null)
      DoctorValidationMessage(_formatToolInstance(clangInstance))
    else
      DoctorValidationMessage.error('Android NDK clang not found.'),
    if (arInstance != null)
      DoctorValidationMessage(_formatToolInstance(arInstance))
    else
      DoctorValidationMessage.error('Android NDK llvm-ar not found.'),
    if (lldInstance != null)
      DoctorValidationMessage(_formatToolInstance(lldInstance))
    else
      DoctorValidationMessage.error('Android NDK ld.lld not found.'),
  ];

  final ndkVersion = ndk.version != null ? 'NDK ${ndk.version}' : 'Android NDK';
  if (clangInstance != null && arInstance != null && lldInstance != null) {
    return DoctorValidationResult(
      title: title,
      type: .success,
      statusInfo: ndkVersion,
      messages: messages,
    );
  }

  return DoctorValidationResult(
    title: title,
    type: .partial,
    statusInfo: '$ndkVersion (missing LLVM tools)',
    messages: messages,
  );
}

Future<List<ToolInstance>> _resolveTool(
  Tool tool,
  ToolResolvingContext context,
) async {
  final resolver = tool.defaultResolver;
  if (resolver == null) return const [];
  final resolved = await _resolveAll(resolver, context);
  return resolved.where((i) => i.tool == tool).toList()..sort();
}

Future<List<ToolInstance>> _resolveAll(
  ToolResolver resolver,
  ToolResolvingContext context,
) async {
  try {
    return await resolver.resolve(context);
  } on Object {
    return const [];
  }
}

String _formatToolInstance(ToolInstance instance) {
  final version = instance.version != null ? ' ${instance.version}' : '';
  return '${instance.tool.name}$version at ${instance.uri.toFilePath()}';
}
