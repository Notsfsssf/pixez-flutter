#include "Saver.h"

using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Storage;

std::string Saver::name = "com.perol.dev/save";
hstring Saver::folderName = L"Pixez";

void Saver::Initialize(flutter::FlutterEngine *engine)
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
        if (call.method_name().compare("save") == 0)
        {
          const auto *arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          auto data = arguments->find(flutter::EncodableValue("data"))->second;
          auto name = arguments->find(flutter::EncodableValue("name"))->second;
          std::vector<uint8_t> vector = std::get<std::vector<uint8_t>>(data);
          hstring fileName = to_hstring(std::get<std::string>(name));
          auto op{Save(vector, fileName)};
          result->Success(op.get());
        }
        else if (call.method_name().compare("exist") == 0)
        {
          const auto *arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          auto name = arguments->find(flutter::EncodableValue("name"))->second;
          hstring fileName = to_hstring(std::get<std::string>(name));
          auto op{Exist(fileName)};
          result->Success(op.get());
        }
      });
}

IAsyncOperation<StorageFolder> Saver::GetFolder()
{
  auto folder = KnownFolders::SavedPictures();
  if (!folder)
    folder = KnownFolders::PicturesLibrary();

  return folder.CreateFolderAsync(folderName, CreationCollisionOption::OpenIfExists);
}
concurrency::task<bool> Saver::Save(const std::vector<uint8_t> &data, hstring fileName)
{
  return concurrency::create_task(
      [fileName, data]()
      {
        StorageFolder folder = GetFolder().get();
        StorageFile file = folder.CreateFileAsync(
                                     fileName,
                                     CreationCollisionOption::ReplaceExisting)
                               .get();
        if (!file)
          return false;

        FileIO::WriteBytesAsync(file, data)
            .get();

        return true;
      });
}

concurrency::task<bool> Saver::Exist(hstring fileName)
{
  return concurrency::create_task(
      [fileName]()
      {
        StorageFolder folder = GetFolder().get();

        Collections::IVectorView<StorageFile> list =
            folder
                .CreateFileQuery()
                .GetFilesAsync()
                .get();

        for (uint32_t i = 0; i < list.Size(); i++)
        {
          StorageFile file = list.GetAt(i);

          if (file.Name() == fileName)
            return true;
        }

        return false;
      });
}