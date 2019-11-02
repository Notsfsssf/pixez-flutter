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

#pragma once

#include <vector>
#include <memory>
#include <stdint.h>
#include "DataBlock.h"
#include "GifFrame.h"

class BitmapIterator;

class GifDecoder
{
	friend class BitmapIterator;
private:
	static const int32_t MAX_STACK_SIZE = 4096;

	std::vector<GifFrame> frames;
	uint16_t width;
	uint16_t height;
	bool interlace;
	bool gctFlag;
	uint32_t gctSize;
	uint8_t bgIndex;
	uint8_t pixelAspect;
	uint32_t gct[256]; // [0] ->r, [1] -> g, [2] -> b, max size to avoid bounds checks
	uint8_t block[256];
	uint16_t ix, iy, iw, ih;
	uint32_t bgColor;
	uint32_t loopCount; // iterations; 0 = repeat forever
	uint32_t dispose; // 0=no action; 1=leave in place; 2=restore to bg; 3=restore to prev
	bool transparency; // use transparent color
	uint16_t delay;
	uint8_t transIndex;
	int32_t frameCount;
	uint8_t* pixels;

	uint32_t lastDispose;
	uint16_t lrx, lry, lrw, lrh;
	uint32_t lastBgColor;
	uint32_t* image;
	const uint32_t* lastBitmap;

	BitmapIterator* lastBitmapIterator;

	void init();

	bool readLSD(DataBlock* dataBlock);
	bool readColorTable(DataBlock* dataBlock, uint32_t* colorTable, int32_t ncolors);
	bool readHeader(DataBlock* dataBlock);

	bool readContents(DataBlock* dataBlock, bool isAFrameNeeded = false);
	bool skip(DataBlock* dataBlock);
	bool readBlock(DataBlock* dataBlock, uint8_t* blockSize);
	bool readNetscapeExt(DataBlock* dataBlock);
	bool readGraphicControlExt(DataBlock* dataBlock);
	bool readBitmap(DataBlock* dataBlock);
	void resetFrame();
	bool decodeBitmapData(DataBlock* dataBlock);
	void setPixels(uint32_t* act);

public:
	GifDecoder(void);
	~GifDecoder(void);

	bool load(const char* fileName);
	BitmapIterator* loadUsingIterator(const char* fileName);
	bool loadFromMemory(const uint8_t* data, uint32_t size);
	BitmapIterator* loadFromMemoryUsingIterator(std::shared_ptr<uint8_t> data, uint32_t size);
	uint32_t getFrameCount();
	const uint32_t* getFrame(int32_t n);
	uint32_t getDelay(int32_t n);

	uint32_t getWidth();
	uint32_t getHeight();
};

