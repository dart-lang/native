// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import TablerBrandGithub from '~icons/tabler/brand-github'
import TablerBug from '~icons/tabler/bug'
import TablerMoon from '~icons/tabler/moon'
import TablerSun from '~icons/tabler/sun'

import { Show } from "solid-js";
import { Divider, HStack } from "styled-system/jsx";
import { $theme } from "~/lib/theme";
import { Badge } from "third_party/ui/badge";
import { Button } from "third_party/ui/button";
import { Heading } from "third_party/ui/heading";
import { IconButton } from "third_party/ui/icon-button";

/*
 * Button that switches the theme
 */
const ThemeSwitcher = () => {
  const [darkMode, setDarkMode] = $theme.darkMode;

  return (
    <IconButton size="xs" onClick={() => setDarkMode((x) => !x)} variant="ghost">
      <Show when={darkMode()} fallback={<TablerMoon />}>
        <TablerSun />
      </Show>
    </IconButton>
  );
};

export const Navbar = () => {
  return (
    <HStack justify="space-between" px="4" py="2">
      <HStack>
        <Heading as="h1" textStyle="lg">
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
              href="https://github.com/dart-lang/native/pull/1390"
              target="_blank"
            >
              <TablerBug />
              Report a Bug
            </a>
          )}
        />
        <Divider orientation="vertical" mx="2" h="6" />
        <ThemeSwitcher />
        <IconButton
          variant="ghost"
          size="xs"
          asChild={(localProps) => (
            <a
              {...localProps()}
              href="https://github.com/dart-lang/native/tree/main/pkgs/ffigen"
              target="_blank"
            >
              <TablerBrandGithub />
            </a>
          )}
        />
      </HStack>
    </HStack>
  );
};
