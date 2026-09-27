#include "paths_plugin.h"

#include <string.h>

#include "../settings.h"

std::string Paths::name = "com.perol.dev/paths";

void Paths::Initialize(FlPluginRegistrar* registrar) {
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(messenger, name.c_str(), FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, HandleMethodCall, nullptr,
                                            nullptr);
}

void Paths::HandleMethodCall(FlMethodChannel* channel,
                             FlMethodCall* method_call, gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "setApplicationSupportDirectory") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* path_value = fl_value_lookup_string(args, "path");
      if (path_value != nullptr &&
          fl_value_get_type(path_value) == FL_VALUE_TYPE_STRING) {
        SetApplicationSupportDirectory(fl_value_get_string(path_value));
        fl_method_call_respond_success(method_call, nullptr, nullptr);
        return;
      }
    }
    fl_method_call_respond_error(method_call, "bad_args", "Invalid arguments",
                                 nullptr, nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void Paths::SetApplicationSupportDirectory(const std::string& path) {
  Settings::SetAppDataFolderPath(path);
}
