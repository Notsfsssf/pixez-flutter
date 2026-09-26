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
        if (call.method_name().compare("setApplicationSupportDirectory") == 0)
        {
        const auto *arguments = get_if<EncodableMap>(call.arguments());
          auto path = to_hstring(get<string>(arguments->find(EncodableValue("path"))->second));
          SetApplicationSupportDirectory(path);
          result->Success();
        }
      });
}

void Paths::SetApplicationSupportDirectory(winrt::hstring path)
{
  return Settings::SetAppDataFolderPath(path);
}
