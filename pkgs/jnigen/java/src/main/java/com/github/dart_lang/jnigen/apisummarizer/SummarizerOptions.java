package com.github.dart_lang.jnigen.apisummarizer;

import org.apache.commons.cli.*;

public class SummarizerOptions {
  private static final CommandLineParser parser = new DefaultParser();
  String sourcePath;
  String classPath;
  boolean useModules;
  Main.Backend backend;
  String modulesList;
  boolean addDependencies;
  String toolArgs;
  boolean verbose;
  String outputFile;
  String[] args;

  SummarizerOptions() {}

  public static SummarizerOptions fromCommandLine(CommandLine cmd) {
    var opts = new SummarizerOptions();
    opts.sourcePath = cmd.getOptionValue("sources", ".");
    var backendString = cmd.getOptionValue("backend", "auto");
    opts.backend = Main.Backend.valueOf(backendString.toUpperCase());
    opts.classPath = cmd.getOptionValue("classes", null);
    opts.useModules = cmd.hasOption("use-modules");
    opts.modulesList = cmd.getOptionValue("module-names", null);
    opts.addDependencies = cmd.hasOption("recursive");
    opts.toolArgs = cmd.getOptionValue("doctool-args", null);
    opts.verbose = cmd.hasOption("verbose");
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
    Option recursive = new Option("r", "recursive", false, "include dependencies of classes");
    Option moduleNames =
        new Option("m", "module-names", true, "comma separated list of module names");
    Option doctoolArgs =
        new Option("D", "doctool-args", true, "arguments to pass to the documentation tool");
    Option verbose = new Option("v", "verbose", false, "enable verbose output");
    Option outputFile =
        new Option("o", "output-file", true, "write JSON to file instead of stdout");
    for (Option opt :
        new Option[] {
          sources,
          classes,
          backend,
          useModules,
          recursive,
          moduleNames,
          doctoolArgs,
          verbose,
          outputFile,
        }) {
      options.addOption(opt);
    }

    HelpFormatter help = new HelpFormatter();

    CommandLine cmd;

    try {
      cmd = parser.parse(options, args);
      if (cmd.getArgs().length < 1) {
        throw new ParseException("Need to specify paths to source files");
      }
    } catch (ParseException e) {
      System.out.println(e.getMessage());
      help.printHelp(
          "java -jar <JAR> [-s <SOURCE_DIR=.>] "
              + "[-c <CLASSES_JAR>] <CLASS_OR_PACKAGE_NAMES>\n"
              + "Class or package names should be fully qualified.\n\n",
          options);
      System.exit(1);
      throw new RuntimeException("Unreachable code");
    }
    return fromCommandLine(cmd);
  }
}
