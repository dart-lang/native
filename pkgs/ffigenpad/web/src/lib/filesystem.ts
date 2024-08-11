import { join, dirname } from "pathe";
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

  const addFile = (parentPathParts: string[], content = "") => {
    // get the contents of the folder where the files is being created
    const parentContents = getNode(parentPathParts) as FSNode;
    // find possible default name for new file
    let i = 1;
    while (`file${i}.h` in parentContents) i++;
    const name = `file${i}.h`;
    globalThis.FS.writeFile(
      join("/home/web_user", ...parentPathParts, name),
      content,
    );
  };

  const addFolder = (parentPathParts: string[]) => {
    // get the contents of the parent folder
    const parentContents = helpers.getNode(parentPathParts) as FSNode;
    // find possible default name for new folder
    let i = 1;
    while (`folder${i}` in parentContents) i++;
    const name = `folder${i}`;
    globalThis.FS.mkdir(join("/home/web_user", ...parentPathParts, name));
  };

  const deleteFile = (filePath: string) => {
    globalThis.FS.unlink(join("/home/web_user", filePath));
  };

  const deleteFolder = (folderPath: string) => {
    // get the contents of the folder being deleted
    const contents = globalThis.FS.readdir(
      join("/home/web_user", folderPath),
    ).slice(2);
    // recursively delete all content in the folder so it is empty
    for (const node of contents) {
      const treeValue = `${folderPath}/${node}`;
      const mode = globalThis.FS.stat(join("/home/web_user/", treeValue)).mode;
      if (globalThis.FS.isFile(mode)) {
        deleteFile(treeValue);
      } else if (globalThis.FS.isDir(mode)) {
        deleteFolder(treeValue);
      }
    }
    // finally remove the empty folder
    globalThis.FS.rmdir(join("/home/web_user", folderPath));
  };

  const renameEntity = (oldPath: string, newName: string) => {
    globalThis.FS.rename(
      join("/home/web_user", oldPath),
      join("/home/web_user", dirname(oldPath), newName),
    );
  };

  const helpers = {
    getNode,
    addFile,
    addFolder,
    deleteFile,
    deleteFolder,
    renameEntity,
  };

  return { fileTree, selectedFile, helpers };
};

export const $filesystem = createRoot(filesystemStore);

export function registerMemFSTrackers() {
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
