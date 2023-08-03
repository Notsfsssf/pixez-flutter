#pragma once

#include <Windows.h>

#include <flutter/flutter_engine.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>

class Info
{
private:
  static std::string name;

  static bool IsBuildOrGreater(DWORD build);

public:
  static void Initialize(flutter::FlutterEngine *engine);
};