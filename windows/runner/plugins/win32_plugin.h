#pragma once

#include <Windows.h>

#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>
#include <winrt/windows.foundation.h>

class Win32
{
private:
  static std::string name;

  static bool IsBuildOrGreater(DWORD build);
  static winrt::Windows::Foundation::IAsyncAction MigrationAppDataAsync();

public:
  static void Initialize(flutter::BinaryMessenger *messenger, const flutter::StandardMethodCodec *codec);
};