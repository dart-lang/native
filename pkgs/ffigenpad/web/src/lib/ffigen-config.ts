import { createRoot, createSignal } from "solid-js";

const configSignal = () =>
  createSignal(`output: 'output.dart' # DO NOT CHANGE OUTPUT PATH
name: 'CoolLibName'
description: 'cool library bindings!'
headers:
  entry-points:
    - '/home/web_user/main.h'
  `);

export const $ffigenConfig = createRoot(configSignal);
