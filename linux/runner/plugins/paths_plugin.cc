#include "paths_plugin.h"
#include "../settings.h"

#include <string.h>

std::string Paths::name = "com.perol.dev/paths";

void Paths::Initialize(FlPluginRegistrar* registrar) {
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      messenger, name.c_str(), FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, HandleMethodCall, nullptr, nullptr);
}

void Paths::HandleMethodCall(FlMethodChannel* channel,
                             FlMethodCall* method_call,
                             gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getDatabaseFolderPath") == 0) {
    std::string path = GetDatabaseFolderPath();
    g_autoptr(FlValue) result = fl_value_new_string(path.c_str());
    fl_method_call_respond_success(method_call, result, nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

std::string Paths::GetDatabaseFolderPath() {
  return Settings::AppDataFolder();
}
