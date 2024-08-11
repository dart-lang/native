import {
  TbChevronRight,
  TbFileDots,
  TbFilePlus,
  TbFileUpload,
  TbFolderPlus,
  TbTrash,
} from "solid-icons/tb";
import { For, Show } from "solid-js";
import { HStack } from "styled-system/jsx";
import { Drawer } from "./ui/drawer";
import { Editable } from "./ui/editable";
import { IconButton } from "./ui/icon-button";
import * as StyledTreeView from "./ui/styled/tree-view";
import { treeView } from "styled-system/recipes";
import { $filesystem, type FSNode } from "~/lib/filesystem";
import { produce } from "solid-js/store";
import { Button } from "./ui/button";
import { Portal } from "solid-js/web";

// need to include recipe to add styles for some reason
treeView();

const FileTree = () => {
  const [fileTree, setFileTree] = $filesystem.fileTree;
  const [_, setSelectedFile] = $filesystem.selectedFile;

  const addFile = (parentPath: string) => {
    // get the contents of the folder where the files is being created
    const parentContents = parentPath
      .split("/")
      .reduce((acc, current) => acc[current], fileTree) as FSNode;
    // find possible default name for new file
    let i = 1;
    while (`file${i}.h` in parentContents) i++;
    const name = `file${i}.h`;
    globalThis.FS.writeFile(`/${parentPath}/${name}`, "");
  };

  const addFolder = (parentPath: string) => {
    // get the contents of the parent folder
    const parentContents = parentPath
      .split("/")
      .reduce((acc, current) => acc[current], fileTree) as FSNode;
    // find possible default name for new folder
    let i = 1;
    while (`folder${i}` in parentContents) i++;
    const name = `folder${i}`;
    globalThis.FS.mkdir(`/${parentPath}/${name}`);
  };

  const deleteFile = (filePath: string) => {
    globalThis.FS.unlink(`/${filePath}`);
  };

  const deleteFolder = (folderPath: string) => {
    // get the contents of the folder being deleted
    const contents = globalThis.FS.readdir(`/${folderPath}`).slice(2);
    // recursive delete all content in the folder so it is empty
    for (const node of contents) {
      const nodePath = `${folderPath}/${node}`;
      const mode = globalThis.FS.stat(`/${nodePath}`).mode;
      if (globalThis.FS.isFile(mode)) {
        deleteFile(nodePath);
      } else {
        deleteFolder(nodePath);
      }
    }
    // finally remove the empty folder
    globalThis.FS.rmdir(`/${folderPath}`);
  };

  const renameEntity = (oldPath: string, newName: string) => {
    const parts = oldPath.split("/");
    // the old filename/foldername for the entity
    const oldName = parts.at(-1);
    // path segments to the entity's parent
    const parentParts = parts.slice(0, -1) as [];

    globalThis.FS.rename(`/${oldPath}`, `/${parentParts.join("/")}/${newName}`);
    // this is easier than adding a FS trackingDelegate for rename
    setFileTree(
      ...parentParts,
      produce((node) => {
        node[newName] = node[oldName];
        node[oldName] = undefined;
      }),
    );
  };

  const renderChild = (
    [name, content]: [string, FSNode | string],
    parent: string,
  ) => {
    // Its the same as the absolute path in the FS except without a leading '/'
    const entityPath = `${parent}/${name}`;

    return (
      <Show
        when={typeof content !== "string"}
        fallback={
          <HStack gap="1">
            <StyledTreeView.Item value={entityPath} flexGrow={1}>
              <Editable.Root
                activationMode="dblclick"
                value={name}
                onValueCommit={({ value }) => renameEntity(entityPath, value)}
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
              onClick={() => deleteFile(entityPath)}
            >
              <TbTrash />
            </IconButton>
          </HStack>
        }
      >
        <StyledTreeView.Branch value={entityPath}>
          <HStack gap="1">
            <StyledTreeView.BranchControl flexGrow={1}>
              <StyledTreeView.BranchIndicator>
                <TbChevronRight />
              </StyledTreeView.BranchIndicator>
              <Editable.Root
                disabled={name === "web_user"}
                activationMode="dblclick"
                value={name === "web_user" ? "/home/web_user" : name}
                onValueCommit={({ value }) => renameEntity(entityPath, value)}
              >
                <Editable.Area>
                  <Editable.Input />
                  <StyledTreeView.BranchText>
                    <Editable.Preview />
                  </StyledTreeView.BranchText>
                </Editable.Area>
              </Editable.Root>
            </StyledTreeView.BranchControl>
            <HStack gap="0">
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => addFile(entityPath)}
              >
                <TbFilePlus />
              </IconButton>
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => addFolder(entityPath)}
              >
                <TbFolderPlus />
              </IconButton>
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => deleteFolder(entityPath)}
              >
                <TbTrash />
              </IconButton>
            </HStack>
          </HStack>
          <StyledTreeView.BranchContent>
            <For each={Object.entries(content)}>
              {(child) => renderChild(child, entityPath)}
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
      defaultExpandedValue={["home/web_user"]}
      defaultSelectedValue={["home/web_user/main.h"]}
      onSelectionChange={({ selectedValue }) => {
        if (selectedValue[0].endsWith(".h")) {
          setSelectedFile(`/${selectedValue[0]}`);
        }
      }}
    >
      <StyledTreeView.Tree>
        <For each={Object.entries(fileTree["home"])}>
          {(child) => renderChild(child, "home")}
        </For>
      </StyledTreeView.Tree>
    </StyledTreeView.Root>
  );
};

const FileExplorer = () => {
  const [selectedFile] = $filesystem.selectedFile;
  return (
    <Drawer.Root variant="left">
      <Drawer.Trigger
        asChild={(triggerProps) => (
          <Button {...triggerProps()}>
            <TbFileDots />
            {selectedFile().substring(selectedFile().lastIndexOf("/") + 1)}
          </Button>
        )}
      />
      <Portal>
        <Drawer.Positioner>
          <Drawer.Content>
            <Drawer.Header>
              <Drawer.Title>Virtual FileSystem</Drawer.Title>
              <Drawer.Description>
                Tip: double click to rename
              </Drawer.Description>
            </Drawer.Header>
            <Drawer.Body>
              <FileTree />
            </Drawer.Body>
            <Drawer.Footer justifyContent="stretch">
              <Button size="sm" flexGrow={1}>
                <TbFileUpload />
                Upload Files
              </Button>
            </Drawer.Footer>
          </Drawer.Content>
        </Drawer.Positioner>
      </Portal>
    </Drawer.Root>
  );
};

export default FileExplorer;
