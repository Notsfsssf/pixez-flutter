#include "document_plugin.h"
#include "paths_plugin.h"
#include "../settings.h"

#include <future>
#include <Shobjidl.h>
#include <flutter/method_channel.h>
#include <winrt/windows.data.json.h>
#include <winrt/windows.foundation.h>
#include <winrt/windows.foundation.collections.h>
#include <winrt/windows.storage.h>
#include <winrt/windows.storage.accesscache.h>
#include <winrt/windows.storage.pickers.h>
#include <winrt/windows.storage.search.h>

using namespace std;
using namespace flutter;
using namespace winrt;
using namespace Windows::Data::Json;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::Storage;
using namespace Windows::Storage::AccessCache;
using namespace Windows::Storage::Pickers;

string Document::name = "com.perol.dev/save";
hstring savedFolderToken = L"SavedFolderToken";

void Document::Initialize(BinaryMessenger *messenger, const StandardMethodCodec *codec, HWND hWnd)
{
  MethodChannel<EncodableValue> channel(messenger, name, codec);

  channel.SetMethodCallHandler(
      [hWnd](const MethodCall<EncodableValue> &call,
             unique_ptr<MethodResult<EncodableValue>> result) -> std::future<void>
      {
        init_apartment(apartment_type::single_threaded);

        const auto *arguments = get_if<EncodableMap>(call.arguments());
        if (call.method_name().compare("save") == 0)
        {
          auto data = get<vector<uint8_t>>(arguments->find(EncodableValue("data"))->second);
          auto name = to_hstring(get<string>(arguments->find(EncodableValue("name"))->second));
          auto resultData = co_await SaveAsync(data, name);
          result->Success(resultData);
        }
        else if (call.method_name().compare("openSave") == 0)
        {
          auto data = get<vector<uint8_t>>(arguments->find(EncodableValue("data"))->second);
          auto name = to_hstring(get<string>(arguments->find(EncodableValue("name"))->second));
          auto resultData = co_await OpenSaveAsync(data, name, hWnd);
          result->Success(resultData);
        }
        else if (call.method_name().compare("permissionStatus") == 0)
        {
          // 不实现
          result->Success();
        }
        else if (call.method_name().compare("requestPermission") == 0)
        {
          // 不实现
          result->Success();
        }
        else if (call.method_name().compare("exist") == 0)
        {
          auto name = to_hstring(get<string>(arguments->find(EncodableValue("name"))->second));
          auto resultData = co_await ExistAsync(name);
          result->Success(resultData);
        }
        else if (call.method_name().compare("get_path") == 0)
        {
          auto resultData = co_await GetPathAsync();
          result->Success(to_string(resultData));
        }
        else if (call.method_name().compare("choice_folder") == 0)
        {
          auto resultData = co_await ChoiceFolderAsync(hWnd);
          result->Success(to_string(resultData));
        }

        uninit_apartment();
      });
}

IAsyncOperation<StorageFolder> GetFolderAsync()
{
  auto value = co_await Settings::TryGetValueAsync(savedFolderToken);
  if (value.empty())
  {
    auto folder = KnownFolders::SavedPictures();
    if (!folder)
      folder = KnownFolders::PicturesLibrary();

    folder = co_await folder.CreateFolderAsync(
        L"Pixez",
        CreationCollisionOption::OpenIfExists);

    co_return folder;
  }

  co_return co_await StorageFolder::GetFolderFromPathAsync(value);
}

IAsyncOperation<bool> Document::SaveAsync(const vector<uint8_t> &data, hstring fileName)
{
  auto folder = co_await GetFolderAsync();

  auto file = co_await folder.CreateFileAsync(
      fileName,
      CreationCollisionOption::ReplaceExisting);
  if (!file)
    co_return false;

  co_await FileIO::WriteBytesAsync(file, data);

  co_return true;
}

IAsyncOperation<bool> Document::OpenSaveAsync(const vector<uint8_t> &data, hstring fileName, HWND hWnd)
{
  wstring fileName1{fileName};
  auto ext = fileName1.substr(fileName1.find(L"."), fileName1.size());
  IVector<hstring> coll{single_threaded_vector<hstring>()};
  coll.Append(ext);

  FileSavePicker picker = {};
  picker.SuggestedFileName(fileName);
  picker.SuggestedStartLocation(PickerLocationId::PicturesLibrary);
  picker.FileTypeChoices().Insert(L"File", coll);

  auto initializeWithWindow{picker.as<::IInitializeWithWindow>()};
  initializeWithWindow->Initialize(hWnd);

  auto file = co_await picker.PickSaveFileAsync();
  if (!file)
    co_return false;

  co_await FileIO::WriteBytesAsync(file, data);

  co_return true;
}

IAsyncOperation<bool> Document::ExistAsync(hstring fileName)
{
  auto folder = co_await GetFolderAsync();

  auto list = co_await folder.CreateFileQuery().GetFilesAsync();

  for (uint32_t i = 0; i < list.Size(); i++)
  {
    auto file = list.GetAt(i);

    if (file.Name() == fileName)
      co_return true;
  }

  co_return false;
}

IAsyncOperation<hstring> Document::GetPathAsync()
{
  auto folder = co_await GetFolderAsync();
  co_return folder.Path();
}

IAsyncOperation<hstring> Document::ChoiceFolderAsync(HWND hWnd)
{
  FolderPicker picker = {};
  picker.SuggestedStartLocation(PickerLocationId::PicturesLibrary);
  picker.FileTypeFilter().Append(L"*");

  auto initializeWithWindow{picker.as<::IInitializeWithWindow>()};
  initializeWithWindow->Initialize(hWnd);

  auto folder = co_await picker.PickSingleFolderAsync();
  if (!folder)
  {
    folder = co_await GetFolderAsync();
    co_return folder.Path();
  }
  co_await Settings::SetValueAsync(savedFolderToken, folder.Path());

  co_return folder.Path();
}
