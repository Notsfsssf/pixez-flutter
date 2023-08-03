#include "Info.h"

std::string Info::name = "com.perol.dev/win32";

void Info::Initialize(flutter::FlutterEngine *engine)
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
        if (call.method_name().compare("isBuildOrGreater") == 0)
        {
          const auto *arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          auto data = arguments->find(flutter::EncodableValue("build"))->second;
          DWORD build = std::get<int32_t>(data);
          result->Success(IsBuildOrGreater(build));
        }
      });
}

bool Info::IsBuildOrGreater(DWORD build)
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