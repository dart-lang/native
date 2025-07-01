// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import { createRoot, createSignal } from "solid-js";

/**
 * ffigen config yaml string
 */
export const $ffigenConfig = createRoot(() =>
  createSignal(
    `output: 'output.dart' # DO NOT CHANGE OUTPUT PATH
name: 'NativeLibrary'
description: 'cool library bindings!'
headers:
  entry-points:
    - '/home/web_user/main.h'
  `,
  ),
);
