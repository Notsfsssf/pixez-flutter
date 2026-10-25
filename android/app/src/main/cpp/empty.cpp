// 空占位库源文件：armeabi-v7a（32 位 ARM）不编 llama.cpp（地址空间
// 不足，产品决策禁止端侧模型），仅生成占位 so 满足 AGP 的 target 收集。
// Dart 侧运行时同步拦截（见 translation_service 的 kLocalLlmAbiSupported），
// 此库不会被实际调用。
extern "C" int llama_shim_placeholder;
extern "C" int llama_shim_placeholder = 0;
