#ifndef PLUGINS_PATHS_PLUGIN_H_
#define PLUGINS_PATHS_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>
#include <string>

class Paths {
 private:
  static std::string name;

  static std::string GetDatabaseFolderPath();
  static void HandleMethodCall(FlMethodChannel* channel,
                               FlMethodCall* method_call,
                               gpointer user_data);

 public:
  static void Initialize(FlPluginRegistrar* registrar);
};

#endif  // PLUGINS_PATHS_PLUGIN_H_
