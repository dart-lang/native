import { createRoot, createSignal } from "solid-js";

const configSignal = () =>
  createSignal(`output: 'output.dart'
headers:
  entry-points:
    - '/home/web_user/main.h'
  `);

export const $ffigenConfig = createRoot(configSignal);
