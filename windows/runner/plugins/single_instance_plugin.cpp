#include "single_instance_plugin.h"

#include <thread>
#include <winrt/base.h>

#include "../utils.h"

using namespace std;
using namespace flutter;
using namespace winrt;

LPCTSTR SingleInstance::name = TEXT("pixez");
LPCTSTR SingleInstance::pipePrefix = TEXT("\\\\.\\pipe\\");

void SingleInstance::Initialize(BinaryMessenger *messenger, const StandardMethodCodec *codec)
{
  string channelName = "pixez/single_instance";

  EventChannel<EncodableValue> channel(messenger, channelName, codec);

  OutputDebugString(TEXT("Initialize SingleInstance\n"));

  channel.SetStreamHandler(
      make_unique<StreamHandlerFunctions<EncodableValue>>(
          &SingleInstance::onListen,
          &SingleInstance::onCancel));
}

HANDLE SingleInstance::SetMutex()
{
  auto hMutex = CreateMutex(NULL, false, name);

  if (WaitForSingleObject(hMutex, 0) == WAIT_OBJECT_0)
    return hMutex;

  vector<string> command_line_arguments =
      GetCommandLineArguments();

  auto pipeName = (to_hstring(pipePrefix) + to_hstring(name)).c_str();

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

  stringstream ss;

  for (size_t i = 0; i < command_line_arguments.size(); i++)
  {
    ss << command_line_arguments.at(i);
    ss.seekp(-1, ios::cur);
    ss << "\n";
  }

  auto data = ss.str();
  DWORD resultSize = 0;
  WriteFile(hPipe, data.c_str(), (DWORD)data.size(), &resultSize, NULL);

  DisconnectNamedPipe(hPipe);
  CloseHandle(hPipe);

  return INVALID_HANDLE_VALUE;
}

unique_ptr<StreamHandlerError<EncodableValue>>
SingleInstance::onListen(
    const EncodableValue *arguments,
    unique_ptr<EventSink<EncodableValue>> &&events)
{
  thread t{sentEvent, move(events)};
  t.detach();

  return nullptr;
}

unique_ptr<StreamHandlerError<EncodableValue>>
SingleInstance::onCancel(
    const EncodableValue *arguments)
{
  return nullptr;
}

void SingleInstance::sentEvent(
    unique_ptr<EventSink<EncodableValue>> &&event)
{
  auto pipeName = (to_hstring(pipePrefix) + to_hstring(name)).c_str();

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

    string str{reinterpret_cast<char *>(buffer), resultSize};

    OutputDebugStringA((str + "\n").c_str());

    event.get()
        ->Success(EncodableValue(str));

    DisconnectNamedPipe(hPipe);
  }
}
