import {
  TbChevronRight,
  TbFileDots,
  TbFilePlus,
  TbFileUpload,
  TbFolderPlus,
  TbTrash,
} from "solid-icons/tb";
import { For, Show } from "solid-js";
import { Portal } from "solid-js/web";
import { HStack } from "styled-system/jsx";
import { treeView } from "styled-system/recipes";
import { $filesystem, type FSNode } from "~/lib/filesystem";
import { Button } from "./ui/button";
import { Drawer } from "./ui/drawer";
import { Editable } from "./ui/editable";
import { IconButton } from "./ui/icon-button";
import * as StyledTreeView from "./ui/styled/tree-view";
import { basename } from "pathe";

// need to include recipe to add styles for some reason
treeView();

const FileTree = () => {
  const { fileTree, helpers } = $filesystem;
  const [_, setSelectedFile] = $filesystem.selectedFile;

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
                onValueCommit={({ value }) => helpers.renameEntity(path, value)}
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
              onClick={() => helpers.deleteFile(path)}
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
                onValueCommit={({ value }) => helpers.renameEntity(path, value)}
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
                onClick={() => helpers.addFile(pathParts)}
              >
                <TbFilePlus />
              </IconButton>
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => helpers.addFolder(pathParts)}
              >
                <TbFolderPlus />
              </IconButton>
              <IconButton
                size="xs"
                variant="ghost"
                onClick={() => helpers.deleteFolder(path)}
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
        if (selectedValue[0].endsWith(".h")) {
          setSelectedFile(`/home/web_user/${selectedValue[0]}`);
        }
      }}
    >
      <StyledTreeView.Tree>
        <For each={Object.entries({ "/home/web_user": fileTree })}>
          {(child) => renderNode(child, [])}
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
