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

package com.waynejo.androidndkgif;

import android.graphics.Bitmap;

import java.io.FileNotFoundException;
import java.util.Locale;

public class GifEncoder {

    static {
        System.loadLibrary("androidndkgif");
    }

    public enum EncodingType {
        ENCODING_TYPE_SIMPLE_FAST,
        ENCODING_TYPE_FAST,
        ENCODING_TYPE_NORMAL_LOW_MEMORY,
        ENCODING_TYPE_STABLE_HIGH_MEMORY
    }

    private native long nativeInit(int width, int height, String path, int encodingType, int threadCount);
    private native void nativeClose(long handle);
    private native void nativeSetDither(long handle, boolean useDither);
    private native void nativeSetThreadCount(long handle, int threadCount);

    private native boolean nativeEncodeFrame(long handle, Bitmap bitmap, int delayMs);

    private long instance = 0;
    private int threadCount = 1;

    private int width;
    private int height;

    public void init(int width, int height, String path) throws FileNotFoundException {
        init(width, height, path, EncodingType.ENCODING_TYPE_NORMAL_LOW_MEMORY);
    }

    public void init(int width, int height, String path, EncodingType encodingType) throws FileNotFoundException {
        if (0 != instance) {
            close();
        }
        this.width = width;
        this.height = height;
        instance = nativeInit(width, height, path, encodingType.ordinal(), threadCount);
        if (0 == instance) {
            throw new FileNotFoundException();
        }
    }

    public void close() {
        nativeClose(instance);
        instance = 0;
    }

    public void setDither(boolean useDither) {
        if (0 == instance) {
            return ;
        }
        nativeSetDither(instance, useDither);
    }

    public void setThreadCount(int threadCount) {
        this.threadCount = threadCount;
        if (0 == instance) {
            return;
        }
        nativeSetThreadCount(instance, threadCount);
    }

    public boolean encodeFrame(Bitmap bitmap, int delayMs) {
        if (0 == instance) {
            return false;
        }
        if (bitmap.getWidth() != width || bitmap.getHeight() != height) {
            String errorMessage = String.format(Locale.ENGLISH, "The size specified at initialization differs from the size of the image.\n expected:(%d, %d) actual:(%d,%d)", width, height, bitmap.getWidth(), bitmap.getHeight());
            throw new RuntimeException(errorMessage);
        }
        nativeEncodeFrame(instance, bitmap, delayMs);
        return true;
    }
}
