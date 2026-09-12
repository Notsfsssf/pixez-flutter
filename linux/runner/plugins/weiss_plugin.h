#ifndef PLUGINS_WEISS_PLUGIN_H_
#define PLUGINS_WEISS_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>
#include <string>

class Weiss {
 private:
  static std::string name;

  static void Start(const std::string& json);
  static void Stop();
  static void Proxy();

  static void HandleMethodCall(FlMethodChannel* channel,
                               FlMethodCall* method_call,
                               gpointer user_data);

 public:
  static void Initialize(FlPluginRegistrar* registrar);
};

#endif  // PLUGINS_WEISS_PLUGIN_H_
