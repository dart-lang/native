package com.github.dart_lang.jnigen.apisummarizer;

import java.io.PrintWriter;
import java.util.Arrays;
import org.apache.commons.cli.*;

public class SummarizerOptions {
  private static final CommandLineParser parser = new DefaultParser();
  String sourcePath;
  String classPath;
  boolean useModules;
  Main.Backend backend;
  String modulesList;
  String toolArgs;
  boolean verbose;
  String outputFile;
  String[] args;

  SummarizerOptions() {}

  public static SummarizerOptions fromCommandLine(CommandLine cmd) {
    var opts = new SummarizerOptions();
    opts.sourcePath = cmd.getOptionValue("sources", null);
    var backendString = cmd.getOptionValue("backend", "auto");
    opts.backend = Main.Backend.valueOf(backendString.toUpperCase());
    opts.classPath = cmd.getOptionValue("classes", null);
    opts.useModules = cmd.hasOption("use-modules");
    opts.modulesList = cmd.getOptionValue("module-names", null);
    opts.toolArgs = cmd.getOptionValue("doctool-args", null);
    opts.outputFile = cmd.getOptionValue("output-file", null);
    opts.args = cmd.getArgs();
    if (opts.args.length == 0) {
      throw new IllegalArgumentException("Need one or more class or package names as arguments");
    }
    return opts;
  }

  public static SummarizerOptions parseArgs(String[] args) {
    var options = new Options();
    Option sources = new Option("s", "sources", true, "paths to search for source files");
    Option classes = new Option("c", "classes", true, "paths to search for compiled classes");
    Option backend =
        new Option(
            "b",
            "backend",
            true,
            "backend to use for summary generation ('doclet', 'asm' or 'auto' (default)).");
    Option useModules = new Option("M", "use-modules", false, "use Java modules");
    Option moduleNames =
        new Option("m", "module-names", true, "comma separated list of module names");
    Option doctoolArgs =
        new Option("D", "doctool-args", true, "arguments to pass to the documentation tool");
    Option outputFile =
        new Option("o", "output-file", true, "write JSON to file instead of stdout");
    Option[] allOptions = {
      sources, classes, backend, useModules, moduleNames, doctoolArgs, outputFile
    };
    Arrays.stream(allOptions).forEach(options::addOption);

    HelpFormatter help = new HelpFormatter();

    CommandLine cmd;

    try {
      cmd = parser.parse(options, args);
      if (cmd.getArgs().length < 1) {
        throw new ParseException("Need to specify the package or class names");
      }
    } catch (ParseException e) {
      System.err.println(e.getMessage());
      help.printHelp(
          new PrintWriter(System.err, true),
          help.getWidth(),
          "java -jar <JAR> [-s <SOURCE_DIR=.>] "
              + "[-c <CLASSES_JAR>] <CLASS_OR_PACKAGE_NAMES>\n"
              + "Class or package names should be fully qualified.\n\n",
          null,
          options,
          help.getLeftPadding(),
          help.getDescPadding(),
          null,
          false);
      System.exit(1);
      throw new RuntimeException("Unreachable code");
    }
    return fromCommandLine(cmd);
  }
}
