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

#include "BitmapIterator.h"

BitmapIterator::BitmapIterator(GifDecoder* gifDecoder, std::shared_ptr<uint8_t> data, DataBlock dataBlock) : 
	gifDecoder(gifDecoder),
	data(data),
	dataBlock(dataBlock),
	hasNextFrame(false),
	isFinished(false)
{
}

bool BitmapIterator::hasNext()
{
	if (isFinished) {
		return false;
	}
	if (hasNextFrame) {
		return true;
	}
	uint32_t lastFrameCount = gifDecoder->getFrameCount();
	bool result = gifDecoder->readContents(&dataBlock, true);
	if (result && lastFrameCount != gifDecoder->getFrameCount()) {
		hasNextFrame = true;
		return true;
	}
	isFinished = true;
	return false;
}


bool BitmapIterator::next(const uint32_t** frame, uint32_t* delayMs)
{
	if (!hasNextFrame) {
		return false;
	}
	uint32_t index = gifDecoder->getFrameCount() - 1;
	*frame = gifDecoder->getFrame(index);
	*delayMs = gifDecoder->getDelay(index);
	hasNextFrame = false;
	return true;
}