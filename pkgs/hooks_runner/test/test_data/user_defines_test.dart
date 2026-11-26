// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:convert';
import 'dart:io';

import 'package:hooks_runner/hooks_runner.dart';
import 'package:test/test.dart';

import '../build_runner/helpers.dart';
import '../helpers.dart';

void main() async {
  const name = 'user_defines';

  /// The user-defines that the hook in `test_data/user_defines` observed.
  Future<Map<String, Object?>> receivedUserDefines(Uri packageUri) async =>
      jsonDecode(
            await File.fromUri(
              packageUri.resolve('received_user_defines.json'),
            ).readAsString(),
          )
          as Map<String, Object?>;

  test('$name build', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('$name/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      final pubspecUri = packageUri.resolve('pubspec.yaml');
      final result = (await build(
        packageUri,
        logger,
        dartExecutable,
        capturedLogs: [],
        buildAssetTypes: [.data],
        userDefines: UserDefines(workspacePubspec: pubspecUri),
      )).success;

      expect(result.encodedAssets.length, 0);

      // The native assets build runner must be reinvoked if the pubspec
      // changes, as the pubspec could contain user-defines.
      expect(result.dependencies, contains(pubspecUri));
      expect(
        result.dependencies,
        contains(packageUri.resolve('assets/data.json')),
      );
      expect(
        result.dependencies,
        contains(packageUri.resolve('assets/second.json')),
      );

      expect(await receivedUserDefines(packageUri), {
        'user_define_key': 'user_define_value',
        'user_define_key2': {'foo': 'bar'},
        'user_define_precedence': 'from_pubspec',
        'user_define_typed': 42,
        'cli_only_key': null,
        'env_only_key': null,
        'some_file': 'assets/data.json',
        'some_file_path': packageUri.resolve('assets/data.json').toString(),
      });
    });
  });

  test('$name build with command-line and environment user-defines', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('$name/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      final logMessages = <String>[];
      final result = (await build(
        packageUri,
        logger,
        dartExecutable,
        capturedLogs: logMessages,
        buildAssetTypes: [.data],
        userDefines: UserDefines(
          workspacePubspec: packageUri.resolve('pubspec.yaml'),
          commandLineDefines: [
            // Overrides the environment variable and the pubspec.
            'user_defines.user_define_precedence=from_command_line',
            // Overrides the pubspec with a different type.
            'user_defines.user_define_typed=43',
            'user_defines.cli_only_key=42',
            // Relative paths resolve against the base path of the
            // command-line arguments.
            'user_defines.some_file=assets/second.json',
            // Not a package in this project, ignored with a warning.
            'no_such_package.key=value',
          ],
          definesBasePath: packageUri,
          environment: {
            // Overrides the pubspec.
            'DART_HOOK_DEFINE__user_defines__user_define_precedence':
                'from_environment',
            'DART_HOOK_DEFINE__user_defines__env_only_key': 'true',
            // Not a package in this project, ignored with a warning.
            'DART_HOOK_DEFINE__no_such_package__key': 'value',
          },
        ),
      )).success;

      final log = logMessages.join('\n');
      expect(
        log,
        contains(
          'Ignoring environment variable '
          "'DART_HOOK_DEFINE__no_such_package__key'",
        ),
      );
      expect(
        log,
        contains("Ignoring command-line user-defines for 'no_such_package'"),
      );

      expect(
        result.dependencies,
        contains(packageUri.resolve('assets/second.json')),
      );

      final received = await receivedUserDefines(packageUri);
      expect(received['user_define_precedence'], 'from_command_line');
      expect(received['user_define_typed'], 43);
      expect(received['cli_only_key'], 42);
      expect(received['env_only_key'], true);
      // Still from the pubspec.
      expect(received['user_define_key'], 'user_define_value');
      expect(received['user_define_key2'], {'foo': 'bar'});
      expect(received['some_file'], 'assets/second.json');
      expect(
        received['some_file_path'],
        packageUri.resolve('assets/second.json').toString(),
      );
    });
  });

  test('$name build with only environment user-defines', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('$name/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      await build(
        packageUri,
        logger,
        dartExecutable,
        capturedLogs: [],
        buildAssetTypes: [.data],
        userDefines: UserDefines(
          workspacePubspec: packageUri.resolve('pubspec.yaml'),
          definesBasePath: packageUri,
          environment: {
            'DART_HOOK_DEFINE__user_defines__user_define_precedence':
                'from_environment',
            'DART_HOOK_DEFINE__user_defines__user_define_typed': 'false',
          },
        ),
      );

      final received = await receivedUserDefines(packageUri);
      expect(received['user_define_precedence'], 'from_environment');
      expect(received['user_define_typed'], false);
    });
  });

  test('$name caches on the user-defines', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('$name/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      Future<List<String>> run(List<String> commandLineDefines) async {
        final logMessages = <String>[];
        (await build(
          packageUri,
          logger,
          dartExecutable,
          capturedLogs: logMessages,
          buildAssetTypes: [.data],
          userDefines: UserDefines(
            workspacePubspec: packageUri.resolve('pubspec.yaml'),
            commandLineDefines: commandLineDefines,
            definesBasePath: packageUri,
          ),
        )).success;
        return logMessages;
      }

      String warnings(List<String> logMessages) => logMessages
          .where((message) => message.contains('Skipping build'))
          .join('\n');

      const define1 = 'user_defines.user_define_precedence=from_command_line_1';
      const define2 = 'user_defines.user_define_precedence=from_command_line_2';

      // First invocation runs the hook.
      await run([define1]);
      expect(
        await receivedUserDefines(packageUri),
        containsPair(
          'user_define_precedence',
          'from_command_line_1',
        ),
      );

      // The same user-defines hit the cache.
      expect(warnings(await run([define1])), contains('Skipping build'));

      // Different user-defines rerun the hook.
      expect(warnings(await run([define2])), isEmpty);
      expect(
        await receivedUserDefines(packageUri),
        containsPair(
          'user_define_precedence',
          'from_command_line_2',
        ),
      );

      // A later invocation without user-defines reruns the hook.
      expect(warnings(await run([])), isEmpty);
      expect(
        await receivedUserDefines(packageUri),
        containsPair(
          'user_define_precedence',
          'from_pubspec',
        ),
      );

      // And switching back to the first user-defines reruns the hook as well.
      expect(warnings(await run([define1])), isEmpty);
      expect(
        await receivedUserDefines(packageUri),
        containsPair(
          'user_define_precedence',
          'from_command_line_1',
        ),
      );
    });
  });

  test('$name fails on malformed command-line user-defines', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('$name/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      final logMessages = <String>[];
      final result = await build(
        packageUri,
        logger,
        dartExecutable,
        capturedLogs: logMessages,
        buildAssetTypes: [.data],
        userDefines: UserDefines(
          workspacePubspec: packageUri.resolve('pubspec.yaml'),
          commandLineDefines: ['user_defines.user_define_precedence'],
          definesBasePath: packageUri,
        ),
      );
      expect(result.failure, HooksRunnerFailure.projectConfig);
      expect(
        logMessages.join('\n'),
        contains("Expected '<package>.<key>=<value>'"),
      );
    });
  });

  test(
    '$name fails on malformed command-line user-defines without hooks',
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('no_hook/');

        await runPubGet(workingDirectory: packageUri, logger: logger);

        // Without command-line user-defines the invocation succeeds, even
        // though there are no hooks at all.
        (await build(
          packageUri,
          logger,
          dartExecutable,
          capturedLogs: [],
          buildAssetTypes: [.data],
          userDefines: UserDefines(
            workspacePubspec: packageUri.resolve('pubspec.yaml'),
            definesBasePath: packageUri,
          ),
        )).success;

        // A malformed command-line user-define fails the invocation, even
        // though no hook reads it.
        final logMessages = <String>[];
        final result = await build(
          packageUri,
          logger,
          dartExecutable,
          capturedLogs: logMessages,
          buildAssetTypes: [.data],
          userDefines: UserDefines(
            workspacePubspec: packageUri.resolve('pubspec.yaml'),
            commandLineDefines: ['user_defines.user_define_precedence'],
            definesBasePath: packageUri,
          ),
        );
        expect(result.failure, HooksRunnerFailure.projectConfig);
        expect(
          logMessages.join('\n'),
          contains("Expected '<package>.<key>=<value>'"),
        );
      });
    },
  );
}
