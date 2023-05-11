#include "Saver.h"
#include <shlobj.h>
#include <iostream>
#include <fstream>

#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/encodable_value.h>

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
                OutputDebugString(L"initDocumentMethodChannel:save");
                const auto *arguments = std::get_if<flutter::EncodableMap>(call.arguments());
                auto data = arguments->find(flutter::EncodableValue("data"))->second;
                auto name = arguments->find(flutter::EncodableValue("name"))->second;
                std::vector<uint8_t> vector = std::get<std::vector<uint8_t>>(data);
                std::string fileName = std::get<std::string>(name);
                Saver::saveToPixezFolder(vector, fileName);
                result->Success(true);
            }
            else
            {
                result->Success("pass result here");
            }
        });
}

void Saver::saveToPixezFolder(const std::vector<uint8_t> &data, const std::string &name)
{
    PWSTR picturesPath;
    HRESULT result = SHGetKnownFolderPath(
        FOLDERID_Pictures, 0, nullptr, &picturesPath);
    if (!SUCCEEDED(result))
    {
        std::cerr << "Failed to get Pictures folder path" << std::endl;
        return;
    }
    std::wstring pixezFolderPath = std::wstring(picturesPath) + L"\\Pixez";
    CreateDirectoryW(pixezFolderPath.c_str(), nullptr);
    std::wstring filePath = pixezFolderPath + L"\\" + std::wstring(name.begin(), name.end());
    std::ofstream file(filePath, std::ofstream::binary);
    if (!file.is_open())
    {
        std::cerr << "Failed to open file for writing" << std::endl;
        return;
    }
    file.write(reinterpret_cast<const char *>(data.data()), sizeof(uint8_t) * data.size());
    file.close();
    CoTaskMemFree(picturesPath);
}