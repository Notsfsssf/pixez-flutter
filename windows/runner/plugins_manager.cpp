#include "plugins_manager.h"
#include "win32_window.h"
#include "plugins/clipboard_plugin.h"
#include "plugins/document_plugin.h"
#include "plugins/paths_plugin.h"
#include "plugins/single_instance_plugin.h"
#include "plugins/weiss_plugin.h"
#include "plugins/win32_plugin.h"

void RegisterPixEzPlugins(flutter::FlutterEngine* engine, HWND hWnd) {
  const auto &codec = flutter::StandardMethodCodec::GetInstance();
  auto messenger = engine->messenger();
  Clipboard::Initialize(messenger, &codec);
  Document::Initialize(messenger, &codec, hWnd);
  Paths::Initialize(messenger, &codec);
  SingleInstance::Initialize(messenger, &codec);
  Weiss::Initialize(messenger, &codec);
  Win32::Initialize(messenger, &codec);
}