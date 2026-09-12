#ifndef PLUGINS_SINGLE_INSTANCE_PLUGIN_H_
#define PLUGINS_SINGLE_INSTANCE_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>
#include <string>
#include <vector>

class SingleInstance {
 private:
  static std::string name;
  static FlEventChannel* s_event_channel;
  static gboolean s_has_listener;
  static std::vector<std::string> s_pending_args;

  static FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                         FlValue* args,
                                         gpointer user_data);
  static FlMethodErrorResponse* OnCancel(FlEventChannel* channel,
                                         FlValue* args,
                                         gpointer user_data);

 public:
  static void Initialize(FlPluginRegistrar* registrar);
  static void SendArgs(const char* args_str);
};

#endif  // PLUGINS_SINGLE_INSTANCE_PLUGIN_H_
