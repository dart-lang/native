package com.github.dart_lang.jnigen.apisummarizer;

import static com.github.dart_lang.jnigen.apisummarizer.util.ClassFinder.findClassAndChildren;
import static com.github.dart_lang.jnigen.apisummarizer.util.ClassFinder.isNestedClassOf;
import static org.junit.Assert.*;

import java.util.*;
import java.util.stream.Collectors;
import org.junit.Test;

public class ClassFinderTest {
  @Test
  public void testNestedClassCheck() {
    assertTrue(
        "Single nested class",
        isNestedClassOf("com/abc/Class$Nested.class", "com/abc/Class", ".class"));
    assertTrue(
        "Nested twice",
        isNestedClassOf("com/abc/Class$Nested$Twice.class", "com/abc/Class", ".class"));
    assertTrue(
        "Single nested class - backslash separator",
        isNestedClassOf("com\\abc\\Class$Nested.class", "com\\abc\\Class", ".class"));
    assertFalse(
        "Anon inner class", isNestedClassOf("com/abc/Class$1.class", "com/abc/Class", ".class"));
    assertFalse(
        "Anon inner class inside nested class",
        isNestedClassOf("com/abc/Class$Nested$1.class", "com/abc/Class", ".class"));
    assertFalse(
        "Different class name",
        isNestedClassOf("com/abc/AClass$Nested.class", "com/abc/Class", ".class"));
  }

  private Optional<List<String>> pathListOf(String sep, String... paths) {
    List<String> pathList =
        Arrays.stream(paths).map(path -> path.replace("/", sep)).collect(Collectors.toList());
    return Optional.of(pathList);
  }

  @Test
  public void testFindChildren() {
    TreeSet<String> entriesWithSlash =
        new TreeSet<>(
            List.of(
                "random/os/App.class",
                "random/os/App$1.class",
                "random/os/App$1$3.class",
                "random/os/Process.class",
                "random/os/Process$Fork.class",
                "random/os/Process$Fork$1.class",
                "random/os/Process$Fork$A$B$C$2.class",
                "random/widget/Dialog.class",
                "random/widget/Dialog$Button.class",
                "random/widget/Dialog$Button$2.class",
                "random/widget/Dialog$Button$Color.class",
                "random/widget/Dialogue$Button.class",
                "random/time/Clock.class",
                "random/time/Clock$1.class",
                "random/time/Calendar.class",
                "random/time/Calendar$Month$1.class",
                "random/time/Calendar$Month.class"));
    TreeSet<String> entriesWithBackslash =
        entriesWithSlash.stream()
            .map(x -> x.replace('/', '\\'))
            .collect(Collectors.toCollection(TreeSet::new));
    Map<String, TreeSet<String>> bySeparater =
        Map.of("/", entriesWithSlash, "\\", entriesWithBackslash);

    for (var sep : bySeparater.keySet()) {
      var entries = bySeparater.get(sep);
      assertEquals(
          pathListOf(sep, "random/os/Process$Fork.class", "random/os/Process.class"),
          findClassAndChildren(entries, "random.os.Process", sep, ".class"));
      assertEquals(
          pathListOf(
              sep,
              "random/time/Calendar$Month.class",
              "random/time/Calendar.class",
              "random/time/Clock.class"),
          findClassAndChildren(entries, "random.time", sep, ".class"));
      assertEquals(
          pathListOf(
              sep,
              "random/widget/Dialog$Button$Color.class",
              "random/widget/Dialog$Button.class",
              "random/widget/Dialog.class"),
          findClassAndChildren(entries, "random.widget.Dialog", sep, ".class"));
      assertEquals(
          pathListOf(sep, "random/os/App.class"),
          findClassAndChildren(entries, "random.os.App", sep, ".class"));
      assertEquals(
          pathListOf(sep, "random/os/App.class"),
          findClassAndChildren(entries, "random.os.App", sep, ".class"));
    }
  }
}
