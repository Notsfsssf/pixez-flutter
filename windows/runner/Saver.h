#pragma once

#include <Windows.h>
#include <ppltasks.h>

#include <flutter/flutter_engine.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>

#include <winrt/windows.foundation.h>
#include <winrt/windows.foundation.collections.h>
#include <winrt/windows.storage.h>
#include <winrt/windows.storage.search.h>

class Saver
{
private:
  static std::string name;
  static winrt::hstring folderName;
  static winrt::Windows::Foundation::IAsyncOperation<winrt::Windows::Storage::StorageFolder> GetFolder();

  static concurrency::task<bool> Save(const std::vector<uint8_t> &data, winrt::hstring fileName);
  static concurrency::task<bool> Exist(winrt::hstring fileName);

public:
  static void Initialize(flutter::FlutterEngine *engine);
};