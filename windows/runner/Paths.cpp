#include "Paths.h"
#include <winrt/windows.storage.h>

std::string Paths::name = "com.perol.dev/single_instance";
std::string Paths::folder = "\\PixEz";

void Paths::Initialize(flutter::FlutterEngine *engine)
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
        if (call.method_name().compare("getAppDataFolderPath") == 0)
        {
          result->Success(GetAppDataFolderPath());
        }
        else if (call.method_name().compare("getPicturesFolderPath") == 0)
        {
          result->Success(GetPicturesFolderPath());
        }
      });
}
std::string Paths::GetAppDataFolderPath()
{
  using namespace winrt;
  using namespace Windows::Storage;

  auto path = UserDataPaths::GetDefault().RoamingAppData();
  return to_string(path) + folder;
}
std::string Paths::GetPicturesFolderPath()
{
  using namespace winrt;
  using namespace Windows::Storage;

  auto path = UserDataPaths::GetDefault().SavedPictures();
  return to_string(path) + folder;
}