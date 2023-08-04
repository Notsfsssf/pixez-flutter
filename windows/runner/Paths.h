#pragma once

#include <Windows.h>
#include <flutter/flutter_engine.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>

class Paths
{
private:
  static std::string name;
  static std::string folder;

  static std::string GetAppDataFolderPath();
  static std::string GetPicturesFolderPath();

public:
  static void Initialize(flutter::FlutterEngine *engine);
};