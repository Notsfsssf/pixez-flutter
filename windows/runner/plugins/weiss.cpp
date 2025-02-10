#include "weiss.h"

#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>

std::string Weiss::name = "com.perol.dev/weiss";
std::string Weiss::port = "9876";

void Weiss::Initialize(flutter::FlutterEngine *engine)
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
        if (call.method_name().compare("start") == 0)
        {
          const auto *arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          const auto p = std::get<std::string>(arguments->at(flutter::EncodableValue("port")));
          const auto map = std::get<std::string>(arguments->at(flutter::EncodableValue("map")));
          if (!p.empty())
            port = p;

          Start(map);
          result->Success();
        }
        else if (call.method_name().compare("stop") == 0)
        {
          Stop();
          result->Success();
        }
        else if (call.method_name().compare("proxy") == 0)
        {
          Proxy();
          result->Success();
        }
      });
}

void Weiss::Start(std::string json)
{
  // TODO
}
void Weiss::Stop()
{
  // TODO
}
void Weiss::Proxy()
{
  // TODO
}