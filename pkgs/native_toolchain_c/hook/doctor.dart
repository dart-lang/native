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
import 'package:native_toolchain_c/src/native_toolchain/xcode.dart';
import 'package:native_toolchain_c/src/tool/tool.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';

void main(List<String> args) async {
  await doctor(args, (input, output) async {
    final context = ToolResolvingContext(logger: createDefaultLogger());
    final validations = await runNativeToolchainCDoctor(
      context: context,
      hostOS: .current,
    );
    output.addValidations(validations);
  });
}

/// Runs C toolchain diagnostics for [hostOS] using [context].
// TODO(dcharkes): Once `DoctorInput` supports protocol extensions (such as
// `CodeAssetExtension`), inspect `cCompiler` configuration from the input to
// validate custom compiler/archiver/linker paths provided by the runner.
// TODO(dcharkes): Once `DoctorInput` provides the enabled target platforms,
// only validate toolchains for the enabled target OS/architectures, and report
// `DoctorValidationType.missing` when a required target toolchain (such as the
// Android NDK or iOS SDK) is not installed.
Future<List<DoctorValidationResult>> runNativeToolchainCDoctor({
  required ToolResolvingContext context,
  required OS hostOS,
}) async => [
  switch (hostOS) {
    .macOS => await _validateMacOSToolchain(context),
    .linux => await _validateLinuxToolchain(context),
    .windows => await _validateWindowsToolchain(context),
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
  await _validateAndroidNdkToolchain(context),
];

Future<DoctorValidationResult> _validateMacOSToolchain(
  ToolResolvingContext context,
) async {
  const title = 'C Toolchain (Apple Clang / Xcode)';
  final (
    appleClangInstances,
    clangInstances,
    arInstances,
    ldInstances,
    otoolInstances,
    sdkInstances,
  ) = await (
    _resolveTool(appleClang, context),
    _resolveTool(clang, context),
    _resolveTool(appleAr, context),
    _resolveTool(appleLd, context),
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
      DoctorValidationMessage.error('Apple archiver (ar) not found.'),
    );
  }

  if (ld != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(ld)));
  } else {
    hasMissingHostTool = true;
    messages.add(DoctorValidationMessage.error('Apple linker (ld) not found.'));
  }

  if (otoolInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(otoolInstance)));
  }

  if (macosSdkInstance != null) {
    messages.add(
      DoctorValidationMessage(_formatToolInstance(macosSdkInstance)),
    );
  } else {
    hasMissingHostTool = true;
    messages.add(
      DoctorValidationMessage.error('MacOSX SDK not found via xcrun.'),
    );
  }

  final hasIosSdks = iosSdkInstance != null && iosSimSdkInstance != null;
  if (iosSdkInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(iosSdkInstance)));
  }
  if (iosSimSdkInstance != null) {
    messages.add(
      DoctorValidationMessage(_formatToolInstance(iosSimSdkInstance)),
    );
  }
  if (!hasIosSdks) {
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

  if (!hasIosSdks) {
    return DoctorValidationResult(
      title: title,
      type: .partial,
      statusInfo: '$compilerVersion (macOS only)',
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
  ToolResolvingContext context,
) async {
  const title = 'C Toolchain (Clang / GCC)';
  final (clangInstances, arInstances, lldInstances, gccInstances) = await (
    _resolveTool(clang, context),
    _resolveTool(llvmAr, context),
    _resolveTool(lld, context),
    _resolveTool(gcc, context),
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
      DoctorValidationMessage.error('LLVM archiver (llvm-ar) not found.'),
    );
  }

  if (lldInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(lldInstance)));
  } else {
    messages.add(
      DoctorValidationMessage.error('LLVM linker (ld.lld) not found.'),
    );
  }

  if (gccInstance != null) {
    messages.add(DoctorValidationMessage(_formatToolInstance(gccInstance)));
  }

  if (clangInstance != null && arInstance != null && lldInstance != null) {
    final versionInfo = clangInstance.version != null
        ? 'Clang ${clangInstance.version}'
        : 'Clang';
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
  ToolResolvingContext context,
) async {
  const title = 'C Toolchain (Visual Studio / MSVC)';
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
    _resolveTool(cl, context),
    _resolveTool(lib, context),
    _resolveTool(msvcLink, context),
    _resolveTool(clang, context),
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

  if (vswhereInstances.isNotEmpty && vsInstance == null) {
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
  ToolResolvingContext context,
) async {
  const title = 'Android NDK C Toolchain';
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
      type: .notAvailable,
      statusInfo: 'not installed (optional unless targeting Android)',
      messages: [
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
