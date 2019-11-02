#pragma once

#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>
#include <winrt/windows.foundation.h>

class Clipboard
{
private:
  static std::string name;
  static winrt::Windows::Foundation::IAsyncAction CopyImageFromByteArrayAsync(const std::vector<uint8_t> data);

public:
  static void Initialize(flutter::BinaryMessenger *messenger, const flutter::StandardMethodCodec *codec);
};