#include "clipboard_plugin.h"

#include <future>
#include <Windows.h>
#include <flutter/method_channel.h>
#include <winrt/windows.applicationmodel.datatransfer.h>
#include <winrt/windows.foundation.collections.h>
#include <winrt/windows.graphics.imaging.h>
#include <winrt/windows.storage.h>
#include <winrt/windows.storage.streams.h>

using namespace std;
using namespace flutter;
using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Storage;
using namespace Windows::Storage::Streams;
using namespace Windows::Graphics::Imaging;

string Clipboard::name = "com.perol.dev/clipboard";

void Clipboard::Initialize(BinaryMessenger *messenger, const StandardMethodCodec *codec)
{
  MethodChannel<EncodableValue> channel(messenger, name, codec);

  channel.SetMethodCallHandler(
      [](const MethodCall<EncodableValue> &call,
         unique_ptr<MethodResult<EncodableValue>> result) -> std::future<void>
      {
        if (call.method_name().compare("copyImageFromPath") == 0)
        {
          const auto *arguments = get_if<EncodableMap>(call.arguments());
          const auto path = get<string>(arguments->at(EncodableValue("path")));

          co_await CopyImageFromPathAsync(path);
          result->Success();
        }
      });
}

IAsyncAction Clipboard::CopyImageFromPathAsync(const string &path)
{
  typedef Windows::ApplicationModel::DataTransfer::Clipboard WinRTClipboard;
  typedef Windows::ApplicationModel::DataTransfer::DataPackage DataPackage;
  typedef Windows::ApplicationModel::DataTransfer::DataPackageOperation DataPackageOperation;

  const auto file = co_await StorageFile::GetFileFromPathAsync(to_hstring(path));
  const auto stream = co_await file.OpenReadAsync();
  const auto reference = RandomAccessStreamReference::CreateFromStream(stream);

  const DataPackage content{};
  content.RequestedOperation(DataPackageOperation::Copy);
  content.SetBitmap(reference);
  WinRTClipboard::SetContent(content);
  WinRTClipboard::Flush();

  stream.Close();
}