#include "single_instance_plugin.h"

std::string SingleInstance::name = "pixez/single_instance";
FlEventChannel* SingleInstance::s_event_channel = nullptr;
gboolean SingleInstance::s_has_listener = FALSE;
std::vector<std::string> SingleInstance::s_pending_args;

void SingleInstance::Initialize(FlPluginRegistrar* registrar) {
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  s_event_channel = fl_event_channel_new(
      messenger, name.c_str(), FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(
      s_event_channel, OnListen, OnCancel, nullptr, nullptr);
}

FlMethodErrorResponse* SingleInstance::OnListen(FlEventChannel* channel,
                                                FlValue* args,
                                                gpointer user_data) {
  s_has_listener = TRUE;
  for (const auto& pending : s_pending_args) {
    g_autoptr(FlValue) value = fl_value_new_string(pending.c_str());
    fl_event_channel_send(s_event_channel, value, nullptr, nullptr);
  }
  s_pending_args.clear();
  return nullptr;
}

FlMethodErrorResponse* SingleInstance::OnCancel(FlEventChannel* channel,
                                                FlValue* args,
                                                gpointer user_data) {
  s_has_listener = FALSE;
  return nullptr;
}

void SingleInstance::SendArgs(const char* args_str) {
  if (args_str == nullptr) return;

  if (s_event_channel != nullptr && s_has_listener) {
    g_autoptr(FlValue) value = fl_value_new_string(args_str);
    fl_event_channel_send(s_event_channel, value, nullptr, nullptr);
  } else {
    s_pending_args.emplace_back(args_str);
  }
}
