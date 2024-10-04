// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:vm_service/vm_service.dart';

// TODO(cbracken) make generic
/// Retries the specified function with the specified interval and returns
/// the result on successful completion.
Future<dynamic> retry(Future Function() f, Duration interval,
    {Duration? timeout}) async {
  var keepGoing = true;

  Future<dynamic> withTimeout(Future Function() f, {Duration? duration}) {
    if (duration == null) {
      return f();
    }

    return f().timeout(duration, onTimeout: () {
      keepGoing = false;
      final msg = duration.inSeconds == 0
          ? '${duration.inMilliseconds}ms'
          : '${duration.inSeconds}s';
      throw StateError('Failed to complete within $msg');
    });
  }

  return withTimeout(() async {
    while (keepGoing) {
      try {
        return await f();
      } catch (_) {
        if (keepGoing) {
          await Future<dynamic>.delayed(interval);
        }
      }
    }
  }, duration: timeout);
}

/// Scrapes and returns the Dart VM service URI from a string, or null if not
/// found.
///
/// Potentially useful as a means to extract it from log statements.
Uri? extractVMServiceUri(String str) {
  final listeningMessageRegExp = RegExp(
    r'(?:Observatory|The Dart VM service is) listening on ((http|//)[a-zA-Z0-9:/=_\-\.\[\]]+)',
  );
  final match = listeningMessageRegExp.firstMatch(str);
  if (match != null) {
    return Uri.parse(match[1]!);
  }
  return null;
}

/// Returns an open port by creating a temporary Socket
Future<int> getOpenPort() async {
  ServerSocket socket;

  try {
    socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  } catch (_) {
    // try again v/ V6 only. Slight possibility that V4 is disabled
    socket =
        await ServerSocket.bind(InternetAddress.loopbackIPv6, 0, v6Only: true);
  }

  try {
    return socket.port;
  } finally {
    await socket.close();
  }
}

final muliLineIgnoreStart = RegExp(r'//\s*coverage:ignore-start[\w\d\s]*$');
final muliLineIgnoreEnd = RegExp(r'//\s*coverage:ignore-end[\w\d\s]*$');
final singleLineIgnore = RegExp(r'//\s*coverage:ignore-line[\w\d\s]*$');
final ignoreFile = RegExp(r'//\s*coverage:ignore-file[\w\d\s]*$');

/// Return list containing inclusive range of lines to be ignored by coverage.
/// If there is a error in balancing the statements it will throw a
/// [FormatException],
/// unless `coverage:ignore-file` is found.
/// Return [0, lines.length] if the whole file is ignored.
///
/// ```
/// 1.  final str = ''; // coverage:ignore-line
/// 2.  final str = '';
/// 3.  final str = ''; // coverage:ignore-start
/// 4.  final str = '';
/// 5.  final str = ''; // coverage:ignore-end
/// ```
///
/// Returns
/// ```
/// [
///   [1,1],
///   [3,5],
/// ]
/// ```
///
List<List<int>> getIgnoredLines(String filePath, List<String>? lines) {
  final ignoredLines = <List<int>>[];
  if (lines == null) return ignoredLines;

  final allLines = [
    [0, lines.length]
  ];

  FormatException? err;
  var i = 0;
  while (i < lines.length) {
    if (lines[i].contains(ignoreFile)) return allLines;

    if (lines[i].contains(muliLineIgnoreEnd)) {
      err ??= FormatException(
        'unmatched coverage:ignore-end found at $filePath:${i + 1}',
      );
    }

    if (lines[i].contains(singleLineIgnore)) ignoredLines.add([i + 1, i + 1]);

    if (lines[i].contains(muliLineIgnoreStart)) {
      final start = i;
      var isUnmatched = true;
      ++i;
      while (i < lines.length) {
        if (lines[i].contains(ignoreFile)) return allLines;
        if (lines[i].contains(muliLineIgnoreStart)) {
          err ??= FormatException(
            'coverage:ignore-start found at $filePath:${i + 1}'
            ' before previous coverage:ignore-start ended',
          );
          break;
        }

        if (lines[i].contains(muliLineIgnoreEnd)) {
          ignoredLines.add([start + 1, i + 1]);
          isUnmatched = false;
          break;
        }
        ++i;
      }

      if (isUnmatched) {
        err ??= FormatException(
          'coverage:ignore-start found at $filePath:${start + 1}'
          ' has no matching coverage:ignore-end',
        );
      }
    }
    ++i;
  }

  if (err == null) {
    return ignoredLines;
  }

  throw err;
}

extension StandardOutExtension on Stream<List<int>> {
  Stream<String> lines() =>
      transform(const SystemEncoding().decoder).transform(const LineSplitter());
}

Future<Uri> serviceUriFromProcess(Stream<String> procStdout) {
  // Capture the VM service URI.
  final serviceUriCompleter = Completer<Uri>();
  procStdout.listen((line) {
    if (!serviceUriCompleter.isCompleted) {
      final serviceUri = extractVMServiceUri(line);
      if (serviceUri != null) {
        serviceUriCompleter.complete(serviceUri);
      }
    }
  });
  return serviceUriCompleter.future;
}

Future<List<IsolateRef>> getAllIsolates(VmService service) async =>
    (await service.getVM()).isolates ?? [];
