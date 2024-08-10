import { createRoot, createSignal, onMount } from "solid-js";
import { createStore } from "solid-js/store";

export type FSNode = { [name: string]: FSNode | string };

const filesystemStore = () => {
  const selectedFile = createSignal("/home/web_user/main.h");
  const fileTree = createStore<FSNode>({
    home: {
      web_user: {
        "main.h": "int sum(int a, int b);",
      },
    },
  });

  return { fileTree: fileTree, selectedFile };
};

export const $filesystem = createRoot(filesystemStore);

export function registerMemFSTrackers() {
  const [fileTree, setFileTree] = $filesystem.fileTree;
  onMount(() => {
    globalThis.FS.writeFile(
      "/home/web_user/main.h",
      fileTree["home"]["web_user"]["main.h"],
    );

    globalThis.FS.trackingDelegate["onMakeDirectory"] = (path: string) => {
      if (path.startsWith("/home/web_user")) {
        const parts = path.substring(1).split("/") as [];
        setFileTree(...parts, {});
      }
    };

    globalThis.FS.trackingDelegate["onDeletePath"] = (path: string) => {
      if (path.startsWith("/home/web_user")) {
        const parts = path.substring(1).split("/") as [];
        console.log({ path, parts });
        setFileTree(...parts, undefined);
      }
    };

    globalThis.FS.trackingDelegate["onWriteToFile"] = function (
      path: string,
      bytesWritten: number,
    ) {
      if (bytesWritten === 0 && path.startsWith("/home/web_user")) {
        const parts = path.substring(1).split("/") as [];
        setFileTree(
          ...parts,
          globalThis.FS.readFile(path, { encoding: "utf8" }),
        );
      }
    };
  });
}
