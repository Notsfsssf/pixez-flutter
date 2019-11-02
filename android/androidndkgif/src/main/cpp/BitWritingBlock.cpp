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

#include "BitWritingBlock.h"
#include <memory>

using namespace std;

BitWritingBlock::BitWritingBlock()
{
	currnet = new uint8_t[BLOCK_SIZE];
	memset(currnet, 0, BLOCK_SIZE);
	datas.push_back(currnet);
	pos = 0;
	remain = 8;
}

BitWritingBlock::~BitWritingBlock()
{
	for (list<uint8_t*>::iterator i = datas.begin(); i != datas.end(); ++i) {
		delete[] (*i);
	}
}

void BitWritingBlock::writeBits(uint32_t src, int32_t bitNum)
{
	while (0 < bitNum) {
		if (remain <= bitNum) {
			currnet[pos] = currnet[pos] | (src << (8 - remain));
			src >>= remain;
			bitNum -= remain;
			remain = 8;
			++pos;
			if (pos == BLOCK_SIZE) {
				currnet = new uint8_t[BLOCK_SIZE];
				memset(currnet, 0, BLOCK_SIZE);
				datas.push_back(currnet);
				pos = 0;
			}
		} else {
			currnet[pos] = (currnet[pos] << bitNum) | (((1 << bitNum) - 1) & src);
			remain -= bitNum;
			bitNum = 0;
		}
	}
}

void BitWritingBlock::writeByte(uint8_t b)
{
	writeBits(b, 8);
}

bool BitWritingBlock::toFile(FILE* dst)
{
	uint8_t size;
	for (list<uint8_t*>::iterator i = datas.begin(); i != datas.end(); ++i) {
		uint8_t* block = (*i);
		size = block == currnet ? (remain == 0 ? pos : pos + 1) : BLOCK_SIZE;
		fwrite(&size, 1, 1, dst);
		fwrite(block, size, 1, dst);
	}
	return true;
}
