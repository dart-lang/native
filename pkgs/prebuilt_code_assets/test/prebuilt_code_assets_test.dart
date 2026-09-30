// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart' show LinkerOptions;
import 'package:prebuilt_code_assets/prebuilt_code_assets.dart';
import 'package:prebuilt_code_assets/src/coff_archive.dart';
import 'package:prebuilt_code_assets/tools.dart';
import 'package:record_use/record_use.dart' as record_use;
import 'package:test/test.dart';

void main() {
  group('targets', () {
    test('targetTripleFor disambiguates iOS device and simulator', () {
      expect(targetTripleFor(OS.linux, Architecture.x64), 'linux-x64');
      expect(
        targetTripleFor(OS.iOS, Architecture.arm64, iosSdk: IOSSdk.iPhoneOS),
        'ios-arm64-iphoneos',
      );
      expect(
        targetTripleFor(
          OS.iOS,
          Architecture.arm64,
          iosSdk: IOSSdk.iPhoneSimulator,
        ),
        'ios-arm64-iphonesimulator',
      );
    });

    test(
      'targetTripleFor produces unique identifiers for supportedTargets',
      () {
        final triples = [
          for (final (os, arch, iosSdk) in supportedTargets)
            targetTripleFor(os, arch, iosSdk: iosSdk),
        ];
        expect(triples.toSet(), hasLength(supportedTargets.length));
      },
    );
  });

  group('BuildOptions', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('build_options_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    HookInputUserDefines defines(Map<String, Object?> userDefines) =>
        (BuildInputBuilder()
              ..setupShared(
                packageRoot: tempDir.uri,
                packageName: 'example_pkg',
                outputFile: tempDir.uri.resolve('output.json'),
                outputDirectoryShared: tempDir.uri.resolve('shared/'),
                userDefines: PackageUserDefines(
                  workspacePubspec: PackageUserDefinesSource(
                    defines: userDefines,
                    basePath: tempDir.uri,
                  ),
                ),
              )
              ..config.setupBuild(linkingEnabled: false))
            .build()
            .userDefines;

    BuildOptions parse(
      Map<String, Object?> userDefines, {
      bool strict = true,
    }) => BuildOptions.fromDefines(
      defines(userDefines),
      packageName: 'example_pkg',
      strict: strict,
    );

    test('defaults to fetch mode and treeshake: auto', () {
      final options = parse({});
      expect(options.buildMode, NativeBuildMode.fetch);
      expect(options.treeshake, TreeshakeMode.auto);
      expect(options.localPath, isNull);
      expect(options.checkoutPath, isNull);
    });

    test('parses treeshake on/off/auto and boolean values', () {
      expect(parse({'treeshake': 'on'}).treeshake, TreeshakeMode.on);
      expect(parse({'treeshake': 'off'}).treeshake, TreeshakeMode.off);
      expect(parse({'treeshake': 'auto'}).treeshake, TreeshakeMode.auto);
      expect(parse({'treeshake': 'TRUE'}).treeshake, TreeshakeMode.on);
      expect(parse({'treeshake': true}).treeshake, TreeshakeMode.on);
      expect(parse({'treeshake': false}).treeshake, TreeshakeMode.off);
    });

    test('accepts `checkout` as an alias for `build`', () {
      expect(parse({'buildMode': 'checkout'}).buildMode, NativeBuildMode.build);
    });

    test('supports the local_build boolean user-define', () {
      expect(parse({'local_build': true}).buildMode, NativeBuildMode.build);
      expect(parse({'local_build': false}).buildMode, NativeBuildMode.fetch);
      expect(
        parse({'local_build': true, 'buildMode': 'local'}).buildMode,
        NativeBuildMode.local,
        reason: 'buildMode takes precedence over local_build',
      );
    });

    test('resolves paths relative to the defining pubspec', () {
      final options = parse({
        'buildMode': 'local',
        'localPath': 'libs/libfoo.so',
        'checkoutPath': 'src/',
      });
      expect(options.localPath, tempDir.uri.resolve('libs/libfoo.so'));
      expect(options.checkoutPath, tempDir.uri.resolve('src/'));
    });

    test('throws on unknown values by default', () {
      expect(
        () => parse({'buildMode': 'biuld'}),
        throwsA(
          isA<BuildError>().having(
            (e) => e.message,
            'message',
            allOf(contains('"biuld"'), contains('example_pkg:')),
          ),
        ),
      );
      expect(() => parse({'treeshake': 'maybe'}), throwsA(isA<BuildError>()));
    });

    test('falls back to defaults for unknown values when not strict', () {
      final options = parse({
        'buildMode': 'biuld',
        'treeshake': 'maybe',
      }, strict: false);
      expect(options.buildMode, NativeBuildMode.fetch);
      expect(options.treeshake, TreeshakeMode.auto);
    });

    test('throws BuildError (not TypeError) for wrongly typed values', () {
      for (final bad in <Map<String, Object?>>[
        {'buildMode': 1},
        {'local_build': 'yes'},
        {'treeshake': 3},
        {'localPath': 42},
        {'checkoutPath': true},
      ]) {
        expect(
          () => parse(bad, strict: false),
          throwsA(isA<BuildError>()),
          reason: '$bad',
        );
      }
    });
  });

  group('COFF archive & Windows linker options', () {
    Uint8List buildSyntheticCoffArchive(List<String> symbols) {
      final builder = BytesBuilder();
      builder.add(ascii.encode('!<arch>\n'));
      // 60-byte archive member header with name '/'
      builder.add(ascii.encode('/'.padRight(60, ' ')));
      // 4-byte big-endian symbol count
      final countBytes = ByteData(4)..setUint32(0, symbols.length, Endian.big);
      builder.add(countBytes.buffer.asUint8List());
      // 4-byte offset per symbol
      for (var i = 0; i < symbols.length; i++) {
        builder.add(const [0, 0, 0, 0]);
      }
      // NUL-terminated symbol strings
      for (final s in symbols) {
        builder.add(ascii.encode(s));
        builder.addByte(0);
      }
      return builder.toBytes();
    }

    test('parses symbols and handles x86 underscore prefix', () {
      final archive = buildSyntheticCoffArchive(['foo', '_bar', 'unmapped']);
      expect(parseCoffArchiveSymbols(archive), {'foo', '_bar', 'unmapped'});
      expect(
        definedBindingsInCoffArchive(archive, ['foo', 'bar', 'missing']),
        {'foo', 'bar'},
      );
    });

    test('throws FormatException for truncated archives', () {
      final archive = buildSyntheticCoffArchive(['foo', 'bar']);
      expect(
        () => parseCoffArchiveSymbols(
          Uint8List.sublistView(archive, 0, archive.length - 2),
        ),
        throwsFormatException,
      );
      expect(
        () => parseCoffArchiveSymbols(Uint8List.sublistView(archive, 0, 10)),
        throwsFormatException,
      );
    });

    Future<File> writeLib(Directory dir, List<String> symbols) async {
      final libFile = File.fromUri(dir.uri.resolve('test.lib'));
      await libFile.writeAsBytes(buildSyntheticCoffArchive(symbols));
      return libFile;
    }

    test('only exports symbols the archive defines', () async {
      final tempDir = await Directory.systemTemp.createTemp('coff_test_');
      addTearDown(() => tempDir.delete(recursive: true));
      final libFile = await writeLib(tempDir, ['sym_a', 'sym_b']);

      Future<LinkerOptions> options(
        List<String>? symbols, [
        List<String>? allKnownSymbols,
      ]) => createWindowsLinkerOptions(
        staticLibrary: libFile.uri,
        symbols: symbols,
        allKnownSymbols: allKnownSymbols,
      );

      expect((await options(['sym_a', 'sym_missing'])).skipWholeLibrary, false);
      expect((await options(['sym_missing'])).skipWholeLibrary, true);
      expect((await options(null, ['sym_b', 'sym_c'])).skipWholeLibrary, false);
      expect((await options(null, ['sym_c'])).skipWholeLibrary, true);
      expect((await options(null)).skipWholeLibrary, false);
    });
  });

  group('SymbolsResolvers', () {
    const bindingsLib = record_use.Library('package:foo/bindings.g.dart');
    const otherLib = record_use.Library('package:foo/other.dart');
    const call = record_use.CallWithArguments(
      positionalArguments: [],
      namedArguments: {},
      loadingUnit: record_use.LoadingUnit('root'),
    );

    record_use.Recordings recordings(
      Iterable<(record_use.Library, String)> methods,
    ) => record_use.Recordings(
      calls: {
        for (final (library, name) in methods)
          record_use.Method(name, library): const [call],
      },
      instances: const {},
    );

    test('fromRecordUseMapping maps, filters, and sorts symbols', () {
      final resolver = SymbolsResolvers.fromRecordUseMapping(
        bindingsLib,
        const {
          'dartB': 'c_b',
          'dartA': 'c_a',
          'dartUnused': 'c_unused',
        },
      );
      expect(
        resolver(
          recordings([
            (bindingsLib, 'dartB'),
            (bindingsLib, 'dartA'),
            (bindingsLib, 'dartUnmapped'),
            (otherLib, 'dartA'),
          ]),
        ),
        ['c_a', 'c_b'],
      );
    });

    test('fromMethodPrefix strips the prefix and filters by library', () {
      final resolver = SymbolsResolvers.fromMethodPrefix(bindingsLib);
      expect(
        resolver(
          recordings([
            (bindingsLib, '_icu4x_b'),
            (bindingsLib, '_icu4x_a'),
            (bindingsLib, 'publicWrapper'),
            (otherLib, '_icu4x_c'),
          ]),
        ),
        ['icu4x_a', 'icu4x_b'],
      );
    });
  });

  group('PrebuiltLibrary', () {
    late Directory tempDir;
    late HttpServer server;
    late Uri serverBaseUri;
    late List<String> requestedPaths;
    final fakeDylibBytes = utf8.encode('fake-dynamic-library-binary');
    final fakeStaticBytes = utf8.encode('fake-static-library-binary');
    final dylibHash = sha256.convert(fakeDylibBytes).toString();
    final staticHash = sha256.convert(fakeStaticBytes).toString();
    const dylibAsset = 'demo-linux-x64-libdemo.so';
    const staticAsset = 'demo-linux-x64-libdemo.a';

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('prebuilt_lib_test_');
      requestedPaths = [];
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      serverBaseUri = Uri.parse('http://127.0.0.1:${server.port}');
      server.listen((request) async {
        final path = request.uri.path;
        requestedPaths.add(path);
        if (path.contains('not-found')) {
          request.response.statusCode = 404;
        } else if (path.contains('corrupt')) {
          request.response.add(utf8.encode('corrupted'));
        } else if (path.endsWith('.a') || path.endsWith('.lib')) {
          request.response.add(fakeStaticBytes);
        } else {
          request.response.add(fakeDylibBytes);
        }
        await request.response.close();
      });
    });

    tearDown(() async {
      await server.close(force: true);
      await tempDir.delete(recursive: true);
    });

    PackageUserDefines userDefines(Map<String, Object?> defines) =>
        PackageUserDefines(
          workspacePubspec: PackageUserDefinesSource(
            defines: defines,
            basePath: tempDir.uri,
          ),
        );

    CodeAssetExtension linuxX64([
      LinkModePreference preference = LinkModePreference.dynamic,
    ]) => CodeAssetExtension(
      targetOS: OS.linux,
      targetArchitecture: Architecture.x64,
      linkModePreference: preference,
    );

    BuildInput createInput({
      required bool linkingEnabled,
      Map<String, Object?> defines = const {},
      LinkModePreference preference = LinkModePreference.dynamic,
    }) {
      final outDir = tempDir.uri.resolve('out/');
      Directory.fromUri(outDir).createSync(recursive: true);
      return (BuildInputBuilder()
            ..setupShared(
              packageRoot: tempDir.uri,
              packageName: 'demo',
              outputFile: tempDir.uri.resolve('output.json'),
              outputDirectoryShared: tempDir.uri.resolve('shared/'),
              userDefines: userDefines(defines),
            )
            ..config.setupBuild(linkingEnabled: linkingEnabled)
            ..addExtension(linuxX64(preference)))
          .build();
    }

    PrebuiltReleaseConfig makeReleaseConfig(
      Map<String, String> hashes, {
      String pathPrefix = '/releases',
    }) => PrebuiltReleaseConfig(
      version: '1.0.0',
      fileHashes: hashes,
      resolveDownloadUri: (ver, asset) =>
          serverBaseUri.resolve('$pathPrefix/$ver/$asset'),
      resolveAssetName: (os, arch, {iosSdk, required static}) {
        final triple = targetTripleFor(os, arch, iosSdk: iosSdk);
        final file = static
            ? os.staticlibFileName('demo')
            : os.dylibFileName('demo');
        return 'demo-$triple-$file';
      },
      resolveLibraryFileName: (os, {required static}) =>
          static ? os.staticlibFileName('demo') : os.dylibFileName('demo'),
    );

    final bothHashes = {dylibAsset: dylibHash, staticAsset: staticHash};

    PrebuiltLibrary makeLibrary(
      PrebuiltReleaseConfig releaseConfig, {
      String? prebuiltDirectory,
      SourceBuildCallback? buildFromSource,
    }) => PrebuiltLibrary(
      name: 'demo',
      assetName: 'demo.dart',
      releaseConfig: releaseConfig,
      prebuiltDirectory: prebuiltDirectory,
      buildFromSource: buildFromSource,
    );

    Future<BuildOutput> runBuild(
      PrebuiltLibrary library,
      BuildInput input,
    ) async {
      final output = BuildOutputBuilder();
      await library.build(input: input, output: output);
      final built = BuildOutput(output.json);
      expect(await ProtocolBase.validateBuildOutput(input, built), isEmpty);
      return built;
    }

    group('build', () {
      test('fetches dynamic library when linking is disabled', () async {
        final built = await runBuild(
          makeLibrary(makeReleaseConfig(bothHashes)),
          createInput(linkingEnabled: false),
        );
        final asset = built.assets.code.single;
        expect(asset.id, 'package:demo/demo.dart');
        expect(asset.linkMode, isA<DynamicLoadingBundled>());
        expect(
          asset.file!.pathSegments.last,
          'libdemo.so',
          reason: 'Leaf filename must be canonical OS dylib filename',
        );
      });

      test('reuses the verified shared cache without downloading', () async {
        final library = makeLibrary(makeReleaseConfig(bothHashes));
        await runBuild(library, createInput(linkingEnabled: false));
        expect(requestedPaths, hasLength(1));
        await runBuild(library, createInput(linkingEnabled: false));
        expect(requestedPaths, hasLength(1));
      });

      test('fetches static library and routes to link hook', () async {
        final built = await runBuild(
          makeLibrary(makeReleaseConfig(bothHashes)),
          createInput(linkingEnabled: true),
        );
        expect(built.assets.code, isEmpty, reason: 'Routed to link hook');
        expect(built.assets.encodedAssetsForLinking['demo'], hasLength(1));
      });

      test(
        'does not route to the link hook when linking is disabled, even with '
        'a static link mode preference',
        () async {
          final built = await runBuild(
            makeLibrary(makeReleaseConfig(bothHashes)),
            createInput(
              linkingEnabled: false,
              preference: LinkModePreference.static,
            ),
          );
          expect(built.assets.encodedAssetsForLinking, isEmpty);
          expect(
            built.assets.code.single.linkMode,
            isA<DynamicLoadingBundled>(),
          );
        },
      );

      test('bundles dynamic library directly when treeshake is off', () async {
        final built = await runBuild(
          makeLibrary(makeReleaseConfig(bothHashes)),
          createInput(linkingEnabled: true, defines: {'treeshake': 'off'}),
        );
        expect(
          built.assets.code.single.linkMode,
          isA<DynamicLoadingBundled>(),
        );
        expect(built.assets.encodedAssetsForLinking['demo'], isNull);
      });

      test(
        'falls back to the prebuilt dynamic library when no static library '
        'is released (treeshake: auto)',
        () async {
          final built = await runBuild(
            makeLibrary(makeReleaseConfig({dylibAsset: dylibHash})),
            createInput(linkingEnabled: true),
          );
          expect(
            built.assets.code.single.linkMode,
            isA<DynamicLoadingBundled>(),
          );
          expect(built.assets.encodedAssetsForLinking['demo'], isNull);
        },
      );

      test(
        'fails instead of bundling a dynamic library when treeshake is on',
        () async {
          await expectLater(
            makeLibrary(makeReleaseConfig({dylibAsset: dylibHash})).build(
              input: createInput(
                linkingEnabled: true,
                defines: {'treeshake': 'on'},
              ),
              output: BuildOutputBuilder(),
            ),
            throwsA(isA<BuildError>()),
          );
        },
      );

      test('throws BuildError on SHA-256 mismatch', () async {
        await expectLater(
          makeLibrary(
            makeReleaseConfig(bothHashes, pathPrefix: '/corrupt'),
          ).build(
            input: createInput(linkingEnabled: false),
            output: BuildOutputBuilder(),
          ),
          throwsA(
            isA<BuildError>().having(
              (e) => e.message,
              'message',
              contains('hash mismatch'),
            ),
          ),
        );
        expect(
          Directory.fromUri(
            tempDir.uri.resolve('shared/'),
          ).listSync(recursive: true).whereType<File>(),
          isEmpty,
          reason: 'Corrupt downloads must not be left in the cache',
        );
      });

      test('uses bundled prebuilt/ directory without network access', () async {
        final prebuiltDir = Directory.fromUri(tempDir.uri.resolve('prebuilt/'))
          ..createSync();
        File.fromUri(
          prebuiltDir.uri.resolve(dylibAsset),
        ).writeAsBytesSync(fakeDylibBytes);

        final built = await runBuild(
          makeLibrary(
            makeReleaseConfig(const {}, pathPrefix: '/not-found'),
            prebuiltDirectory: 'prebuilt',
          ),
          createInput(linkingEnabled: false),
        );
        expect(built.assets.code.single.file!.pathSegments.last, 'libdemo.so');
        expect(requestedPaths, isEmpty);
      });

      test('verifies bundled binaries against registered hashes', () async {
        final prebuiltDir = Directory.fromUri(tempDir.uri.resolve('prebuilt/'))
          ..createSync();
        File.fromUri(
          prebuiltDir.uri.resolve(dylibAsset),
        ).writeAsStringSync('tampered');

        await expectLater(
          makeLibrary(
            makeReleaseConfig(bothHashes),
            prebuiltDirectory: 'prebuilt',
          ).build(
            input: createInput(linkingEnabled: false),
            output: BuildOutputBuilder(),
          ),
          throwsA(isA<BuildError>()),
        );
      });

      Future<Uri> fakeSourceBuild(
        BuildInput input,
        BuildOutputBuilder output, {
        required bool static,
        Uri? checkoutPath,
      }) async {
        final f = File.fromUri(input.outputDirectory.resolve('libdemo.so'));
        await f.parent.create(recursive: true);
        await f.writeAsBytes(fakeDylibBytes);
        return f.uri;
      }

      test(
        'falls back to buildFromSource when no hash is registered',
        () async {
          var sourceBuildCalled = false;
          final built = await runBuild(
            makeLibrary(
              makeReleaseConfig(const {}),
              buildFromSource:
                  (input, output, {required static, checkoutPath}) {
                    sourceBuildCalled = true;
                    return fakeSourceBuild(input, output, static: static);
                  },
            ),
            createInput(linkingEnabled: false),
          );
          expect(sourceBuildCalled, isTrue);
          expect(built.assets.code, hasLength(1));
        },
      );

      test('falls back to buildFromSource when the download 404s', () async {
        var sourceBuildCalled = false;
        await runBuild(
          makeLibrary(
            makeReleaseConfig(bothHashes, pathPrefix: '/not-found'),
            buildFromSource: (input, output, {required static, checkoutPath}) {
              sourceBuildCalled = true;
              return fakeSourceBuild(input, output, static: static);
            },
          ),
          createInput(linkingEnabled: false),
        );
        expect(sourceBuildCalled, isTrue);
      });

      test('returns null after retrying network errors', () async {
        await server.close(force: true);
        final input = createInput(linkingEnabled: false);
        final result = await fetchPrebuiltLibrary(
          input,
          makeReleaseConfig(bothHashes),
          static: false,
          maxAttempts: 2,
        );
        expect(result, isNull);
      });

      test('throws a helpful error for buildMode: local without a path', () {
        expect(
          makeLibrary(makeReleaseConfig(bothHashes)).build(
            input: createInput(
              linkingEnabled: false,
              defines: {'buildMode': 'local'},
            ),
            output: BuildOutputBuilder(),
          ),
          throwsA(
            isA<BuildError>().having(
              (e) => e.message,
              'message',
              contains('localPath'),
            ),
          ),
        );
      });
    });

    group('link', () {
      LinkInput createLinkInput(
        List<EncodedAsset> assets, {
        Map<String, Object?> defines = const {},
        CodeAssetExtension? extension,
      }) =>
          (LinkInputBuilder()
                ..setupShared(
                  packageRoot: tempDir.uri,
                  packageName: 'demo',
                  outputFile: tempDir.uri.resolve('link_output.json'),
                  outputDirectoryShared: tempDir.uri.resolve('shared/'),
                  userDefines: userDefines(defines),
                )
                ..setupLink(
                  assets: assets,
                  assetsFromLinking: const [],
                  recordedUsesFile: null,
                )
                ..addExtension(extension ?? linuxX64()))
              .build();

      CodeAsset staticAsset(String name) => CodeAsset(
        package: 'demo',
        name: name,
        linkMode: StaticLinking(),
        file: tempDir.uri.resolve('libdemo.a'),
      );

      test(
        'treeshake: off bundles the prebuilt dynamic library and forwards '
        'unrelated assets',
        () async {
          final unrelated = CodeAsset(
            package: 'demo',
            name: 'src/not_demo.dart',
            linkMode: DynamicLoadingBundled(),
            file: tempDir.uri.resolve('libother.so'),
          );
          final input = createLinkInput(
            [
              staticAsset('demo.dart').encode(),
              unrelated.encode(),
            ],
            defines: {'treeshake': 'off'},
          );
          final output = LinkOutputBuilder();
          await makeLibrary(
            makeReleaseConfig(bothHashes),
          ).link(input: input, output: output);

          final linked = LinkOutput(output.json);
          expect(await ProtocolBase.validateLinkOutput(input, linked), isEmpty);
          final ids = {
            for (final e in linked.assets.encodedAssets)
              CodeAsset.fromEncoded(e).id: CodeAsset.fromEncoded(e).linkMode,
          };
          expect(ids, {
            'package:demo/demo.dart': isA<DynamicLoadingBundled>(),
            'package:demo/src/not_demo.dart': isA<DynamicLoadingBundled>(),
          });
        },
      );

      test('matches the asset ID exactly', () async {
        // `package:demo/mydemo.dart` ends with `demo.dart` but is not ours.
        final lookalike = staticAsset('mydemo.dart');
        final input = createLinkInput([lookalike.encode()]);
        final output = LinkOutputBuilder();
        await makeLibrary(
          makeReleaseConfig(bothHashes),
        ).link(input: input, output: output);
        final linked = LinkOutput(output.json);
        expect(
          linked.assets.encodedAssets.map((e) => CodeAsset.fromEncoded(e).id),
          ['package:demo/mydemo.dart'],
          reason: 'Forwarded untouched, not linked',
        );
        expect(requestedPaths, isEmpty);
      });

      test(
        'treeshake: auto falls back when the static library cannot be read',
        () async {
          // On Windows, reading the symbols of the (invalid) archive fails
          // before the linker runs.
          await File.fromUri(
            tempDir.uri.resolve('libdemo.a'),
          ).writeAsString('not-an-archive');
          final dll = makeReleaseConfig(
            const {},
          ).resolveAssetName(OS.windows, Architecture.x64, static: false);
          final input = createLinkInput(
            [staticAsset('demo.dart').encode()],
            extension: CodeAssetExtension(
              targetOS: OS.windows,
              targetArchitecture: Architecture.x64,
              linkModePreference: LinkModePreference.dynamic,
            ),
          );
          final output = LinkOutputBuilder();
          await makeLibrary(
            makeReleaseConfig({dll: dylibHash}),
          ).link(input: input, output: output);
          final asset = LinkOutput(output.json).assets.code.single;
          expect(asset.linkMode, isA<DynamicLoadingBundled>());
          expect(requestedPaths, ['/releases/1.0.0/$dll']);
        },
      );

      test('passes the CodeConfig to libraries and frameworks', () async {
        final configs = <String, CodeConfig>{};
        // Not a valid archive, so linking fails (and `treeshake: on` rethrows)
        // after the callbacks ran.
        await File.fromUri(
          tempDir.uri.resolve('libdemo.a'),
        ).writeAsString('not-an-archive');
        final input = createLinkInput(
          [
            staticAsset('demo.dart').encode(),
          ],
          defines: {'treeshake': 'on'},
        );
        final library = PrebuiltLibrary(
          name: 'demo',
          assetName: 'demo.dart',
          libraries: (code) {
            configs['libraries'] = code;
            return const ['m'];
          },
          frameworks: (code) {
            configs['frameworks'] = code;
            return const [];
          },
        );
        await expectLater(
          library.link(input: input, output: LinkOutputBuilder()),
          throwsA(anything),
        );
        for (final code in [configs['libraries'], configs['frameworks']]) {
          expect(code?.targetOS, OS.linux);
          expect(code?.targetArchitecture, Architecture.x64);
        }
      });
    });
  });

  group('runPrecompileBinariesCli', () {
    final library = PrebuiltLibrary(
      name: 'demo',
      assetName: 'demo.dart',
      buildFromSource: (input, output, {required static, checkoutPath}) =>
          throw StateError('should not build'),
    );

    test('requires --ios-sdk for iOS', () {
      expect(
        runPrecompileBinariesCli(['--target-os', 'ios'], library: library),
        throwsA(isA<UsageException>()),
      );
    });

    test('rejects --ios-sdk for non-iOS targets', () {
      expect(
        runPrecompileBinariesCli([
          '--target-os',
          'linux',
          '--ios-sdk',
          'iphoneos',
        ], library: library),
        throwsA(isA<UsageException>()),
      );
    });

    test('throws UsageException for unknown options', () {
      expect(
        runPrecompileBinariesCli(['--nope'], library: library),
        throwsA(isA<UsageException>()),
      );
    });
  });

  group('runRegenerateHashesCli', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('regenerate_test_');
    });

    tearDown(() => tempDir.delete(recursive: true));

    PrebuiltReleaseConfig config(String version, Uri base) =>
        PrebuiltReleaseConfig.github(
          owner: 'o',
          repo: 'demo',
          version: version,
          fileHashes: const {},
          libraryName: 'demo',
        ).copyWithDownloadBase(base);

    test('aborts without writing when downloads fail', () async {
      final hashes = File.fromUri(tempDir.uri.resolve('hashes.dart'));
      await expectLater(
        runRegenerateHashesCli(
          const ['1.0.0'],
          defaultVersion: '1.0.0',
          // Nothing listens on port 9 (discard); connections are refused.
          releaseConfigForVersion: (v) =>
              config(v, Uri.parse('http://127.0.0.1:9/')),
          hashesFilePath: hashes.path,
          versionFilePath: null,
          targets: const [(OS.linux, Architecture.x64, null)],
        ),
        throwsStateError,
      );
      expect(hashes.existsSync(), isFalse);
    });

    test('writes escaped hashes without a license header by default', () async {
      final artifacts = Directory.fromUri(tempDir.uri.resolve('artifacts/'))
        ..createSync();
      File.fromUri(
        artifacts.uri.resolve('demo-linux-x64-libdemo.so'),
      ).writeAsStringSync('dylib');
      final hashes = File.fromUri(tempDir.uri.resolve('hashes.dart'));
      final version = File.fromUri(tempDir.uri.resolve('version.dart'));

      await runRegenerateHashesCli(
        [r"1.0.0-it's$", artifacts.path],
        defaultVersion: '1.0.0',
        releaseConfigForVersion: (v) =>
            config(v, Uri.parse('http://unused.invalid/')),
        hashesFilePath: hashes.path,
        versionFilePath: version.path,
        targets: const [(OS.linux, Architecture.x64, null)],
      );

      final content = hashes.readAsStringSync();
      expect(content, startsWith('// coverage:ignore-file'));
      expect(content, contains("import 'version.dart';"));
      expect(
        content,
        contains(sha256.convert(utf8.encode('dylib')).toString()),
      );
      expect(version.readAsStringSync(), contains(r"'1.0.0-it\'s\$'"));
    });

    test('requires the version file next to the hashes file', () {
      expect(
        runRegenerateHashesCli(
          const [],
          defaultVersion: '1.0.0',
          releaseConfigForVersion: (v) =>
              config(v, Uri.parse('http://unused.invalid/')),
          hashesFilePath: tempDir.uri.resolve('a/hashes.dart').toFilePath(),
          versionFilePath: tempDir.uri.resolve('b/version.dart').toFilePath(),
        ),
        throwsArgumentError,
      );
    });
  });
}

extension on PrebuiltReleaseConfig {
  PrebuiltReleaseConfig copyWithDownloadBase(Uri base) => PrebuiltReleaseConfig(
    version: version,
    fileHashes: fileHashes,
    resolveDownloadUri: (ver, asset) => base.resolve('$ver/$asset'),
    resolveAssetName: resolveAssetName,
    resolveLibraryFileName: resolveLibraryFileName,
  );
}
