#include "weiss_plugin.h"

#include <string.h>

std::string Weiss::name = "com.perol.dev/weiss";

void Weiss::Initialize(FlPluginRegistrar* registrar) {
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      messenger, name.c_str(), FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, HandleMethodCall, nullptr, nullptr);
}

void Weiss::Start(const std::string& json) {}
void Weiss::Stop() {}
void Weiss::Proxy() {}

void Weiss::HandleMethodCall(FlMethodChannel* channel,
                             FlMethodCall* method_call,
                             gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "start") == 0 ||
      strcmp(method, "stop") == 0 ||
      strcmp(method, "proxy") == 0) {
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}
