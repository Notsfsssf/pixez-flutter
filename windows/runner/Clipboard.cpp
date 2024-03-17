#include "Clipboard.h"

std::string Clipboard::name = "com.perol.dev/clipboard";

void Clipboard::Initialize(flutter::FlutterEngine *engine)
{
  const auto &codec = flutter::StandardMethodCodec::GetInstance();

  flutter::MethodChannel<flutter::EncodableValue> channel(
      engine->messenger(),
      name,
      &codec);

  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue> &call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
      {
        if (call.method_name().compare("copyImageFromPath") == 0)
        {
          const auto *arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          const auto path = std::get<std::string>(arguments->at(flutter::EncodableValue("path")));

          const auto op{CopyImage(path)};
          op.get();
          result->Success();
        }
      });
}

concurrency::task<void> Clipboard::CopyImage(const std::string &path)
{
  return concurrency::create_task(
      [path]()
      {
        using namespace winrt;
        using namespace Windows::ApplicationModel::DataTransfer;
        using namespace Windows::Storage;
        using namespace Windows::Storage::Streams;
        using namespace Windows::Graphics::Imaging;

        typedef Windows::ApplicationModel::DataTransfer::Clipboard WinRTClipboard;

        const auto file = StorageFile::GetFileFromPathAsync(to_hstring(path)).get();
        const auto stream = file.OpenReadAsync().get();
        const auto reference = RandomAccessStreamReference::CreateFromStream(stream);

        const DataPackage content{};
        content.RequestedOperation(DataPackageOperation::Copy);
        content.SetBitmap(reference);
        WinRTClipboard::SetContent(content);
        WinRTClipboard::Flush();

        stream.Close();
      });
}