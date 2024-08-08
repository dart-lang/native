import { useStore } from "@nanostores/solid";
import { createResource, onMount, Show } from "solid-js";
import { Box, Center, Container, Flex, HStack } from "styled-system/jsx";
import * as dart from "../../bin/ffigenpad.mjs";
import dartWasm from "../../bin/ffigenpad.wasm?url";
import createLibClang from "../../third_party/libclang/bin/libclang.mjs";
import { Header } from "./components/header";
import { LogsViewer } from "./components/logs-viewer";
import { Button } from "./components/ui/button";
import { Spinner } from "./components/ui/spinner";
import { Tabs } from "./components/ui/tabs";
import { $logs } from "./lib/log";

function FFIGenPad({ ffigenpad }: { ffigenpad: WebAssembly.Instance }) {
  const logs = useStore($logs);

  onMount(() => {
    console.log("mount");
    globalThis.FS.writeFile(
      "/home/web_user/test.h",
      `
#include <stdint.h>
int64_t sum(int a, int b);`,
    );
  });

  function generate() {
    dart.invoke(
      ffigenpad,
      `
output: '/output.dart'
headers:
  entry-points:
    - '/home/web_user/test.h'
    `,
    );
  }

  return (
    <HStack alignItems="start">
      <Tabs.Root defaultValue="files" variant="enclosed">
        <HStack justify="space-between">
          <Tabs.List>
            <Tabs.Trigger value="files">Files</Tabs.Trigger>
            <Tabs.Trigger value="config">Config</Tabs.Trigger>
            <Tabs.Indicator />
          </Tabs.List>
          <Button onClick={generate}>Generate</Button>
        </HStack>
        <Tabs.Content value="files">Files</Tabs.Content>
        <Tabs.Content value="config">Config</Tabs.Content>
      </Tabs.Root>
      <Tabs.Root defaultValue="bindings" variant="enclosed">
        <HStack>
          <Tabs.List>
            <Tabs.Trigger value="bindings">Bindings</Tabs.Trigger>
            <Tabs.Trigger value="logs">Logs ({logs().length})</Tabs.Trigger>
            <Tabs.Indicator />
          </Tabs.List>
        </HStack>

        <Tabs.Content value="bindings">Bindings</Tabs.Content>
        <Tabs.Content value="logs">
          <LogsViewer />
        </Tabs.Content>
      </Tabs.Root>
    </HStack>
  );
}

function App() {
  const [ffigenpad] = createResource(async () => {
    const libclang = await createLibClang();
    globalThis.FS = libclang.FS;
    globalThis.addFunction = libclang.addFunction;
    globalThis.removeFunction = libclang.removeFunction;

    console.log("Test");

    const module = new WebAssembly.Module(
      await (await fetch(dartWasm)).arrayBuffer(),
    );
    return (await dart.instantiate(module, {
      ffi: {
        malloc: libclang.wasmExports.malloc,
        free: libclang.wasmExports.free,
        memory: libclang.wasmMemory,
      },
      libclang: libclang.wasmExports,
    })) as WebAssembly.Instance;
  });

  return (
    <Flex
      direction="column"
      height="screen"
      maxHeight="screen"
      overflowY="auto"
      gap="2"
    >
      <Header />
      <Box flexGrow={1}>
        <Show
          when={!ffigenpad.loading}
          fallback={
            <Center height="full">
              <Spinner size="xl" />
            </Center>
          }
        >
          <Container>
            <FFIGenPad ffigenpad={ffigenpad()} />
          </Container>
        </Show>
      </Box>
    </Flex>
  );
}

export default App;
