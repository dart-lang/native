import { createRoot, createSignal } from "solid-js";

const bindingsSignal = () =>
  createSignal("// Click on generate to see the magic");

export const $bindings = createRoot(bindingsSignal);
