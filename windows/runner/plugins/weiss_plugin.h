#pragma once

#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>

class Weiss
{
private:
  static std::string name;
  static std::string port;

  static void Start(std::string json);
  static void Stop();
  static void Proxy();

public:
  static void Initialize(flutter::BinaryMessenger *messenger, const flutter::StandardMethodCodec *codec);
};
