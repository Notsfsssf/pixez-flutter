#include "settings.h"

#include <winrt/windows.data.json.h>
#include <winrt/windows.foundation.collections.h>
#include <winrt/windows.storage.h>

using namespace winrt;
using namespace Windows::Data::Json;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::Storage;

winrt::hstring &Settings::Storage()
{
  static winrt::hstring value;
  return value;
}

void Settings::SetAppDataFolderPath(winrt::hstring path)
{
  Storage() = std::move(path);
}

winrt::hstring Settings::AppDataFolder()
{
  return Storage();
}

IAsyncOperation<hstring> Settings::TryGetValueAsync(hstring key)
{
  auto dataFolder = co_await StorageFolder::GetFolderFromPathAsync(AppDataFolder());
  auto settingsFile = co_await dataFolder.CreateFileAsync(L"settings.json", CreationCollisionOption::OpenIfExists);
  auto jsonString = co_await FileIO::ReadTextAsync(settingsFile);
  JsonObject json{};
  // Return an empty string, not (wchar_t *) nullptr: constructing an hstring
  // from a null pointer calls wcslen(nullptr) and crashes.
  if (jsonString.empty() || !JsonObject::TryParse(jsonString, json) || !json.HasKey(key))
    co_return hstring{};

  co_return json.GetNamedString(key);
}

IAsyncAction Settings::SetValueAsync(hstring key, hstring value)
{
  auto dataFolder = co_await StorageFolder::GetFolderFromPathAsync(AppDataFolder());
  auto settingsFileTask = dataFolder.CreateFileAsync(L"settings.json", CreationCollisionOption::ReplaceExisting);

  JsonObject json{};
  json.SetNamedValue(key, JsonValue::CreateStringValue(value));
  co_await FileIO::WriteTextAsync(co_await settingsFileTask, json.Stringify());
}
