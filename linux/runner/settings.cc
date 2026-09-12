#include "settings.h"
#include "utils.h"

#include <flutter_linux/flutter_linux.h>
#include <glib.h>

std::string Settings::ConfigFolder() {
  std::string base_dir = Utils::GetConfigDirectory();
  g_autofree gchar* path = g_build_filename(base_dir.c_str(), "PixEz", nullptr);
  g_mkdir_with_parents(path, 0755);
  return std::string(path);
}

std::string Settings::AppDataFolder() {
  std::string base_dir = Utils::GetDataDirectory();
  g_autofree gchar* path = g_build_filename(base_dir.c_str(), "PixEz", nullptr);
  g_mkdir_with_parents(path, 0755);
  return std::string(path);
}

std::string Settings::TryGetValue(const std::string& key) {
  std::string config_dir = ConfigFolder();
  g_autofree gchar* file_path =
      g_build_filename(config_dir.c_str(), "settings.json", nullptr);

  gchar* content = nullptr;
  if (!g_file_get_contents(file_path, &content, nullptr, nullptr)) {
    return "";
  }

  g_autoptr(FlJsonMessageCodec) codec = fl_json_message_codec_new();
  g_autoptr(FlValue) map = fl_json_message_codec_decode(codec, content, nullptr);
  g_free(content);

  if (map != nullptr && fl_value_get_type(map) == FL_VALUE_TYPE_MAP) {
    FlValue* val = fl_value_lookup_string(map, key.c_str());
    if (val != nullptr && fl_value_get_type(val) == FL_VALUE_TYPE_STRING) {
      return fl_value_get_string(val);
    }
  }

  return "";
}

void Settings::SetValue(const std::string& key, const std::string& value) {
  std::string config_dir = ConfigFolder();
  g_autofree gchar* file_path =
      g_build_filename(config_dir.c_str(), "settings.json", nullptr);

  g_autoptr(FlJsonMessageCodec) codec = fl_json_message_codec_new();
  g_autoptr(FlValue) map = nullptr;

  gchar* content = nullptr;
  if (g_file_get_contents(file_path, &content, nullptr, nullptr)) {
    map = fl_json_message_codec_decode(codec, content, nullptr);
    g_free(content);
  }

  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    g_clear_pointer(&map, fl_value_unref);
    map = fl_value_new_map();
  }

  fl_value_set_string_take(map, key.c_str(), fl_value_new_string(value.c_str()));

  g_autofree gchar* json_str = fl_json_message_codec_encode(codec, map, nullptr);
  if (json_str != nullptr) {
    g_file_set_contents(file_path, json_str, -1, nullptr);
  }
}
