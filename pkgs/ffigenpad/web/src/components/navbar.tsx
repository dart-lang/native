import { Flex, HStack } from "styled-system/jsx";
import { Heading } from "./ui/heading";
import { Button } from "./ui/button";
import { IconButton } from "./ui/icon-button";
import { $theme } from "~/lib/theme";
import { createEffect, Show } from "solid-js";
import { TbMoon, TbSun } from "solid-icons/tb";

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
    <Flex justify="space-between" align="center" pt="1" px="4" flexShrink={0}>
      <Heading as="h1" textStyle="xl">
        FFIgenPad
      </Heading>
      <ThemeSwitcher />
    </Flex>
  );
};
