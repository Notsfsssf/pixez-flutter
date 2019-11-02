#pragma once

#include <Windows.h>

#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>

class Win32
{
private:
  static std::string name;

  static bool IsBuildOrGreater(DWORD build);

public:
  static void Initialize(flutter::BinaryMessenger *messenger, const flutter::StandardMethodCodec *codec);
};