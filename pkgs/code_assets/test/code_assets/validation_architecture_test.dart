// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:code_assets/code_assets.dart';
import 'package:code_assets/src/code_assets/validation.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  late Uri tempUri;
  late Uri outDirUri;
  late Uri outDirSharedUri;
  late String packageName;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    outDirUri = tempUri.resolve('out/');
    await Directory.fromUri(outDirUri).create();
    outDirSharedUri = tempUri.resolve('out_shared/');
    await Directory.fromUri(outDirSharedUri).create();
    packageName = 'my_package';
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  BuildInput makeCodeBuildInput({
    required OS targetOS,
    required Architecture targetArchitecture,
    LinkModePreference linkModePreference = LinkModePreference.dynamic,
  }) {
    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: outDirSharedUri,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(
        CodeAssetExtension(
          targetOS: targetOS,
          targetArchitecture: targetArchitecture,
          linkModePreference: linkModePreference,
        ),
      );
    return inputBuilder.build();
  }

  Future<(ValidationErrors, List<LogRecord>)> validate(
    List<int> fileBytes, {
    required OS targetOS,
    required Architecture targetArchitecture,
    LinkMode? linkMode,
    LinkModePreference linkModePreference = LinkModePreference.dynamic,
  }) async {
    final input = makeCodeBuildInput(
      targetOS: targetOS,
      targetArchitecture: targetArchitecture,
      linkModePreference: linkModePreference,
    );
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes(fileBytes);
    final outputBuilder = BuildOutputBuilder();
    outputBuilder.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'foo.dart',
        file: assetFile.uri,
        linkMode: linkMode ?? DynamicLoadingBundled(),
      ),
    );
    final records = <LogRecord>[];
    final logger = Logger.detached('test')
      ..level = Level.ALL
      ..onRecord.listen(records.add);
    final errors = await validateCodeAssetBuildOutput(
      input,
      outputBuilder.build(),
      logger: logger,
    );
    return (errors, records);
  }

  group('ELF', () {
    test('matching architecture is clean', () async {
      final (errors, records) = await validate(
        elfHeader(machine: 183),
        targetOS: OS.linux,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, isEmpty);
      expect(records, isEmpty);
    });

    test('mismatched architecture is an error', () async {
      final (errors, _) = await validate(
        elfHeader(machine: 62),
        targetOS: OS.android,
        targetArchitecture: Architecture.arm64,
      );
      expect(
        errors,
        contains(contains('is built for x64, but the target architecture')),
      );
    });

    test('big-endian machine field is read correctly', () async {
      final (errors, _) = await validate(
        elfHeader(machine: 183, littleEndian: false),
        targetOS: OS.linux,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, isEmpty);
    });

    test('riscv width comes from the ELF class', () async {
      final (errors64, _) = await validate(
        elfHeader(machine: 243),
        targetOS: OS.linux,
        targetArchitecture: Architecture.riscv64,
      );
      expect(errors64, isEmpty);
      final (errors32, _) = await validate(
        elfHeader(machine: 243, is64: false),
        targetOS: OS.linux,
        targetArchitecture: Architecture.riscv64,
      );
      expect(errors32, contains(contains('is built for riscv32')));
    });

    test('unknown machine value only warns', () async {
      final (errors, records) = await validate(
        elfHeader(machine: 0x1234),
        targetOS: OS.linux,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, isEmpty);
      expect(records, hasLength(1));
      expect(records.single.message, contains('0x1234'));
      expect(records.single.message, contains('file an issue'));
    });
  });

  group('Mach-O', () {
    test('thin arm64 matches macOS arm64', () async {
      final (errors, records) = await validate(
        machOHeader(cpuType: 0x0100000c),
        targetOS: OS.macOS,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, isEmpty);
      expect(records, isEmpty);
    });

    test('thin x64 mismatches macOS arm64', () async {
      final (errors, _) = await validate(
        machOHeader(cpuType: 0x01000007),
        targetOS: OS.macOS,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, contains(contains('is built for x64')));
    });

    test('big-endian written header is read correctly', () async {
      final (errors, _) = await validate(
        machOHeader(cpuType: 0x0100000c, littleEndian: false),
        targetOS: OS.iOS,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, isEmpty);
    });

    test('multi-architecture file containing the target is an error', () async {
      final (errors, _) = await validate(
        machOFatHeader(cpuTypes: [0x01000007, 0x0100000c]),
        targetOS: OS.macOS,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, contains(contains('multi-architecture Mach-O')));
    });

    test('fat file without the target architecture is an error', () async {
      final (errors, _) = await validate(
        machOFatHeader(cpuTypes: [0x01000007]),
        targetOS: OS.macOS,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, contains(contains('is built for x64')));
    });
  });

  group('PE', () {
    test('x64 matches windows x64', () async {
      final (errors, records) = await validate(
        peFile(machine: 0x8664),
        targetOS: OS.windows,
        targetArchitecture: Architecture.x64,
      );
      expect(errors, isEmpty);
      expect(records, isEmpty);
    });

    test('arm64 mismatches windows x64', () async {
      final (errors, _) = await validate(
        peFile(machine: 0xaa64),
        targetOS: OS.windows,
        targetArchitecture: Architecture.x64,
      );
      expect(errors, contains(contains('is built for arm64')));
    });
  });

  group('format and OS', () {
    test('an ELF file for a macOS target only warns', () async {
      final (errors, records) = await validate(
        elfHeader(machine: 183),
        targetOS: OS.macOS,
        targetArchitecture: Architecture.arm64,
      );
      expect(errors, isEmpty);
      expect(records, hasLength(1));
      expect(records.single.level, Level.WARNING);
    });

    test('a Mach-O file for a windows target only warns', () async {
      final (errors, records) = await validate(
        machOHeader(cpuType: 0x01000007),
        targetOS: OS.windows,
        targetArchitecture: Architecture.x64,
      );
      expect(errors, isEmpty);
      expect(records, hasLength(1));
      expect(records.single.level, Level.WARNING);
    });
  });

  group('unrecognized files', () {
    for (final (name, bytes) in [
      ('garbage', [1, 2, 3]),
      ('empty', <int>[]),
      ('truncated ELF magic', [0x7f, 0x45, 0x4c, 0x46]),
    ]) {
      test('$name only warns', () async {
        final (errors, records) = await validate(
          bytes,
          targetOS: OS.linux,
          targetArchitecture: Architecture.arm64,
        );
        expect(errors, isEmpty);
        expect(records, hasLength(1));
        expect(records.single.level, Level.WARNING);
        expect(records.single.message, contains('file an issue'));
      });
    }

    test('a PE offset past the end of the file only warns', () async {
      final bytes = peFile(machine: 0x8664);
      bytes.buffer.asByteData().setUint32(0x3c, 0x4000, Endian.little);
      final (errors, records) = await validate(
        bytes,
        targetOS: OS.windows,
        targetArchitecture: Architecture.x64,
      );
      expect(errors, isEmpty);
      expect(records, hasLength(1));
    });

    test('without a logger a mismatch still errors', () async {
      final input = makeCodeBuildInput(
        targetOS: OS.linux,
        targetArchitecture: Architecture.arm64,
      );
      final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
      await assetFile.writeAsBytes(elfHeader(machine: 62));
      final outputBuilder = BuildOutputBuilder();
      outputBuilder.assets.code.add(
        CodeAsset(
          package: input.packageName,
          name: 'foo.dart',
          file: assetFile.uri,
          linkMode: DynamicLoadingBundled(),
        ),
      );
      final errors = await validateCodeAssetBuildOutput(
        input,
        outputBuilder.build(),
      );
      expect(errors, contains(contains('is built for x64')));
    });
  });

  group('link modes', () {
    test('non-bundled dynamic loading is not checked', () async {
      final (errors, records) = await validate(
        elfHeader(machine: 62),
        targetOS: OS.linux,
        targetArchitecture: Architecture.arm64,
        linkMode: DynamicLoadingSystem(Uri.file('libfoo.so')),
      );
      expect(errors, isEmpty);
      expect(records, isEmpty);
    });

    test('static archives are not checked', () async {
      final (errors, records) = await validate(
        '!<arch>\n'.codeUnits,
        targetOS: OS.linux,
        targetArchitecture: Architecture.arm64,
        linkMode: StaticLinking(),
        linkModePreference: LinkModePreference.static,
      );
      expect(errors, isEmpty);
      expect(records, isEmpty);
    });
  });
}

