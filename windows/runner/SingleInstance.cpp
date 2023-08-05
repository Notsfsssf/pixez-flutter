#include <winrt/base.h>

#include "utils.h"
#include "SingleInstance.h"

LPCTSTR SingleInstance::name = TEXT("pixez");
LPCTSTR SingleInstance::pipePrefix = TEXT("\\\\.\\pipe\\");

void SingleInstance::Initialize(flutter::FlutterEngine *engine)
{
  std::string channelName = "pixez/single_instance";
  const auto &codec = flutter::StandardMethodCodec::GetInstance();

  flutter::EventChannel<flutter::EncodableValue> channel(
      engine->messenger(),
      channelName,
      &codec);

  OutputDebugString(TEXT("Initialize SingleInstance\n"));

  channel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          &SingleInstance::onListen,
          &SingleInstance::onCancel));
}

HANDLE SingleInstance::SetMutex()
{
  auto hMutex = CreateMutex(NULL, false, name);

  if (WaitForSingleObject(hMutex, 0) == WAIT_OBJECT_0)
    return hMutex;

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  auto pipeName = (winrt::to_hstring(pipePrefix) + winrt::to_hstring(name)).c_str();

  // 判断是否有可以利用的命名管道
  if (!WaitNamedPipeW(pipeName, NMPWAIT_USE_DEFAULT_WAIT))
    return INVALID_HANDLE_VALUE;

  auto hPipe = CreateFileW(
      pipeName,
      GENERIC_WRITE,
      FILE_SHARE_READ | FILE_SHARE_WRITE,
      NULL,
      OPEN_EXISTING,
      0,
      NULL);

  std::stringstream ss;

  for (size_t i = 0; i < command_line_arguments.size(); i++)
  {
    ss << command_line_arguments.at(i);
    ss.seekp(-1, std::ios::cur);
    ss << "\n";
  }

  auto data = ss.str();
  DWORD resultSize = 0;
  WriteFile(hPipe, data.c_str(), (DWORD)data.size(), &resultSize, NULL);

  DisconnectNamedPipe(hPipe);
  CloseHandle(hPipe);

  return INVALID_HANDLE_VALUE;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
SingleInstance::onListen(
    const flutter::EncodableValue *arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
{
  std::thread t{sentEvent, std::move(events)};
  t.detach();

  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
SingleInstance::onCancel(
    const flutter::EncodableValue *arguments)
{
  return nullptr;
}

void SingleInstance::sentEvent(
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&event)
{
  auto pipeName = (winrt::to_hstring(pipePrefix) + winrt::to_hstring(name)).c_str();

  OutputDebugString(TEXT("SingleInstance CreateNamedPipe\n"));
  auto hPipe = CreateNamedPipeW(
      pipeName,
      PIPE_ACCESS_DUPLEX,
      PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
      PIPE_UNLIMITED_INSTANCES,
      0, 0,
      NMPWAIT_USE_DEFAULT_WAIT,
      NULL);

  if (hPipe == INVALID_HANDLE_VALUE)
    return;

  const size_t size = 512;
  BYTE buffer[size];
  DWORD resultSize = 0;
  while (true)
  {
    OutputDebugString(TEXT("SingleInstance::SentEvent: Waiting Connect...\n"));
    if (!ConnectNamedPipe(hPipe, NULL) || !ReadFile(hPipe, buffer, size, &resultSize, NULL))
    {
      OutputDebugString(TEXT("Unknown Error\n"));
      continue;
    }

    std::string str{reinterpret_cast<char *>(buffer), resultSize};

    OutputDebugStringA((str + "\n").c_str());

    event.get()
        ->Success(flutter::EncodableValue(str));

    DisconnectNamedPipe(hPipe);
  }
}
