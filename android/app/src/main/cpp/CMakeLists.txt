# 端侧翻译推理：llama.cpp（GGUF）+ 极薄 C shim。
#
# llama.cpp 源码 vendored 在 build/mirror/llama/llama.cpp-0.7.0
# （源 tarball 留档于 build/tmp/llama-dl/llama-v0.7.0.tar.gz，
#  从 https://github.com/ggml-org/llama.cpp tag v0.7.0 获取）。
#
# ABI 策略：armeabi-v7a（32 位）**不编 llama.cpp**——地址空间 ~3GB，
# 1GB 权重 + KV cache 极易 OOM，产品决策禁止端侧模型（只能用云端 API），
# Dart 侧运行时同步拦截（translation_service 的 kLocalLlmAbiSupported）。
# armv7 仍生成空占位库以满足 AGP 的 target 收集。
cmake_minimum_required(VERSION 3.22)
project(llamashim LANGUAGES CXX)

# AGP 的 debug variant 默认传 CMAKE_BUILD_TYPE=Debug（-O0），llama.cpp / ggml
# 大量标量循环在 -O0 下慢 20~30 倍（真机实测 decode 12s/token，Release 正常
# 速度应在 0.3~0.5s/token 量级）。推理库无论 APK debug 与否一律按 Release 优化。
if(NOT CMAKE_BUILD_TYPE MATCHES "Release|RelWithDebInfo|MinSizeRel")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
endif()

if(ANDROID AND ANDROID_ABI STREQUAL "armeabi-v7a")
    add_library(llamashim SHARED empty.cpp)
    return()
endif()

set(LLAMA_CPP_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../../build/mirror/llama/llama.cpp-0.7.0")
if(NOT EXISTS "${LLAMA_CPP_DIR}/CMakeLists.txt")
    message(FATAL_ERROR
        "llama.cpp 源码缺失：${LLAMA_CPP_DIR}\n"
        "重新解包：mkdir -p build/mirror/llama && tar -xzf build/tmp/llama-dl/llama-v0.7.0.tar.gz -C build/mirror/llama/")
endif()

# 以子目录方式接入（非 standalone）：只编 ggml + llama 核心库，
# 不编 common / tests / examples / server。
set(LLAMA_STANDALONE     OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_COMMON   OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TESTS    OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER   OFF CACHE BOOL "" FORCE)
# NDK 无 libomp；交叉编译禁用本机 arch 探测。
set(GGML_OPENMP OFF CACHE BOOL "" FORCE)
if(ANDROID)
    set(GGML_NATIVE OFF CACHE BOOL "" FORCE)
endif()
add_subdirectory("${LLAMA_CPP_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/llama-build" EXCLUDE_FROM_ALL)

# 上游把 ~50 个源文件合成 3-4 个巨型翻译单元（UNITY_BUILD BATCH_SIZE 16），
# 多核机器上尾段只剩一两个核在编；拆散换取并行均衡（构建提速）。
set_target_properties(llama PROPERTIES UNITY_BUILD OFF)

add_library(llamashim SHARED llama_shim.cpp)
target_include_directories(llamashim PRIVATE "${LLAMA_CPP_DIR}/include")
# liblog：SHIM_LOG 用 __android_log_print 把多序列诊断（每序列生成
# token 数）打到 logcat，标签 llama_shim。
if(ANDROID)
    target_link_libraries(llamashim PRIVATE llama log)
else()
    target_link_libraries(llamashim PRIVATE llama)
endif()
