#ifndef PLUGINS_LOGIN_PLUGIN_H_
#define PLUGINS_LOGIN_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <string>

class LoginPlugin {
 private:
  static std::string name;
  static GtkWindow* s_parent_window;

  static void HandleMethodCall(FlMethodChannel* channel,
                               FlMethodCall* method_call,
                               gpointer user_data);

 public:
  static void Initialize(FlPluginRegistrar* registrar, GtkWindow* window);
};

#endif  // PLUGINS_LOGIN_PLUGIN_H_
