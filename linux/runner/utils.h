#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>

class Utils {
 public:
  // Formats command line arguments (skipping argv[0]) separated by newline for single instance.
  static std::string FormatCommandLineArguments(int argc, char** argv);

  // Resolves the XDG user Pictures directory (or fallback ~/.config/user-dirs.dirs / ~/Pictures).
  static std::string GetPicturesDirectory();

  // Resolves the XDG Data directory ($XDG_DATA_HOME or ~/.local/share).
  static std::string GetDataDirectory();

  // Resolves the XDG Config directory ($XDG_CONFIG_HOME or ~/.config).
  static std::string GetConfigDirectory();
};

#endif  // RUNNER_UTILS_H_