/// A minimal 64-byte ELF header with [machine] at offset 0x12.
Uint8List elfHeader({
  required int machine,
  bool is64 = true,
  bool littleEndian = true,
}) {
  final bytes = Uint8List(64);
  bytes.setAll(0, [0x7f, 0x45, 0x4c, 0x46]);
  bytes[4] = is64 ? 2 : 1;
  bytes[5] = littleEndian ? 1 : 2;
  bytes.buffer.asByteData().setUint16(
    18,
    machine,
    littleEndian ? Endian.little : Endian.big,
  );
  return bytes;
}

/// A minimal 32-byte thin Mach-O header with [cpuType] after the magic.
Uint8List machOHeader({required int cpuType, bool littleEndian = true}) {
  final bytes = Uint8List(32);
  final data = bytes.buffer.asByteData();
  final endian = littleEndian ? Endian.little : Endian.big;
  data.setUint32(0, 0xfeedfacf, endian);
  data.setUint32(4, cpuType, endian);
  return bytes;
}

/// A minimal big-endian fat Mach-O header with one slice per cpu type.
Uint8List machOFatHeader({required List<int> cpuTypes}) {
  final bytes = Uint8List(8 + cpuTypes.length * 20);
  final data = bytes.buffer.asByteData();
  data.setUint32(0, 0xcafebabe);
  data.setUint32(4, cpuTypes.length);
  for (var slice = 0; slice < cpuTypes.length; slice++) {
    data.setUint32(8 + slice * 20, cpuTypes[slice]);
  }
  return bytes;
}

/// A minimal PE file: DOS header pointing at a `PE\0\0` signature and COFF
/// [machine].
Uint8List peFile({required int machine}) {
  final bytes = Uint8List(0x48);
  bytes[0] = 0x4d;
  bytes[1] = 0x5a;
  final data = bytes.buffer.asByteData();
  data.setUint32(0x3c, 0x40, Endian.little);
  bytes.setAll(0x40, [0x50, 0x45, 0x00, 0x00]);
  data.setUint16(0x44, machine, Endian.little);
  return bytes;
}
