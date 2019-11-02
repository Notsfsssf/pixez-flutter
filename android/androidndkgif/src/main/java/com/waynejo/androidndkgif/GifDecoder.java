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

public class GifDecoder {

    static {
        System.loadLibrary("androidndkgif");
    }

    private native long nativeInit();
    private native void nativeClose(long handle);

    private native boolean nativeLoad(long handle, String fileName);
    private native long nativeLoadUsingIterator(long handle, String fileName);

    private native int nativeGetFrameCount(long handle);

    private native Bitmap nativeGetFrame(long handle, int n);
    private native int nativeGetDelay(long handle, int n);

    private native int nativeGetWidth(long handle);
    private native int nativeGetHeight(long handle);

    private native boolean nativeBitmapIteratorHasNext(long handle);
    private native GifImage nativeBitmapIteratornext(long decoderHandle, long iteratorHandle);

    private int width = 0;
    private int height = 0;

    private Bitmap[] bitmaps = new Bitmap[0];
    private int[] delays = new int[0];
    private int frameNum;

    private boolean hasUnclosedIterator = false;

    public boolean load(String fileName) {
        long handle = nativeInit();
        if (!nativeLoad(handle, fileName)) {
            nativeClose(handle);
            return false;
        }
        width = nativeGetWidth(handle);
        height = nativeGetHeight(handle);

        frameNum = nativeGetFrameCount(handle);
        bitmaps = new Bitmap[frameNum];
        delays = new int[frameNum];
        for (int i = 0; i < frameNum; ++i) {
            bitmaps[i] = nativeGetFrame(handle, i);
            delays[i] = nativeGetDelay(handle, i);
        }

        nativeClose(handle);
        return true;
    }

    public GifImageIterator loadUsingIterator(String fileName) {
        if (hasUnclosedIterator) {
            return null;
        }

        final long handle = nativeInit();

        final long iteratorHandle = nativeLoadUsingIterator(handle, fileName);
        if (0 == iteratorHandle) {
            nativeClose(handle);
            return null;
        }
        width = nativeGetWidth(handle);
        height = nativeGetHeight(handle);
        hasUnclosedIterator = true;

        return new GifImageIterator() {
            boolean isClosed = false;

            @Override
            public boolean hasNext() {
                return nativeBitmapIteratorHasNext(iteratorHandle);
            }

            @Override
            public GifImage next() {
                return nativeBitmapIteratornext(handle, iteratorHandle);
            }

            @Override
            public void close() {
                if (!isClosed) {
                    nativeClose(handle);
                    hasUnclosedIterator = false;
                    isClosed = true;
                }
            }
        };
    }

    public int width() {
        return width;
    }

    public int height() {
        return height;
    }

    public int frameNum() {
        return frameNum;
    }

    public Bitmap frame(int idx) {
        if (0 == frameNum) {
            return null;
        }
        return bitmaps[idx % frameNum];
    }

    // It is not supported when using Iterator.
    public int delay(int idx) {
        if (0 == frameNum) {
            return 0;
        }
        return delays[idx % frameNum];
    }
}
