import { createStore } from "solid-js/store";

export type FSNode = { [name: string]: FSNode | string };

export const $fileTree = createStore<FSNode>({
  "home/web_user": {
    "a.h": "a",
    "clang-c": {
      "b.h": "b",
    },
  },
});
