import { useStore } from "@nanostores/solid";
import { createResource, createSignal, Show } from "solid-js";
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
import { ConfigEditor } from "./components/config-editor";
import { BindingsViewer } from "./components/bindings-viewer";
import { $bindings } from "./lib/bindings";
import { $ffigenConfig } from "./lib/ffigen-config";
import { $headers } from "./lib/headers";
import { HeaderEditor } from "./components/header-editor";

function FFIGenPad({ ffigenpad }: { ffigenpad: WebAssembly.Instance }) {
  const logs = useStore($logs);
  const ffigenConfig = useStore($ffigenConfig);
  const headers = useStore($headers);
  const [loading, setLoading] = createSignal(false);
  function generate() {
    setLoading(true);
    globalThis.FS.writeFile("/home/web_user/main.h", headers());
    $logs.set([]);
    dart.invoke(ffigenpad, ffigenConfig());
    $bindings.set(globalThis.FS.readFile("/output.dart", { encoding: "utf8" }));
    setLoading(false);
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
          <Button loading={loading()} onClick={generate}>
            Generate
          </Button>
        </HStack>
        <Tabs.Content value="files">
          <HeaderEditor />
        </Tabs.Content>
        <Tabs.Content value="config">
          <ConfigEditor />
        </Tabs.Content>
      </Tabs.Root>
      <Tabs.Root defaultValue="bindings" variant="enclosed">
        <HStack>
          <Tabs.List>
            <Tabs.Trigger value="bindings">Bindings</Tabs.Trigger>
            <Tabs.Trigger value="logs">Logs ({logs().length})</Tabs.Trigger>
            <Tabs.Indicator />
          </Tabs.List>
        </HStack>

        <Tabs.Content value="bindings">
          <BindingsViewer />
        </Tabs.Content>
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
    globalThis.setLogs = $logs.set;

    const module = new WebAssembly.Module(
      await (await fetch(dartWasm)).arrayBuffer(),
    );
    const instance: WebAssembly.Instance = await dart.instantiate(module, {
      ffi: {
        malloc: libclang.wasmExports.malloc,
        free: libclang.wasmExports.free,
        memory: libclang.wasmMemory,
      },
      libclang: libclang.wasmExports,
    });
    return instance;
  });

  return (
    <Flex direction="column" gap="2" height="screen">
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
