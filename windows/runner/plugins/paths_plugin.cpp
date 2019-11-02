#include "paths_plugin.h"
#include "../settings.h"

#include <Windows.h>
#include <flutter/method_channel.h>
#include <winrt/windows.storage.h>

using namespace std;
using namespace flutter;
using namespace winrt;
using namespace Windows::Storage;

string Paths::name = "com.perol.dev/paths";
hstring folder = L"\\PixEz";

void Paths::Initialize(BinaryMessenger *messenger, const StandardMethodCodec *codec)
{
  MethodChannel<EncodableValue> channel(messenger, name, codec);

  channel.SetMethodCallHandler(
      [](const MethodCall<EncodableValue> &call,
         unique_ptr<MethodResult<EncodableValue>> result)
      {
        if (call.method_name().compare("getDatabaseFolderPath") == 0)
        {
          result->Success(to_string(GetDatabaseFolderPath()));
        }
      });
}

hstring Paths::GetDatabaseFolderPath()
{
  return Settings::AppDataFolder();
}
