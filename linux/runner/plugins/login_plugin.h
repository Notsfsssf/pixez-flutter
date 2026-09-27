#ifndef PLUGINS_LOGIN_PLUGIN_H_
#define PLUGINS_LOGIN_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <string>

class LoginPlugin {
 public:
  static std::string name;
  static GtkOverlay* s_overlay;
  static FlView* s_fl_view;
  static FlMethodChannel* s_channel;

  static void Initialize(FlPluginRegistrar* registrar, GtkOverlay* overlay,
                         FlView* view);

 private:
  static void HandleMethodCall(FlMethodChannel* channel,
                               FlMethodCall* method_call, gpointer user_data);
};

#endif  // PLUGINS_LOGIN_PLUGIN_H_
