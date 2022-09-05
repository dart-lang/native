// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni_gen/jni_gen.dart';

const preamble = '''
// Generated from Apache PDFBox library which is licensed under the Apache License 2.0.
// The following copyright from the original authors applies.
//
// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to You under the Apache License, Version 2.0
// (the "License"); you may not use this file except in compliance with
// the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
''';

void main(List<String> arguments) async {
  final config = Config(
    mavenDownloads: MavenDownloads(
      sourceDeps: ['org.apache.pdfbox:pdfbox:2.0.26'],
      jarOnlyDeps: [
        'org.bouncycastle:bcmail-jdk15on:1.70',
        'org.bouncycastle:bcprov-jdk15on:1.70',
      ],
    ),
    classes: ['org.apache.pdfbox.pdmodel', 'org.apache.pdfbox.text'],
    cRoot: Uri.directory('src/'),
    cSubdir: 'third_party',
    preamble: preamble,
    dartRoot: Uri.directory('lib/third_party'),
    libraryName: 'pdfbox_plugin',
  );
  await generateJniBindings(config);
}
