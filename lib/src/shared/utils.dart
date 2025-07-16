class Utils {
  static String escapeShellCommand(String command) {
    return command.replaceAll("'", r"'\''");
  }
}
