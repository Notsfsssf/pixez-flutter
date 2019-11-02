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

#include <stdio.h>
#include <stdint.h>
#include "BaseGifEncoder.h"
#include "LCTGifEncoder.h"
#include "FastGifEncoder.h"
#include "SimpleGCTEncoder.h"
#include "GCTGifEncoder.h"
#include "GifEncoder.h"
#include "BitWritingBlock.h"
#include <vector>

using namespace std;

GifEncoder::GifEncoder(EncodingType encodingType)
{
	switch (encodingType)
	{
	case ENCODING_TYPE_SIMPLE_FAST:
		gifEncoder = new SimpleGCTGifEncoder();
		break;
	case ENCODING_TYPE_FAST:
		gifEncoder = new FastGifEncoder();
		break;
	case ENCODING_TYPE_STABLE_HIGH_MEMORY:
		gifEncoder = new GCTGifEncoder();
		break;
	case ENCODING_TYPE_NORMAL_LOW_MEMORY:
	default:
		gifEncoder = new LCTGifEncoder();
		break;
	}
}

bool GifEncoder::init(uint16_t width, uint16_t height, const char* fileName)
{
	return gifEncoder->init(width, height, fileName);
}

void GifEncoder::release()
{
	gifEncoder->release();
}

void GifEncoder::setDither(bool useDither) {
	gifEncoder->setDither(useDither);
}

uint16_t GifEncoder::getWidth()
{
	return gifEncoder->getWidth();
}

uint16_t GifEncoder::getHeight()
{
	return gifEncoder->getHeight();
}

void GifEncoder::setThreadCount(int32_t threadCount)
{
	gifEncoder->setThreadCount(threadCount);
}

void GifEncoder::encodeFrame(uint32_t* pixels, int delayMs)
{
	gifEncoder->encodeFrame(pixels, delayMs);
}
