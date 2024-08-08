import { Container, Divider, Flex, HStack } from "styled-system/jsx";
import { Heading } from "./ui/heading";

export const Header = () => {
  return (
    <Divider py="2">
      <Container>
        <Flex align="center" justify="space-between">
          <Heading as="h1" textStyle="2xl">
            FFIgenPad
          </Heading>
          <HStack>hello</HStack>
        </Flex>
      </Container>
    </Divider>
  );
};
