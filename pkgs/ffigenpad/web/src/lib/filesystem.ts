import { createRoot, createSignal } from "solid-js";
import { createStore, produce } from "solid-js/store";

export type FSNode = { [name: string]: FSNode | string };

const filesystemStore = () => {
  const selectedFile = createSignal("/home/web_user/main.h");
  const [fileTree, setFileTree] = createStore<FSNode>({
    "home/web_user": {
      "main.h": "int sum(int a, int b);",
      "clang-c": {
        "b.h": "b",
      },
    },
  });

  /**
   * Performs commong file operations in both, MemFS and frontend
   */
  const helpers = {
    addFile: (parentPath: string) => {
      const parts = filePathSegments(parentPath);

      const parentContents: FSNode = parts.reduce(
        (acc, current) => acc[current],
        fileTree["home/web_user"],
      );

      let i = 1;
      while (`file${i}.h` in parentContents) {
        i++;
      }
      const name = `file${i}.h`;
      console.log(`${parentPath}/${name}`);
      globalThis.FS.writeFile(`${parentPath}/${name}`, "");
      setFileTree("home/web_user", ...(parts as []), {
        [name]: "",
      });
    },

    addFolder: (parentPath: string) => {
      const parts = filePathSegments(parentPath);

      const parentContents: FSNode = parts.reduce(
        (acc, current) => acc[current],
        fileTree["home/web_user"],
      );

      let i = 1;
      while (`folder${i}` in parentContents) {
        i++;
      }
      const name = `folder${i}`;
      globalThis.FS.mkdir(`${parentPath}/${name}`);
      setFileTree("home/web_user", ...(parts as []), {
        [name]: {},
      });
    },

    deleteEntity: (entityPath: string) => {
      const parts = filePathSegments(entityPath);
      setFileTree("home/web_user", ...(parts as []), undefined);
    },

    renameEntity: (oldPath: string, newName: string) => {
      const parts = filePathSegments(oldPath);
      const oldName = parts.at(-1);
      const parentPathParts = parts.slice(0, -1);
      globalThis.FS.rename(
        oldPath,
        `/home/web_user/${parentPathParts.join("/")}/${newName}`,
      );
      setFileTree(
        "home/web_user",
        ...(parentPathParts as []),
        produce((parent) => {
          parent[newName] = parent[oldName];
          parent[oldName] = undefined;
        }),
      );
    },
  };

  return { fileTree: [fileTree, setFileTree] as const, selectedFile, helpers };
};

export const $filesystem = createRoot(filesystemStore);

/**
 * Returns an array of path segments relative to /home/web_user
 */
export const filePathSegments = (entityPath: string) => {
  return entityPath.split("/").slice(3);
};

export const writeToMemFS = (fileTree: FSNode) => {
  const FS = globalThis.FS;

  console.log(FS.readdir("/home/web_user"));
};
