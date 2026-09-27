#ifndef SETTINGS_H_
#define SETTINGS_H_

#include <string>

class Settings {
 private:
  static std::string& Storage();

 public:
  static void SetAppDataFolderPath(const std::string& path);
  static std::string AppDataFolder();
  static std::string TryGetValue(const std::string& key);
  static void SetValue(const std::string& key, const std::string& value);
};

#endif  // SETTINGS_H_
