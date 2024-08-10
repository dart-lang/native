import {
  TbChevronRight,
  TbFileDots,
  TbFilePlus,
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

// need to include recipie for some reason
treeView();

const FileTree = () => {
  const [fileTree, setFileTree] = $filesystem.fileTree;
  const [selectedFile, setSelectedFile] = $filesystem.selectedFile;

  const addFile = (parentPath: string) => {
    const parentContents = parentPath
      .split("/")
      .reduce((acc, current) => acc[current], fileTree) as FSNode;
    console.log(parentPath);
    let i = 1;
    while (`file${i}.h` in parentContents) i++;
    const name = `file${i}.h`;
    globalThis.FS.writeFile(`/${parentPath}/${name}`, "");
  };

  const addFolder = (parentPath: string) => {
    const parentContents = parentPath
      .split("/")
      .reduce((acc, current) => acc[current], fileTree) as FSNode;

    let i = 1;
    while (`folder${i}` in parentContents) i++;
    const name = `folder${i}`;
    globalThis.FS.mkdir(`/${parentPath}/${name}`);
  };

  const deleteFile = (filePath: string) => {
    globalThis.FS.unlink(`/${filePath}`);
  };

  const deleteFolder = (folderPath: string) => {
    const contents = globalThis.FS.readdir(`/${folderPath}`).slice(2);
    for (const node of contents) {
      const nodePath = `${folderPath}/${node}`;
      const mode = globalThis.FS.stat(`/${nodePath}`).mode;
      if (globalThis.FS.isFile(mode)) {
        deleteFile(nodePath);
      } else {
        deleteFolder(nodePath);
      }
    }
    globalThis.FS.rmdir(`/${folderPath}`);
  };

  const renameEntity = (oldPath: string, newName: string) => {
    const parts = oldPath.split("/");
    const oldName = parts.at(-1);
    const parentParts = parts.slice(0, -1) as [];
    globalThis.FS.rename(`/${oldPath}`, `/${parentParts.join("/")}/${newName}`);
    console.log({ parts, oldName, newName });
    setFileTree(
      ...parentParts,
      produce((node) => {
        node[newName] = node[oldName];
        node[oldName] = undefined;
      }),
    );
    console.log(fileTree);
  };

  const renderChild = (
    [name, content]: [string, FSNode | string],
    parent: string,
  ) => {
    const entityPath = `${parent}/${name}`;
    return (
      <Show
        when={typeof content !== "string"}
        fallback={
          <HStack justify="space-between">
            <StyledTreeView.Item value={entityPath}>
              <Editable.Root
                activationMode="dblclick"
                value={name}
                onValueCommit={({ value }) => renameEntity(entityPath, value)}
              >
                <Editable.Area>
                  <Editable.Input />
                  <StyledTreeView.ItemText>
                    <Editable.Preview />
                  </StyledTreeView.ItemText>
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
          <HStack justify="space-between">
            <StyledTreeView.BranchControl>
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
      defaultSelectedValue={[selectedFile().substring(1)]}
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

export const FileExplorer = () => {
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
      <Drawer.Positioner>
        <Drawer.Content>
          <Drawer.Header>
            <Drawer.Title>FileSystem</Drawer.Title>
            <Drawer.Description>Tip: double click to rename</Drawer.Description>
          </Drawer.Header>
          <Drawer.Body>
            <FileTree />
          </Drawer.Body>
        </Drawer.Content>
      </Drawer.Positioner>
    </Drawer.Root>
  );
};
