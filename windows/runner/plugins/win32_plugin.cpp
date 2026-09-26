#include "win32_plugin.h"

#include <future>
#include <shlobj.h>
#include <flutter/method_channel.h>
#include <winrt/windows.foundation.h>
#include <winrt/windows.foundation.collections.h>
#include <winrt/windows.storage.h>

#include "../settings.h"

using namespace std;
using namespace flutter;

using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Storage;

string Win32::name = "com.perol.dev/win32";

void Win32::Initialize(BinaryMessenger *messenger, const StandardMethodCodec *codec)
{
  MethodChannel<EncodableValue> channel(messenger, name, codec);

  channel.SetMethodCallHandler(
      [](const MethodCall<EncodableValue> &call,
         unique_ptr<MethodResult<EncodableValue>> result) -> std::future<void>
      {
        if (call.method_name().compare("isBuildOrGreater") == 0)
        {
          const auto *arguments = get_if<EncodableMap>(call.arguments());
          auto data = arguments->find(EncodableValue("build"))->second;
          DWORD build = get<int32_t>(data);
          result->Success(IsBuildOrGreater(build));
        }
        else if (call.method_name().compare("migrationAppData") == 0)
        {
          try
          {
            co_await MigrationAppDataAsync();
            result->Success();
          }
          catch (winrt::hresult_error const &ex)
          {
            result->Error(
                "migration_failed",
                winrt::to_string(ex.message()));
          }
          catch (std::exception const &ex)
          {
            result->Error(
                "migration_failed",
                ex.what());
          }
          catch (...)
          {
            result->Error(
                "migration_failed",
                "An unknown error occurred.");
          }
        }
      });
}

bool Win32::IsBuildOrGreater(DWORD build)
{
  OSVERSIONINFOEX lpVersionInformation;
  lpVersionInformation.dwBuildNumber = build;

  auto dwlConditionMask = VerSetConditionMask(
      0,
      VER_BUILDNUMBER,
      VER_GREATER_EQUAL);

  return VerifyVersionInfo(
             &lpVersionInformation,
             VER_BUILDNUMBER,
             dwlConditionMask) ==
         TRUE;
}

bool CreateDirectoryRecursive(hstring const &path)
{
  auto result = SHCreateDirectoryExW(
      nullptr,
      path.c_str(),
      nullptr);

  return result == ERROR_SUCCESS ||
         result == ERROR_ALREADY_EXISTS;
}

IAsyncAction Win32::MigrationAppDataAsync()
{
  const winrt::hstring newPathStr = Settings::AppDataFolder();

  if (newPathStr.empty())
    co_return;

  const auto appDataPath =
      winrt::Windows::Storage::UserDataPaths::GetDefault()
          .RoamingAppData();

  const winrt::hstring oldPathStr = appDataPath + L"\\PixEz";

  if (oldPathStr == newPathStr)
    co_return;

  // 检查旧目录
  StorageFolder appDataFolder =
      co_await StorageFolder::GetFolderFromPathAsync(appDataPath);

  auto oldItem = co_await appDataFolder.TryGetItemAsync(L"PixEz");

  if (!oldItem || !oldItem.IsOfType(StorageItemTypes::Folder))
    co_return;

  StorageFolder oldFolder = oldItem.as<StorageFolder>();

  if (!CreateDirectoryRecursive(newPathStr))
    co_return;

  StorageFolder newFolder =
      co_await StorageFolder::GetFolderFromPathAsync(newPathStr);

  // 复制文件
  bool copySuccess = true;
  for (auto const &item : co_await oldFolder.GetItemsAsync())
  {
    if (!item.IsOfType(StorageItemTypes::File))
      continue;

    auto file = item.as<StorageFile>();

    try
    {
      co_await file.CopyAsync(
          newFolder,
          file.Name(),
          NameCollisionOption::FailIfExists);
    }
    catch (...)
    {
      // 已存在或复制失败
      copySuccess = false;
    }
  }

  if (!copySuccess)
    co_return;

  try
  {
    co_await oldFolder.DeleteAsync();
  }
  catch (...)
  {
  }
}
