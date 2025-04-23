// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'hooks/syntax.g.dart' as syntax;

/// The user-defines for a single build hokok invocation
///
/// Currently only holds [workspacePubspec]. (In the future this class will also
/// take command-line arguments and a working directory for the command-line
/// argument paths to be resolved against.)
class PackageUserDefines {
  final PackageUserDefinesSource? workspacePubspec;

  PackageUserDefines({required this.workspacePubspec});

  @override
  String toString() =>
      'PackageUserDefines(workspacePubspec: $workspacePubspec)';
}

extension PackageUserDefinesSyntax on PackageUserDefines {
  static PackageUserDefines fromSyntax(syntax.UserDefines syntaxNode) =>
      PackageUserDefines(
        workspacePubspec: switch (syntaxNode.workspacePubspec) {
          null => null,
          final o => PackageUserDefinesSourceSyntax.fromSyntax(o),
        },
      );

  syntax.UserDefines toSyntax() {
    final result = syntax.UserDefines(
      workspacePubspec: workspacePubspec?.toSyntax(),
    );

    return result;
  }
}

class PackageUserDefinesSource {
  final Map<String, Object?> defines;

  /// The base path for relative paths in [defines].
  final Uri basePath;

  PackageUserDefinesSource({required this.defines, required this.basePath});

  @override
  String toString() =>
      'PackageUserDefinesSource(defines: $defines, basePath: $basePath)';
}

extension PackageUserDefinesSourceSyntax on PackageUserDefinesSource {
  static PackageUserDefinesSource fromSyntax(
    syntax.UserDefinesSource syntaxNode,
  ) => PackageUserDefinesSource(
    defines: syntaxNode.defines.json,
    basePath: syntaxNode.basePath,
  );

  syntax.UserDefinesSource toSyntax() => syntax.UserDefinesSource(
    basePath: basePath,
    defines: syntax.JsonObject.fromJson(defines),
  );
}
