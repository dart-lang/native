import { batch, createRoot, createSignal, onMount } from "solid-js";
import { createMutable } from "solid-js/store";

export type FSNode = { [name: string]: FSNode | string };

const filesystemStore = () => {
  const selectedFile = createSignal("/home/web_user/main.h");
  const fileTree = createMutable<FSNode>({
    "main.h": "int sum(int a, int b);",
  });

  /**
   * Returns a mutable fileTree node
   * @param pathParts array of keys of parents in fileTree
   */
  const getNode = (pathParts: string[]) =>
    pathParts.reduce((node, key) => node[key], fileTree);

  const helpers = {
    getNode,
  };

  return { fileTree, selectedFile, helpers };
};

export const $filesystem = createRoot(filesystemStore);

/* register FS event listeners so to reflect changes onto the file explorer */
export function registerMemFSListeners() {
  const { fileTree, helpers } = $filesystem;

  onMount(() => {
    globalThis.FS.writeFile("/home/web_user/main.h", fileTree["main.h"]);

    globalThis.FS.trackingDelegate["onMakeDirectory"] = (
      entityPath: string,
    ) => {
      if (entityPath.startsWith("/home/web_user")) {
        const parts = entityPath.substring("/home/web_user/".length).split("/");
        const parentFolder = helpers.getNode(parts.slice(0, -1));
        parentFolder[parts.at(-1)] = {};
      }
    };

    globalThis.FS.trackingDelegate["onDeletePath"] = (entityPath: string) => {
      if (entityPath.startsWith("/home/web_user")) {
        const parts = entityPath.substring("/home/web_user/".length).split("/");
        const parentFolder = helpers.getNode(parts.slice(0, -1));
        parentFolder[parts.at(-1)] = undefined;
      }
    };

    globalThis.FS.trackingDelegate["onWriteToFile"] = function (
      entityPath: string,
      bytesWritten: number,
    ) {
      if (bytesWritten === 0 && entityPath.startsWith("/home/web_user")) {
        const parts = entityPath.substring("/home/web_user/".length).split("/");
        const parentFolder = helpers.getNode(parts.slice(0, -1));
        parentFolder[parts.at(-1)] = "";
      }
    };

    globalThis.FS.trackingDelegate["onMovePath"] = function (
      oldPath: string,
      newPath: string,
    ) {
      if (newPath.startsWith("/home/web_user")) {
        const oldPathParts = oldPath
          .substring("/home/web_user/".length)
          .split("/");
        const newPathParts = newPath
          .substring("/home/web_user/".length)
          .split("/");
        const oldName = oldPathParts.at(-1);
        const newName = newPathParts.at(-1);
        const oldParent = helpers.getNode(oldPathParts.slice(0, -1));
        const newParent = helpers.getNode(newPathParts.slice(0, -1));

        batch(() => {
          newParent[newName] = oldParent[oldName];
          oldParent[oldName] = undefined;
        });
      }
    };
  });
}
