#include "Saver.h"
#include <shlobj.h>
#include <iostream>
#include <fstream>

#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/encodable_value.h>

#include <pplawait.h>
#include <winrt/windows.foundation.h>
#include <winrt/windows.storage.h>

void Saver::initMethodChannel(flutter::FlutterEngine *flutter_instance)
{
    const static std::string channel_name("com.perol.dev/save");
    auto channel =
        std::make_unique<flutter::MethodChannel<>>(
            flutter_instance->messenger(), channel_name,
            &flutter::StandardMethodCodec::GetInstance());
    channel->SetMethodCallHandler(
        [](const flutter::MethodCall<> &call,
           std::unique_ptr<flutter::MethodResult<>> result)
        {
            if (call.method_name().compare("save") == 0)
            {
                OutputDebugString(TEXT("initDocumentMethodChannel:save\n"));
                const auto *arguments = std::get_if<flutter::EncodableMap>(call.arguments());
                auto data = arguments->find(flutter::EncodableValue("data"))->second;
                auto name = arguments->find(flutter::EncodableValue("name"))->second;
                std::vector<uint8_t> vector = std::get<std::vector<uint8_t>>(data);
                std::string fileName = std::get<std::string>(name);
                Saver::saveToPixezFolder(vector, fileName).get();
                result->Success(true);
            }
            else
            {
                result->Success("pass result here");
            }
        });
}

concurrency::task<void> Saver::saveToPixezFolder(const std::vector<uint8_t> &data, const std::string &name)
{
    using namespace winrt;
    using namespace Windows::Storage;

    co_await winrt::resume_background();
    auto base = KnownFolders::SavedPictures();
    auto folder = co_await base.CreateFolderAsync(L"PixEz", CreationCollisionOption::OpenIfExists);
    auto file = co_await folder.CreateFileAsync(to_hstring(name), CreationCollisionOption::ReplaceExisting);
    co_await FileIO::WriteBytesAsync(file, data);
}