// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

/// A concrete subclass of [ProtocolExtension] that intentionally implements
/// nothing.
///
/// **CRITICAL**: Do NOT add any method or member implementations/overrides to
/// this class.
///
/// [ProtocolExtension] is an abstract base class (not an interface) to prevent
/// breaking changes across the ecosystem when new methods are added. All new
/// methods added to [ProtocolExtension] MUST have a default implementation.
///
/// If this class fails to compile with a "missing concrete implementation"
/// error, it means an abstract member was added to [ProtocolExtension]. To fix
/// it, add a default implementation to the member in [ProtocolExtension]
/// instead of implementing it here.
final class ConcreteProtocolExtension extends ProtocolExtension {
  // Class body must be left empty (see doc comment).
}

void main() {
  test(
    'ProtocolExtension can be fully subclassed without overriding methods',
    () async {
      final extension = ConcreteProtocolExtension();

      final logger = Logger('test');
      extension.setupLogger(logger);
      expect(extension.logger, same(logger));

      final buildInputBuilder = BuildInputBuilder()
        ..setupShared(
          packageRoot: Uri.file('/tmp/'),
          packageName: 'my_package',
          outputFile: Uri.file('/tmp/output.json'),
          outputDirectoryShared: Uri.file('/tmp/shared/'),
        )
        ..config.setupBuild(linkingEnabled: false);
      extension.setupBuildInput(buildInputBuilder);
      final buildInput = buildInputBuilder.build();
      final buildOutput = BuildOutput(BuildOutputBuilder().json);

      final linkInputBuilder = LinkInputBuilder()
        ..setupShared(
          packageRoot: Uri.file('/tmp/'),
          packageName: 'my_package',
          outputFile: Uri.file('/tmp/link_output.json'),
          outputDirectoryShared: Uri.file('/tmp/shared/'),
        )
        ..setupLink(assets: [], recordedUsesFile: null, assetsFromLinking: []);
      extension.setupLinkInput(linkInputBuilder);
      final linkInput = linkInputBuilder.build();
      final linkOutput = LinkOutput(LinkOutputBuilder().json);

      // Verify default implementations return expected empty collections.
      expect(await extension.validateBuildInput(buildInput), isEmpty);
      expect(
        await extension.validateBuildOutput(buildInput, buildOutput),
        isEmpty,
      );
      expect(await extension.validateLinkInput(linkInput), isEmpty);
      expect(
        await extension.validateLinkOutput(linkInput, linkOutput),
        isEmpty,
      );
      expect(await extension.validateApplicationAssets([]), isEmpty);
      expect(extension.outputFiles([]), isEmpty);
    },
  );
}
