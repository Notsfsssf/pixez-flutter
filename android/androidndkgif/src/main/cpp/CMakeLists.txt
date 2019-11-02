cmake_minimum_required(VERSION 3.22.1)
project("androidndkgif")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(androidndkgif SHARED
   DataBlock.cpp
   BitmapIterator.cpp
   BitWritingBlock.cpp
   GifDecoder.cpp
   GifEncoder.cpp
   GifFrame.cpp
   com_waynejo_androidndkgif_GifDecoder.cpp
   com_waynejo_androidndkgif_GifEncoder.cpp
   GCTGifEncoder.cpp
   LCTGifEncoder.cpp
   FastGifEncoder.cpp
   SimpleGCTEncoder.cpp
   BaseGifEncoder.cpp
)

target_compile_definitions(androidndkgif PRIVATE
   __GXX_EXPERIMENTAL_CXX0X__
   __ANDROID_USE_LARGE_PAGES__
)

target_link_options(androidndkgif PRIVATE
   "LINKER:-z,max-page-size=16384"
   "LINKER:-z,common-page-size=16384"
)

target_link_libraries(androidndkgif
   jnigraphics
   log
)
