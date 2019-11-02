#include "settings.h"

#include <winrt/windows.data.json.h>
#include <winrt/windows.foundation.collections.h>
#include <winrt/windows.storage.h>

using namespace winrt;
using namespace Windows::Data::Json;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::Storage;

hstring Settings::_appDataFolder = UserDataPaths::GetDefault().RoamingAppData() + L"\\PixEz";

IAsyncOperation<hstring> Settings::TryGetValueAsync(hstring key)
{
  auto dataFolder = co_await StorageFolder::GetFolderFromPathAsync(AppDataFolder());
  auto settingsFile = co_await dataFolder.CreateFileAsync(L"settings.json", CreationCollisionOption::OpenIfExists);
  auto jsonString = co_await FileIO::ReadTextAsync(settingsFile);
  JsonObject json{};
  if (jsonString.empty() || !JsonObject::TryParse(jsonString, json) || !json.HasKey(key))
    co_return (wchar_t *) nullptr;

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
