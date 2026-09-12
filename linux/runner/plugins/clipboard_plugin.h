#ifndef PLUGINS_CLIPBOARD_PLUGIN_H_
#define PLUGINS_CLIPBOARD_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>
#include <string>

class Clipboard {
 private:
  static std::string name;

  static bool CopyImageFromByteArray(const uint8_t* data, size_t length);
  static void HandleMethodCall(FlMethodChannel* channel,
                               FlMethodCall* method_call,
                               gpointer user_data);

 public:
  static void Initialize(FlPluginRegistrar* registrar);
};

#endif  // PLUGINS_CLIPBOARD_PLUGIN_H_
