// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  BuildInput makeInput(Map<String, Object?> defines, Uri basePath) {
    final tempUri = Directory.systemTemp.uri;
    final builder = BuildInputBuilder()
      ..setupShared(
        packageName: 'my_package',
        packageRoot: tempUri.resolve('my_package/'),
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUri.resolve('out_shared/'),
        userDefines: PackageUserDefines(
          workspacePubspec: PackageUserDefinesSource(
            defines: defines,
            basePath: basePath,
          ),
        ),
      )
      ..config.addBuildAssetTypes(['my-asset-type'])
      ..config.setupBuild(linkingEnabled: false);
    return builder.build();
  }

  group('path() on Windows', () {
    final basePath = Uri.parse('file:///D:/proj/example/pubspec.yaml');

    // Skips are done with early returns instead of `testOn`, because these
    // tests also run on the Dart SDK CI which does not respect `package:test`
    // annotations.
    test('absolute path with Windows separators is returned as-is', () {
      if (!Platform.isWindows) return;
      final input = makeInput({'lib': r'D:\some\dir\lib.dll'}, basePath);
      final uri = input.userDefines.path('lib')!;
      expect(uri, Uri.parse('file:///D:/some/dir/lib.dll'));
      expect(uri.toFilePath(), r'D:\some\dir\lib.dll');
    });

    test('absolute path with forward slashes is returned as-is', () {
      if (!Platform.isWindows) return;
      final input = makeInput({'lib': 'D:/some/dir/lib.dll'}, basePath);
      final uri = input.userDefines.path('lib')!;
      expect(uri, Uri.parse('file:///D:/some/dir/lib.dll'));
      expect(uri.toFilePath(), r'D:\some\dir\lib.dll');
    });

    test('UNC path is returned as-is', () {
      if (!Platform.isWindows) return;
      final input = makeInput({'lib': r'\\server\share\lib.dll'}, basePath);
      final uri = input.userDefines.path('lib')!;
      expect(uri, Uri.parse('file://server/share/lib.dll'));
      expect(uri.toFilePath(), r'\\server\share\lib.dll');
    });

    test('relative path with Linux separators resolves against basePath', () {
      if (!Platform.isWindows) return;
      final input = makeInput({'file': 'some/dir/model.bin'}, basePath);
      final uri = input.userDefines.path('file')!;
      expect(uri, Uri.parse('file:///D:/proj/example/some/dir/model.bin'));
      expect(uri.toFilePath(), r'D:\proj\example\some\dir\model.bin');
    });

    test('relative path with Windows separators resolves against basePath', () {
      if (!Platform.isWindows) return;
      final input = makeInput({'file': r'some\dir\model.bin'}, basePath);
      final uri = input.userDefines.path('file')!;
      expect(uri, Uri.parse('file:///D:/proj/example/some/dir/model.bin'));
      expect(uri.toFilePath(), r'D:\proj\example\some\dir\model.bin');
    });
  });

  group('path() on POSIX', () {
    final basePath = Uri.parse('file:///home/user/proj/example/pubspec.yaml');

    test('absolute path is returned as-is', () {
      if (Platform.isWindows) return;
      final input = makeInput({'lib': '/some/dir/lib.so'}, basePath);
      final uri = input.userDefines.path('lib')!;
      expect(uri, Uri.parse('file:///some/dir/lib.so'));
      expect(uri.toFilePath(), '/some/dir/lib.so');
    });

    test('relative path resolves against basePath', () {
      if (Platform.isWindows) return;
      final input = makeInput({'file': 'some/dir/model.bin'}, basePath);
      final uri = input.userDefines.path('file')!;
      expect(
        uri,
        Uri.parse('file:///home/user/proj/example/some/dir/model.bin'),
      );
      expect(uri.toFilePath(), '/home/user/proj/example/some/dir/model.bin');
    });

    test('relative path with Windows separators resolves against basePath', () {
      if (Platform.isWindows) return;
      final input = makeInput({'file': r'some\dir\model.bin'}, basePath);
      final uri = input.userDefines.path('file')!;
      expect(
        uri,
        Uri.parse('file:///home/user/proj/example/some/dir/model.bin'),
      );
      expect(uri.toFilePath(), '/home/user/proj/example/some/dir/model.bin');
    });
  });

  group('path()', () {
    final basePath = Uri.parse('file:///base/dir/pubspec.yaml');

    test('returns null for a missing key', () {
      final input = makeInput({}, basePath);
      expect(input.userDefines.path('missing'), isNull);
    });

    test('returns null for a non-String value', () {
      final input = makeInput({'key': 1}, basePath);
      expect(input.userDefines.path('key'), isNull);
    });

    test('returns null without user-defines', () {
      final tempUri = Directory.systemTemp.uri;
      final builder = BuildInputBuilder()
        ..setupShared(
          packageName: 'my_package',
          packageRoot: tempUri.resolve('my_package/'),
          outputFile: tempUri.resolve('output.json'),
          outputDirectoryShared: tempUri.resolve('out_shared/'),
        )
        ..config.addBuildAssetTypes(['my-asset-type'])
        ..config.setupBuild(linkingEnabled: false);
      expect(builder.build().userDefines.path('key'), isNull);
    });
  });
}
