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

#include "DataBlock.h"
#include <string.h>

DataBlock::DataBlock(const uint8_t* data, int32_t remain) : 
	remain(remain)
{
	this->data = data;
}

DataBlock::DataBlock(const DataBlock& dataBlock)
{
	this->data = dataBlock.data;
	this->remain = dataBlock.remain;
}

DataBlock::~DataBlock(void)
{
}

bool DataBlock::read(uint8_t* dst, int32_t size)
{
	if (remain < size) {
		return false;
	}
	memcpy(dst, data, size);
	
	data += size;
	remain -= size;
	return true;
}

bool  DataBlock::read(uint16_t* dst)
{
	return read((uint8_t*)dst, 2);
}