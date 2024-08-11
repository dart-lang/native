import { TbBug, TbMoon, TbSun } from "solid-icons/tb";
import { createEffect, Show } from "solid-js";
import { Flex, HStack } from "styled-system/jsx";
import { $theme } from "~/lib/theme";
import { Heading } from "./ui/heading";
import { IconButton } from "./ui/icon-button";
import { Badge } from "./ui/badge";
import { Button } from "./ui/button";

const ThemeSwitcher = () => {
  const [darkMode, setDarkMode] = $theme.darkMode;

  createEffect(() => {
    if (darkMode()) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  });

  return (
    <IconButton onClick={() => setDarkMode((x) => !x)} variant="ghost">
      <Show when={darkMode()} fallback={<TbSun />}>
        <TbMoon />
      </Show>
    </IconButton>
  );
};

export const Navbar = () => {
  return (
    <HStack justify="space-between" pt="1" px="4" flexShrink={0}>
      <HStack>
        <Heading as="h1" textStyle="xl">
          FFIgenPad
        </Heading>
        <Badge>ffigen 14.0.0-wip</Badge>
        <Badge>libclang 18.1.8</Badge>
      </HStack>
      <HStack>
        <Button
          size="xs"
          variant="outline"
          asChild={(localProps) => (
            <a
              {...localProps()}
              // TODO: url redirects to pull request
              href="https://github.com/dart-lang/native/pull/1390"
              target="_blank"
            >
              <TbBug />
              Report a Bug
            </a>
          )}
        ></Button>
        <ThemeSwitcher />
      </HStack>
    </HStack>
  );
};
