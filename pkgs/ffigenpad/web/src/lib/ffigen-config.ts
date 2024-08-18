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
