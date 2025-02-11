#pragma once

#include <Windows.h>
#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>
#include <winrt/windows.foundation.h>

class Document
{
private:
  static std::string name;

  static winrt::Windows::Foundation::IAsyncOperation<bool> SaveAsync(const std::vector<uint8_t> &data, winrt::hstring fileName);
  static winrt::Windows::Foundation::IAsyncOperation<bool> OpenSaveAsync(const std::vector<uint8_t> &data, winrt::hstring fileName, HWND hWnd);
  static winrt::Windows::Foundation::IAsyncOperation<bool> ExistAsync(winrt::hstring fileName);
  static winrt::Windows::Foundation::IAsyncOperation<winrt::hstring> GetPathAsync();
  static winrt::Windows::Foundation::IAsyncOperation<winrt::hstring> ChoiceFolderAsync(HWND hWnd);

public:
  static void Initialize(flutter::BinaryMessenger *messenger, const flutter::StandardMethodCodec *codec, HWND hWnd);
};