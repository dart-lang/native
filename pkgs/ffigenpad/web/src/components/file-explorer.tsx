import { basename, dirname, join } from "pathe";
import {
  TbChevronRight,
  TbFileDots,
  TbFilePlus,
  TbFileUpload,
  TbFolderPlus,
  TbTrash,
} from "solid-icons/tb";
import { createSignal, For, Show } from "solid-js";
import { Portal } from "solid-js/web";
import { HStack, Stack } from "styled-system/jsx";
import { treeView } from "styled-system/recipes";
import { $filesystem, type FSNode } from "~/lib/filesystem";
import { Button } from "./ui/button";
import { Dialog } from "./ui/dialog";
import { Drawer } from "./ui/drawer";
import { Editable } from "./ui/editable";
import { FileUpload } from "./ui/file-upload";
import { IconButton } from "./ui/icon-button";
import { Input } from "./ui/input";
import * as StyledTreeView from "./ui/styled/tree-view";
import { Text } from "./ui/text";

// need to include recipe to add styles for some reason
treeView();

/**
 * Displays MemFS files located at /home/web_user as file tree with the ability
 * to create, rename, delete files and folders
 */
const FileTree = () => {
  const { fileTree, helpers } = $filesystem;
  const [_, setSelectedFile] = $filesystem.selectedFile;

  // adds a file with the default name as 'file*.h'
  const addFile = (parentPathParts: string[], content = "") => {
    // get the contents of the folder where the files is being created
    const parentContents = helpers.getNode(parentPathParts) as FSNode;
    // find possible default name for new file
    let i = 1;
    while (`file${i}.h` in parentContents) i++;
    const name = `file${i}.h`;
    globalThis.FS.writeFile(
      join("/home/web_user", ...parentPathParts, name),
      content,
    );
  };

  // adds a folder with the default name as 'file*.h'
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

  // recursively deleted child files and folders
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

  // renames a file or a folder
  const renameEntity = (oldPath: string, newName: string) => {
    globalThis.FS.rename(
      join("/home/web_user", oldPath),
      join("/home/web_user", dirname(oldPath), newName),
    );
  };

  /**
   *
   * @param node Object in the fileTree represented as a [key, value] array
   * @param parentPathParts array of names of parent nodes
   */
  const renderNode = (
    node: [string, FSNode | string],
    parentPathParts: string[],
  ) => {
    const [name, children] = node;
    // ensures that all values are relative
    const pathParts =
      name === "/home/web_user" ? [] : [...parentPathParts, name];
    // it is path relative to /home/web_user in MemFS
    const path = pathParts.join("/");

    return (
      <Show
        when={typeof children !== "string"}
        fallback={
          // rendered when node is a file and the contents are a string
          <HStack gap="1">
            <StyledTreeView.Item value={path} flexGrow={1}>
              <Editable.Root
                activationMode="dblclick"
                value={name}
                onValueCommit={({ value }) => renameEntity(path, value)}
              >
                <Editable.Area>
                  <Editable.Input />
                  <StyledTreeView.ItemText
                    asChild={(localProps) => (
                      <Editable.Preview {...localProps()} />
                    )}
                  />
                </Editable.Area>
              </Editable.Root>
            </StyledTreeView.Item>

            <IconButton
              size="xs"
              variant="ghost"
              onClick={() => deleteFile(path)}
            >
              <TbTrash />
            </IconButton>
          </HStack>
        }
      >
        {/* rendered when node is a folder and children is an object */}
        <StyledTreeView.Branch value={path}>
          <HStack gap="1">
            <StyledTreeView.BranchControl flexGrow={1}>
              <StyledTreeView.BranchIndicator>
                <TbChevronRight />
              </StyledTreeView.BranchIndicator>
              <Editable.Root
                disabled={name === "/home/web_user"}
                activationMode="dblclick"
                value={name}
                onValueCommit={({ value }) => renameEntity(path, value)}
              >
                <Editable.Area>
                  <Editable.Input />
                  <StyledTreeView.BranchText
                    asChild={(localProps) => (
                      <Editable.Preview {...localProps()} />
                    )}
                  />
                </Editable.Area>
              </Editable.Root>
            </StyledTreeView.BranchControl>
            <HStack gap="0">
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => addFile(pathParts)}
              >
                <TbFilePlus />
              </IconButton>
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => addFolder(pathParts)}
              >
                <TbFolderPlus />
              </IconButton>
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => deleteFolder(path)}
              >
                <TbTrash />
              </IconButton>
            </HStack>
          </HStack>
          <StyledTreeView.BranchContent>
            <For each={Object.entries(children)}>
              {(child) => renderNode(child, pathParts)}
            </For>
          </StyledTreeView.BranchContent>
        </StyledTreeView.Branch>
      </Show>
    );
  };

  return (
    <StyledTreeView.Root
      aria-label="FileSystem"
      typeahead={false}
      defaultExpandedValue={[""]}
      defaultSelectedValue={["main.h"]}
      onSelectionChange={({ selectedValue }) => {
        // only open file in editor if the filename ends with .h
        if (selectedValue[0].endsWith(".h")) {
          setSelectedFile(`/home/web_user/${selectedValue[0]}`);
        }
      }}
    >
      <StyledTreeView.Tree>
        {/* /home/web_user should be used as the base for the tree */}
        <For each={Object.entries({ "/home/web_user": fileTree })}>
          {(child) => renderNode(child, [])}
        </For>
      </StyledTreeView.Tree>
    </StyledTreeView.Root>
  );
};

