import { useStore } from "@nanostores/solid";
import { TbInfoCircleFilled } from "solid-icons/tb";
import { createResource, createSignal, Show } from "solid-js";
import { Center, Flex, HStack, Stack } from "styled-system/jsx";
import * as dart from "../../bin/ffigenpad.mjs";
import dartWasm from "../../bin/ffigenpad.wasm?url";
import createLibClang from "../../third_party/libclang/bin/libclang.mjs";
import { BindingsViewer } from "./components/bindings-viewer";
import { ConfigEditor } from "./components/config-editor";
import { HeaderEditor } from "./components/header-editor";
import { LogsViewer } from "./components/logs-viewer";
import { Navbar } from "./components/navbar";
import { Button } from "./components/ui/button";
import { IconButton } from "./components/ui/icon-button";
import { Spinner } from "./components/ui/spinner";
import { Splitter } from "./components/ui/splitter";
import { Tabs } from "./components/ui/tabs";
import { Text } from "./components/ui/text";
import { $bindings } from "./lib/bindings";
import { $ffigenConfig } from "./lib/ffigen-config";
import { $headers } from "./lib/headers";
import { $logs } from "./lib/log";
import { FileExplorer } from "./components/file-explorer";

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
    <Splitter.Root
      defaultSize={[{ id: "input" }, { id: "output" }]}
      height="full"
      px="2"
    >
      <Splitter.Panel id="input">
        <Tabs.Root defaultValue="headers" variant="enclosed">
          <HStack justify="space-between">
            <HStack gap="2">
              <FileExplorer />
              <Tabs.List>
                <Tabs.Trigger value="headers">Headers</Tabs.Trigger>
                <Tabs.Trigger value="config">Config</Tabs.Trigger>
                <Tabs.Indicator />
              </Tabs.List>
            </HStack>
            <HStack gap="2">
              <IconButton
                variant="outline"
                asChild={(link) => (
                  <a
                    {...link()}
                    href="https://github.com/dart-lang/native/tree/main/pkgs/ffigen#configurations"
                    target="_blank"
                  >
                    <TbInfoCircleFilled />
                  </a>
                )}
              ></IconButton>
              <Button loading={loading()} onClick={generate}>
                Generate
              </Button>
            </HStack>
          </HStack>
          <Tabs.Content value="headers">
            <HeaderEditor />
          </Tabs.Content>
          <Tabs.Content value="config">
            <ConfigEditor />
          </Tabs.Content>
        </Tabs.Root>
      </Splitter.Panel>
      <Splitter.ResizeTrigger id="input:output" />
      <Splitter.Panel id="output">
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
      </Splitter.Panel>
    </Splitter.Root>
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
    <Flex direction="column" height="screen">
      <Navbar />
      <Show
        when={!ffigenpad.loading}
        fallback={
          <Center flexGrow={1} height="full">
            <Stack alignItems="center" gap="6">
              <Spinner size="xl" />
              <Text>ffigenpad might take some time to load</Text>
            </Stack>
          </Center>
        }
      >
        <FFIGenPad ffigenpad={ffigenpad()} />
      </Show>
    </Flex>
  );
}

export default App;
