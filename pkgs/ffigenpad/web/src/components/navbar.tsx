import { TbBrandGithub, TbBug, TbMoon, TbSun } from "solid-icons/tb";
import { Show } from "solid-js";
import { Divider, HStack } from "styled-system/jsx";
import { $theme } from "~/lib/theme";
import { Badge } from "./ui/badge";
import { Button } from "./ui/button";
import { Heading } from "./ui/heading";
import { IconButton } from "./ui/icon-button";

/*
 * Button that switches the theme
 */
const ThemeSwitcher = () => {
  const [darkMode, setDarkMode] = $theme.darkMode;

  return (
    <IconButton onClick={() => setDarkMode((x) => !x)} variant="ghost">
      <Show when={darkMode()} fallback={<TbMoon />}>
        <TbSun />
      </Show>
    </IconButton>
  );
};

export const Navbar = () => {
  return (
    <Divider
      display="flex"
      justifyContent="space-between"
      alignItems="center"
      px="4"
      mb="1.5"
    >
      <HStack>
        <Heading as="h1" textStyle="xl">
          FFIgenPad
        </Heading>
        <Badge>ffigen 14.0.0-wip</Badge>
        <Badge>libclang 18.1.8</Badge>
      </HStack>
      <HStack gap="0">
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
        />
        <Divider orientation="vertical" h="6" mx="3" />
        <ThemeSwitcher />
        <IconButton
          variant="ghost"
          asChild={(localProps) => (
            <a
              {...localProps()}
              href="https://github.com/dart-lang/native/tree/main/pkgs/ffigen"
              target="_blank"
            >
              <TbBrandGithub />
            </a>
          )}
        />
      </HStack>
    </Divider>
  );
};
