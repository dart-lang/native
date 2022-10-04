// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

Stream<String> commandOutputStream(
        String Function(String) lineMapper, Stream<List<int>> input) =>
    input.transform(Utf8Decoder()).transform(LineSplitter()).map(lineMapper);

Stream<String> prefixedCommandOutputStream(
        String prefix, Stream<List<int>> input) =>
    commandOutputStream((line) => '$prefix $line', input);

void collectOutputStream(Stream<List<int>> stream, StringBuffer buffer) =>
    stream.transform(Utf8Decoder()).forEach(buffer.write);
