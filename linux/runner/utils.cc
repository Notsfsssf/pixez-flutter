#include "utils.h"

#include <glib.h>

std::string Utils::FormatCommandLineArguments(int argc, char** argv) {
  std::string result;
  for (int i = 1; i < argc; ++i) {
    if (!result.empty()) {
      result += "\n";
    }
    result += argv[i];
  }
  return result;
}

std::string Utils::GetPicturesDirectory() {
  const gchar* xdg_pictures = g_get_user_special_dir(G_USER_DIRECTORY_PICTURES);
  if (xdg_pictures != nullptr && *xdg_pictures != '\0') {
    return std::string(xdg_pictures);
  }

  g_autofree gchar* home_pictures =
      g_build_filename(g_get_home_dir(), "Pictures", nullptr);
  return std::string(home_pictures);
}

std::string Utils::GetDataDirectory() {
  return std::string(g_get_user_data_dir());
}

std::string Utils::GetConfigDirectory() {
  return std::string(g_get_user_config_dir());
}
