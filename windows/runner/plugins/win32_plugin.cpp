#include "win32_plugin.h"

#include <flutter/method_channel.h>

using namespace std;
using namespace flutter;

string Win32::name = "com.perol.dev/win32";

void Win32::Initialize(BinaryMessenger *messenger, const StandardMethodCodec *codec)
{
  MethodChannel<EncodableValue> channel(messenger, name, codec);

  channel.SetMethodCallHandler(
      [](const MethodCall<EncodableValue> &call,
         unique_ptr<MethodResult<EncodableValue>> result)
      {
        if (call.method_name().compare("isBuildOrGreater") == 0)
        {
          const auto *arguments = get_if<EncodableMap>(call.arguments());
          auto data = arguments->find(EncodableValue("build"))->second;
          DWORD build = get<int32_t>(data);
          result->Success(IsBuildOrGreater(build));
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