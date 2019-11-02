#pragma once

#include <winrt/base.h>
#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>

class Paths
{
private:
  static std::string name;

  static winrt::hstring GetDatabaseFolderPath();
  static winrt::hstring GetPicturesFolderPath();

public:
  static void Initialize(flutter::BinaryMessenger *messenger, const flutter::StandardMethodCodec *codec);
};