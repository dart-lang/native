// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'config.dart';
import 'hooks/syntax.g.dart';

/// The user-defines for [HookInputBuilder.setupShared].
///
/// User-defines can originate from multiple sources. The sources are ordered by
/// precedence, highest first:
/// 1. [commandLineArguments] (`--hook-define=<package>.<key>=<value>`).
/// 2. [environmentVariables] (`DART_HOOK_DEFINE__<package>__<key>=<value>`).
/// 3. [workspacePubspec] (`hooks.user_defines` in the workspace
///    `pubspec.yaml`).
///
/// A define in a higher precedence source overrides the same key in a lower
/// precedence source.
final class PackageUserDefines {
  /// User-defines originating from command-line arguments to the SDK.
  final PackageUserDefinesSource? commandLineArguments;

  /// User-defines originating from environment variables.
  final PackageUserDefinesSource? environmentVariables;

  /// User-defines originating from the `pubspec.yaml` in the workspace root.
  final PackageUserDefinesSource? workspacePubspec;

  /// Creates a [PackageUserDefines].
  PackageUserDefines({
    this.commandLineArguments,
    this.environmentVariables,
    required this.workspacePubspec,
  });

  /// The sources of user-defines, ordered by precedence, highest first.
  List<PackageUserDefinesSource> get sources => [
    ?commandLineArguments,
    ?environmentVariables,
    ?workspacePubspec,
  ];

  // coverage:ignore-start
  @override
  String toString() =>
      'PackageUserDefines(commandLineArguments: $commandLineArguments, '
      'environmentVariables: $environmentVariables, '
      'workspacePubspec: $workspacePubspec)';
  // coverage:ignore-end
}

/// Extension methods for [PackageUserDefines] to convert to and from syntax
/// nodes.
extension PackageUserDefinesSyntaxExtension on PackageUserDefines {
  /// Creates a [PackageUserDefines] from a [UserDefinesSyntax] node.
  static PackageUserDefines fromSyntax(UserDefinesSyntax syntaxNode) =>
      PackageUserDefines(
        commandLineArguments:
            PackageUserDefinesSourceSyntaxExtension.fromSyntaxOrNull(
              syntaxNode.commandLineArguments,
            ),
        environmentVariables:
            PackageUserDefinesSourceSyntaxExtension.fromSyntaxOrNull(
              syntaxNode.environmentVariables,
            ),
        workspacePubspec:
            PackageUserDefinesSourceSyntaxExtension.fromSyntaxOrNull(
              syntaxNode.workspacePubspec,
            ),
      );

  /// Converts this [PackageUserDefines] to a [UserDefinesSyntax] node.
  UserDefinesSyntax toSyntax() {
    final result = UserDefinesSyntax(
      commandLineArguments: commandLineArguments?.toSyntax(),
      environmentVariables: environmentVariables?.toSyntax(),
      workspacePubspec: workspacePubspec?.toSyntax(),
    );

    return result;
  }
}

/// A source of user-defines in a [PackageUserDefines].
final class PackageUserDefinesSource {
  /// The user-defined values.
  final Map<String, Object?> defines;

  /// The base path for relative paths in [defines].
  final Uri basePath;

  /// Creates a [PackageUserDefinesSource].
  PackageUserDefinesSource({required this.defines, required this.basePath});

  // coverage:ignore-start
  @override
  String toString() =>
      'PackageUserDefinesSource(defines: $defines, basePath: $basePath)';
  // coverage:ignore-end
}

/// Extension methods for [PackageUserDefinesSource] to convert to and from
/// syntax nodes.
extension PackageUserDefinesSourceSyntaxExtension on PackageUserDefinesSource {
  /// Creates a [PackageUserDefinesSource] from a [UserDefinesSourceSyntax]
  /// node, or `null` if [syntaxNode] is `null`.
  static PackageUserDefinesSource? fromSyntaxOrNull(
    UserDefinesSourceSyntax? syntaxNode,
  ) => switch (syntaxNode) {
    null => null,
    final node => fromSyntax(node),
  };

  /// Creates a [PackageUserDefinesSource] from a [UserDefinesSourceSyntax]
  /// node.
  static PackageUserDefinesSource fromSyntax(
    UserDefinesSourceSyntax syntaxNode,
  ) => PackageUserDefinesSource(
    defines: syntaxNode.defines.json,
    basePath: syntaxNode.basePath,
  );

  /// Converts this [PackageUserDefinesSource] to a [UserDefinesSourceSyntax]
  /// node.
  UserDefinesSourceSyntax toSyntax() => UserDefinesSourceSyntax(
    basePath: basePath,
    defines: JsonObjectSyntax.fromJson(defines),
  );
}
