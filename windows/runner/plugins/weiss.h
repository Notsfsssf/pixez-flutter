#pragma once

#include <flutter/flutter_engine.h>

class Weiss
{
private:
  static std::string name;
  static std::string port;
  
  static void Start(std::string json);
  static void Stop();
  static void Proxy();
public:
  static void Initialize(flutter::FlutterEngine *engine);
};
