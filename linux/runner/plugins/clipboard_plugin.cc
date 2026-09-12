#include "clipboard_plugin.h"

#include <gdk-pixbuf/gdk-pixbuf.h>
#include <gtk/gtk.h>
#include <string.h>

std::string Clipboard::name = "com.perol.dev/clipboard";

void Clipboard::Initialize(FlPluginRegistrar* registrar) {
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      messenger, name.c_str(), FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, HandleMethodCall, nullptr, nullptr);
}

bool Clipboard::CopyImageFromByteArray(const uint8_t* data, size_t length) {
  if (data == nullptr || length == 0) {
    return false;
  }

  g_autoptr(GdkPixbufLoader) loader = gdk_pixbuf_loader_new();
  g_autoptr(GError) write_error = nullptr;

  gboolean write_ok = gdk_pixbuf_loader_write(loader, data, length, &write_error);
  if (!write_ok) {
    g_warning("Failed to write to pixbuf loader: %s",
              write_error ? write_error->message : "unknown");
    return false;
  }

  g_autoptr(GError) close_error = nullptr;
  gboolean close_ok = gdk_pixbuf_loader_close(loader, &close_error);
  if (!close_ok) {
    g_warning("Failed to close pixbuf loader: %s",
              close_error ? close_error->message : "unknown");
    return false;
  }

  GdkPixbuf* pixbuf = gdk_pixbuf_loader_get_pixbuf(loader);
  if (pixbuf == nullptr) {
    return false;
  }

  GtkClipboard* clipboard = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
  gtk_clipboard_set_image(clipboard, pixbuf);
  gtk_clipboard_store(clipboard);
  return true;
}

void Clipboard::HandleMethodCall(FlMethodChannel* channel,
                                 FlMethodCall* method_call,
                                 gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "copyImageFromByteArray") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    FlValue* data_val = nullptr;
    if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      data_val = fl_value_lookup_string(args, "data");
    }

    if (data_val != nullptr &&
        fl_value_get_type(data_val) == FL_VALUE_TYPE_UINT8_LIST) {
      if (CopyImageFromByteArray(fl_value_get_uint8_list(data_val),
                                 fl_value_get_length(data_val))) {
        fl_method_call_respond_success(method_call, nullptr, nullptr);
        return;
      }
    }
    fl_method_call_respond_error(
        method_call, "COPY_FAILED", "Failed to write image to clipboard",
        nullptr, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}
