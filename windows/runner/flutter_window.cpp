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

void writeDataToFile(const std::string &target_path, const std::vector<uint8_t> &data)
{
  std::ofstream outfile(target_path, std::ios::binary | std::ios::out);

  if (outfile.is_open())
  {
    outfile.write(reinterpret_cast<const char *>(data.data()), data.size());
    outfile.close();
  }
}

wchar_t *GetUserPicturesPath()
{
  PWSTR picturesPath = nullptr;
  if (SHGetKnownFolderPath(FOLDERID_Pictures, 0, nullptr, &picturesPath) != S_OK)
    return nullptr;
  return picturesPath;
}

void initDocumentMethodChannel(flutter::FlutterEngine *flutter_instance)
{

  const static std::string channel_name("com.perol.dev/save");

  auto channel =
      std::make_unique<flutter::MethodChannel<>>(
          flutter_instance->messenger(), channel_name,
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<> &call,
         std::unique_ptr<flutter::MethodResult<>> result)
      {
        if (call.method_name().compare("save") == 0)
        {
          OutputDebugString(L"initDocumentMethodChannel:save");
          const auto *arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          auto data = arguments->find(flutter::EncodableValue("data"))->second;
          auto name = arguments->find(flutter::EncodableValue("name"))->second;
          std::vector<uint8_t> vector = std::get<std::vector<uint8_t>>(data);
          std::string fileName = std::get<std::string>(name);
          wchar_t *path = GetUserPicturesPath();
          char *pMBBuffer = (char *)malloc(100);
          size_t i;
          wcstombs_s(&i, pMBBuffer, (size_t)100,
                     path, (size_t)100 - 1);
          std::string str(pMBBuffer);
          str += "\\";
          str += fileName;
          OutputDebugStringA(str.c_str());
          writeDataToFile(str, vector);
          result->Success(true);
        }
        else
        {
          result->Success("pass result here");
        }
      });
}

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
  initDocumentMethodChannel(flutter_controller_->engine());

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
