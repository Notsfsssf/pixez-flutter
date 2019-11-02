/*
 * Copyright (c) 2015 waynejo
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "com_waynejo_androidndkgif_GifEncoder.h"
#include <stdint.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "GifEncoder.h"
#include <string.h>
#include <wchar.h>
#include <android/bitmap.h>

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT jlong JNICALL Java_com_waynejo_androidndkgif_GifEncoder_nativeInit
  (JNIEnv *env, jobject, jint width, jint height, jstring path, jint encodingType, jint threadCount)
{
    GifEncoder* gifEncoder = new GifEncoder(static_cast<EncodingType>(encodingType));
    gifEncoder->setThreadCount(threadCount);
    const char* pathChars = env->GetStringUTFChars(path, 0);
    bool result = gifEncoder->init(width, height, pathChars);
    env->ReleaseStringUTFChars(path, pathChars);
    if (result) {
        return (jlong) gifEncoder;
    } else {
        delete gifEncoder;
        return 0;
    }
}

JNIEXPORT void JNICALL Java_com_waynejo_androidndkgif_GifEncoder_nativeClose
  (JNIEnv *, jobject, jlong handle)
{
    GifEncoder* gifEncoder = (GifEncoder*)handle;
    gifEncoder->release();
    delete gifEncoder;
}

JNIEXPORT void JNICALL Java_com_waynejo_androidndkgif_GifEncoder_nativeSetDither
  (JNIEnv *, jobject, jlong handle, jboolean useDither)
{
    GifEncoder* gifEncoder = (GifEncoder*)handle;
    gifEncoder->setDither(useDither);
}

JNIEXPORT void JNICALL Java_com_waynejo_androidndkgif_GifEncoder_nativeSetThreadCount
  (JNIEnv *, jobject, jlong handle, jint threadCount)
{
    GifEncoder* gifEncoder = (GifEncoder*)handle;
    gifEncoder->setThreadCount(threadCount);
}

JNIEXPORT jboolean JNICALL Java_com_waynejo_androidndkgif_GifEncoder_nativeEncodeFrame
  (JNIEnv * env, jobject, jlong handle, jobject jBmpObj, jint delayMs)
{
    GifEncoder* gifEncoder = (GifEncoder*)handle;
    void* bitmapPixels;
    if (AndroidBitmap_lockPixels(env, jBmpObj, &bitmapPixels) < 0) {
        return false;
    }
    uint16_t imgWidth = gifEncoder->getWidth();
    uint16_t imgHeight = gifEncoder->getHeight();
    uint32_t* src = (uint32_t*) bitmapPixels;
    uint32_t* tempPixels = new unsigned int[imgWidth * imgHeight];
    int stride = imgWidth * 4;
    int pixelsCount = stride * imgHeight;
    memcpy(tempPixels, bitmapPixels, pixelsCount);
    AndroidBitmap_unlockPixels(env, jBmpObj);
    gifEncoder->encodeFrame(tempPixels, delayMs);
    delete[] tempPixels;
    return true;
}

#ifdef __cplusplus
}
#endif
