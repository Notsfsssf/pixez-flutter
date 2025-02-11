#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

#include <windows.h>
#include <ShlObj.h>
#include <iostream>
#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/encodable_value.h>
#include <fstream>
#include <stdexcept>
#include <stdlib.h>
#include <stdio.h>

#include "plugins/clipboard_plugin.h"
#include "plugins/document_plugin.h"
#include "plugins/paths_plugin.h"
#include "plugins/single_instance_plugin.h"
#include "plugins/weiss_plugin.h"
#include "plugins/win32_plugin.h"

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view())
  {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  const auto &codec = flutter::StandardMethodCodec::GetInstance();
  auto messenger = flutter_controller_->engine()->messenger();
  Clipboard::Initialize(messenger, &codec);
  Document::Initialize(messenger, &codec, GetHandle());
  Paths::Initialize(messenger, &codec);
  SingleInstance::Initialize(messenger, &codec);
  Weiss::Initialize(messenger, &codec);
  Win32::Initialize(messenger, &codec);

  flutter_controller_->engine()->SetNextFrameCallback([&]()
                                                      { this->Show(); });

  return true;
}

void FlutterWindow::OnDestroy()
{
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept
{
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result)
    {
      return *result;
    }
  }

  switch (message)
  {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
