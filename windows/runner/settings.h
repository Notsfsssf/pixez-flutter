#pragma once

#include <winrt/windows.foundation.h>
#include <winrt/windows.storage.h>

class Settings
{
private:
  static winrt::hstring &Storage();

public:
  static void SetAppDataFolderPath(winrt::hstring path);
  static winrt::hstring AppDataFolder();
  static winrt::Windows::Foundation::IAsyncOperation<winrt::hstring> TryGetValueAsync(winrt::hstring key);
  static winrt::Windows::Foundation::IAsyncAction SetValueAsync(winrt::hstring key, winrt::hstring value);
};