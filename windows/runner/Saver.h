#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <ShlObj.h>
#include <flutter/flutter_engine.h>

class Saver {
public:
    static void initMethodChannel(flutter::FlutterEngine *flutter_instance);
    static void saveToPixezFolder(const std::vector<uint8_t> &data, const std::string &name);
};