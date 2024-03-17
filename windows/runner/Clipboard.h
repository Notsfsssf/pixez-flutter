#pragma once

#include <Windows.h>
#include <ppltasks.h>

#include <flutter/flutter_engine.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>

#include <winrt/windows.applicationmodel.datatransfer.h>
#include <winrt/windows.foundation.h>
#include <winrt/windows.foundation.collections.h>
#include <winrt/windows.graphics.imaging.h>
#include <winrt/windows.storage.h>
#include <winrt/windows.storage.streams.h>

class Clipboard
{
private:
  static std::string name;
  static concurrency::task<void> CopyImage(const std::string &path);

public:
  static void Initialize(flutter::FlutterEngine *engine);
};