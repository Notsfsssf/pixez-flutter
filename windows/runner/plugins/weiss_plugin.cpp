#include "weiss_plugin.h"

#include <flutter/method_channel.h>

using namespace std;
using namespace flutter;

string Weiss::name = "com.perol.dev/weiss";
string Weiss::port = "9876";

void Weiss::Initialize(BinaryMessenger *messenger, const StandardMethodCodec *codec)
{
  MethodChannel<EncodableValue> channel(messenger, name, codec);

  channel.SetMethodCallHandler(
      [](const MethodCall<EncodableValue> &call,
         unique_ptr<MethodResult<EncodableValue>> result)
      {
        if (call.method_name().compare("start") == 0)
        {
          const auto *arguments = get_if<EncodableMap>(call.arguments());
          const auto p = get<string>(arguments->at(EncodableValue("port")));
          const auto map = get<string>(arguments->at(EncodableValue("map")));
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

void Weiss::Start(string json)
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