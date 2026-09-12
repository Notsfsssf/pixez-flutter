#ifndef SETTINGS_H_
#define SETTINGS_H_

#include <string>

class Settings {
 public:
  static std::string AppDataFolder();
  static std::string DatabaseFolder();
  static std::string TryGetValue(const std::string& key);
  static void SetValue(const std::string& key, const std::string& value);
};

#endif  // SETTINGS_H_