/*
 * A dialog box to upload multiple files from user at once to a specific directory
 */
function UploadFiles() {
  const [files, setFiles] = createSignal<File[]>([]);
  const [directory, setDirectory] = createSignal("");
  const [isLoading, setIsLoading] = createSignal(false);

  async function onConfirm() {
    setIsLoading(true);
    const directoryParts = directory()
      .split("/")
      .filter((p) => p.trim() !== "");
    let parentPath = "/home/web_user";

    for (const folder of directoryParts) {
      parentPath = join(parentPath, folder);
      globalThis.FS.mkdir(parentPath);
    }

    for (const file of files()) {
      const filePath = join(parentPath, file.name);
      globalThis.FS.writeFile(filePath, "");
      globalThis.FS.writeFile(filePath, await file.text());
    }
    setIsLoading(false);
  }

  return (
    <Dialog.Root>
      <Dialog.Trigger
        asChild={(triggerProps) => (
          <Button {...triggerProps()} size="sm" flexGrow={1}>
            <TbFileUpload />
            Upload Files
          </Button>
        )}
      />
      <Dialog.Backdrop />
      <Dialog.Positioner>
        <Dialog.Content>
          <Stack gap="4" p="6">
            <FileUpload.Root
              accept=".h"
              maxFiles={15}
              maxHeight="sm"
              overflowY="auto"
              onFileAccept={({ files }) => setFiles(files)}
            >
              <FileUpload.Dropzone minHeight="unset">
                <FileUpload.Label>Drop your header files here</FileUpload.Label>
                <FileUpload.Trigger
                  asChild={(triggerProps) => (
                    <Button size="sm" {...triggerProps()}>
                      Open Dialog
                    </Button>
                  )}
                />
              </FileUpload.Dropzone>
              <FileUpload.ItemGroup>
                <FileUpload.Context>
                  {(fileUpload) => (
                    <For each={fileUpload().acceptedFiles}>
                      {(file) => (
                        <FileUpload.Item file={file}>
                          <FileUpload.ItemName />
                          <FileUpload.ItemSizeText />
                          <FileUpload.ItemDeleteTrigger
                            asChild={(triggerProps) => (
                              <IconButton
                                variant="link"
                                size="sm"
                                {...triggerProps()}
                              >
                                <TbTrash />
                              </IconButton>
                            )}
                          />
                        </FileUpload.Item>
                      )}
                    </For>
                  )}
                </FileUpload.Context>
              </FileUpload.ItemGroup>
              <FileUpload.HiddenInput />
            </FileUpload.Root>
            <HStack>
              <Text>/home/web_user/</Text>
              <Input
                onChange={(e) => setDirectory(e.target.value)}
                value={directory()}
              />
            </HStack>
            <HStack>
              <Dialog.CloseTrigger
                asChild={(closeTriggerProps) => (
                  <Button {...closeTriggerProps()} variant="outline">
                    Cancel
                  </Button>
                )}
              />
              <Button width="full" onClick={onConfirm} loading={isLoading()}>
                Confirm
              </Button>
            </HStack>
          </Stack>
        </Dialog.Content>
      </Dialog.Positioner>
    </Dialog.Root>
  );
}

/**
 * Drawer that handles emscripten's MemFS filesystem as a tree
 */
const FileExplorer = () => {
  const [selectedFile] = $filesystem.selectedFile;
  return (
    <Drawer.Root>
      <Drawer.Trigger
        asChild={(triggerProps) => (
          <Button {...triggerProps()}>
            <TbFileDots />
            {basename(selectedFile())}
          </Button>
        )}
      />
      <Portal>
        <Drawer.Positioner>
          <Drawer.Content>
            <Drawer.Header>
              <Drawer.Title>Virtual FileSystem</Drawer.Title>
              <Drawer.Description>
                tip: double click to rename
              </Drawer.Description>
            </Drawer.Header>
            <Drawer.Body>
              <FileTree />
            </Drawer.Body>
            <Drawer.Footer justifyContent="stretch">
              <UploadFiles />
            </Drawer.Footer>
          </Drawer.Content>
        </Drawer.Positioner>
      </Portal>
    </Drawer.Root>
  );
};

export default FileExplorer;
