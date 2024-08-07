// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import { onMount } from "solid-js";
import createLibclang from "../../third_party/libclang/bin/libclang.mjs";
import * as dart from "../../bin/ffigenpad.mjs";
import wasm_url from "../../bin/ffigenpad.wasm?url";

function App() {
  onMount(async () => {
    const libclang = await createLibclang();

    globalThis.FS = libclang.FS;
    globalThis.addFunction = libclang.addFunction;
    globalThis.removeFunction = libclang.removeFunction;

    const module = new WebAssembly.Module(await (await fetch(wasm_url)).arrayBuffer());
    /** @type {WebAssembly.Instance} */
    const ffigenpad = await dart.instantiate(module, {
      ffi: {
        malloc: libclang.wasmExports.malloc,
        free: libclang.wasmExports.free,
        memory: libclang.wasmMemory,
      },
      libclang: libclang.wasmExports,
    });

    libclang.FS.writeFile(
      "/home/web_user/test.h",
      `
#include <stdint.h>
int64_t sum(int a, int b);`,
    );


    dart.invoke(ffigenpad, `
output: '/output.dart'
headers:
  entry-points:
    - '/home/web_user/test.h'
`);

    console.log(libclang.FS.readFile("/output.dart", {encoding: 'utf8'}));
  });

  return (
    <main>
      <h1>FFIgenPad</h1>
    </main>
  )
}

export default App
