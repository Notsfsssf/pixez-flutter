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

#include "GifDecoder.h"
#include "DataBlock.h"
#include "BitmapIterator.h"

template< typename T >
struct array_deleter
{
	void operator ()( T const * p)
	{
		delete[] p;
	}
};

GifDecoder::GifDecoder()
{
	pixels = NULL;
	lastBitmapIterator = NULL;
}

GifDecoder::~GifDecoder()
{
	if (NULL != pixels) {
		delete[] pixels;
		pixels = NULL;
	}
	for (std::vector<GifFrame>::iterator i = frames.begin(); i != frames.end(); ++i) {
		delete i->data;
	}
	delete lastBitmapIterator;
}

void GifDecoder::init()
{
	loopCount = 1;
	dispose = 0;
	lastDispose = 0;
	transparency = false;
	delay = 0;
	frameCount = 0;
	width = 0;
	height = 0;
	interlace = false;
	if (NULL != pixels) {
		delete[] pixels;
		pixels = NULL;
	}
	image = NULL;
	lastBitmap = NULL;
}

bool GifDecoder::load(const char* fileName)
{
	init();

	FILE* fp = fopen(fileName, "rb");
	if (NULL == fp) {
		return false;
	}
	fseek(fp, 0, SEEK_END);
	int32_t fileSize = ftell(fp);
	uint8_t* data = new uint8_t[fileSize];
	rewind(fp);
	fread(data, fileSize, 1, fp);
	fclose(fp);

	bool result = loadFromMemory(data, fileSize);
	delete[] data;

	return result;
}

BitmapIterator* GifDecoder::loadUsingIterator(const char* fileName)
{
	init();

	FILE* fp = fopen(fileName, "rb");
	if (NULL == fp) {
		return NULL;
	}
	fseek(fp, 0, SEEK_END);
	int32_t fileSize = ftell(fp);
	uint8_t* data = new uint8_t[fileSize];
	rewind(fp);
	fread(data, fileSize, 1, fp);
	fclose(fp);

	return loadFromMemoryUsingIterator(std::shared_ptr<uint8_t>(data, array_deleter<uint8_t>()), fileSize);
}

bool GifDecoder::loadFromMemory(const uint8_t* data, uint32_t size)
{
	DataBlock dataBlock(data, size);
	if (!readHeader(&dataBlock)) {
		return false;
	}
	return readContents(&dataBlock);
}

BitmapIterator* GifDecoder::loadFromMemoryUsingIterator(std::shared_ptr<uint8_t> data, uint32_t size)
{
	DataBlock dataBlock(data.get(), size);
	if (!readHeader(&dataBlock)) {
		return NULL;
	}
	if (NULL != lastBitmapIterator) {
		delete lastBitmapIterator;
	}

	lastBitmapIterator = new BitmapIterator(this, data, dataBlock);
	return lastBitmapIterator;
}

bool GifDecoder::readLSD(DataBlock* dataBlock)
{
	// logical screen size
	if (!dataBlock->read(&width) || !dataBlock->read(&height)) {
		return false;
	}

	// packed fields
	uint8_t packed;
	if (!dataBlock->read(&packed, 1)) {
		return false;
	}
	gctFlag = (packed & 0x80) != 0; // 1 : global color table flag
	// 2-4 : color resolution
	// 5 : gct sort flag
	gctSize = 2 << (packed & 7); // 6-8 : gct size
	if (!dataBlock->read(&bgIndex, 1)) { // background color index
		return false;
	}
	if (!dataBlock->read(&pixelAspect, 1)) { // pixel aspect ratio
		return false;
	}
	return true;
}

bool GifDecoder::readColorTable(DataBlock* dataBlock, uint32_t* colorTable, int32_t ncolors)
{
	for (int32_t i = 0; i < ncolors; ++i) {
		if (!dataBlock->read((uint8_t*)(colorTable + i), 3)) {
			return false;
		}
		colorTable[i] |= 0xFF000000;
	}
	return true;
}

bool GifDecoder::readHeader(DataBlock* dataBlock)
{
	uint8_t buffer[6];
	if (!dataBlock->read(buffer, 6)) {
		return false;
	}
	if (0 != memcmp("GIF", buffer, 3)) {
		return false;
	}

    if (!readLSD(dataBlock)) {
		return false;
	}

	if (gctFlag) {
		if (!readColorTable(dataBlock, gct, gctSize)) {
			return false;
		}
		bgColor = gct[bgIndex];
 	}
	return true;
}

bool GifDecoder::readContents(DataBlock* dataBlock, bool isAFrameNeeded)
{
	// read GIF file content blocks
	uint8_t code;
	while (true) {
		if (!dataBlock->read(&code, 1)) {
			return false;
		}
		switch (code) {
		case 0x2C: // image separator
			if (!readBitmap(dataBlock)) {
				return false;
			} else if (isAFrameNeeded) {
				if (1 < frameCount) {
					delete[] frames[frameCount - 2].data;
					frames[frameCount - 2].data = NULL;
				}
				return true;
			}
			break;
		case 0x21: // extension
			if (!dataBlock->read(&code, 1)) {
				return false;
			}
			switch (code) {
			case 0xf9: // graphics control extension
				if (!readGraphicControlExt(dataBlock)) {
					return false;
				}
				break;
			case 0xff: // application extension
				uint8_t blockSize;
				readBlock(dataBlock, &blockSize);
				if (0 == memcmp("NETSCAPE2.0", block, 11)) {
					if (!readNetscapeExt(dataBlock)) {
						return false;
					}
				} else { // don't care
					if (!skip(dataBlock)) {
						return false;
					}
				}
				break;
			case 0xfe:// comment extension
				if (!skip(dataBlock)) {
					return false;
				}
				break;
			case 0x01:// plain text extension
				if (!skip(dataBlock)) {
					return false;
				}
				break;
			default: // uninteresting extension
				if (!skip(dataBlock)) {
					return false;
				}
			}
			break;
		case 0x3b: // terminator
			return true;
		case 0x00: // bad byte, but keep going and see what happens break;
		default:
			return false;
		}
	}
}

bool GifDecoder::skip(DataBlock* dataBlock)
{
	uint8_t blockSize;
	do {
		if (!readBlock(dataBlock, &blockSize)) {
			return false;
		}
	} while ((blockSize > 0));
	return true;
}

bool GifDecoder::readBlock(DataBlock* dataBlock, uint8_t* blockSize)
{
	dataBlock->read(blockSize, 1);
	return *blockSize <= 0 || dataBlock->read(block, *blockSize);
}

bool GifDecoder::readNetscapeExt(DataBlock* dataBlock)
{
	uint8_t blockSize;
	do {
		if (!readBlock(dataBlock, &blockSize)) {
			return false;
		}
		if (block[0] == 1) {
			// loop count sub-block
			int32_t b1 = ((int32_t) block[1]) & 0xff;
			int32_t b2 = ((int32_t) block[2]) & 0xff;
			loopCount = (b2 << 8) | b1;
		}
	} while ((blockSize > 0));
	return true;
}

bool GifDecoder::readGraphicControlExt(DataBlock* dataBlock)
{
	uint8_t unused;
	if (!dataBlock->read(&unused, 1)) { // block size
		return false;
	}
	uint8_t packed;
	if (!dataBlock->read(&packed, 1)) { // packed fields)
		return false;
	}
	dispose = (packed & 0x1c) >> 2; // disposal method
	if (dispose == 0) {
		dispose = 1; // elect to keep old image if discretionary
	}
	transparency = (packed & 1) != 0;
	if (!dataBlock->read(&delay)) {
		return false;
	}
	delay *= 10; // delay in milliseconds
	if (!dataBlock->read(&transIndex, 1)) {// transparent color index)
		return false;
	}
	return dataBlock->read(&unused, 1); // block terminator
}

bool GifDecoder::readBitmap(DataBlock* dataBlock)
{
	uint8_t packed;
	if (!dataBlock->read(&ix) || !dataBlock->read(&iy) ||  // (sub)image position & size
		!dataBlock->read(&iw) || !dataBlock->read(&ih) || !dataBlock->read(&packed, 1)) {
		return false;
	}

	bool lctFlag = (packed & 0x80) != 0; // 1 - local color table flag interlace
	int32_t lctSize = 2 << (packed & 0x07);
	// 3 - sort flag
	// 4-5 - reserved lctSize = 2 << (packed & 7); // 6-8 - local color
	// table size
	interlace = (packed & 0x40) != 0;
	uint32_t lct[256];
	uint32_t* act;
	if (lctFlag) {
		if (!readColorTable(dataBlock, lct, lctSize)) { // read table
			return false;
		}
		act = lct; // make local table active
	} else {
		act = gct; // make global table active
		if (bgIndex == transIndex) {
			bgColor = 0;
		}
	}
	uint32_t save;
	if (transparency) {
		save = act[transIndex];
		act[transIndex] = 0; // set transparent color if specified
	}

	if (!decodeBitmapData(dataBlock) || !skip(dataBlock)) { // decode pixel data
		return false;
	}

	frameCount++;
	// create new image to receive frame data
	setPixels(act); // transfer pixel data to image

	if (transparency) {
		act[transIndex] = save;
	}
	resetFrame();
	return true;
}

void GifDecoder::resetFrame()
{
	lastDispose = dispose;
	lrx = ix;
	lry = iy;
	lrw = iw;
	lrh = ih;
	lastBitmap = image;
	lastBgColor = bgColor;
	dispose = 0;
	transparency = false;
	delay = 0;
}

bool GifDecoder::decodeBitmapData(DataBlock* dataBlock)
{
	int32_t nullCode = -1;
	int32_t npix = iw * ih;
	int32_t available, clear, code_mask, code_size, end_of_information, in_code, old_code, bits, code, i, top, bi, pi;
	uint32_t datum, first;
	uint8_t count, data_size;
	if (NULL == pixels) {
		pixels = new uint8_t[npix]; // allocate new pixel array
	} else if (lrw != iw || lrh != ih) {
		delete[] pixels;
		pixels = new uint8_t[npix];
	}

	uint16_t prefix[MAX_STACK_SIZE];
	uint8_t suffix[MAX_STACK_SIZE];
	uint8_t pixelStack[MAX_STACK_SIZE + 1];

	// Initialize GIF data stream decoder.
	if (!dataBlock->read(&data_size, 1)) {
		return false;
	}
	clear = 1 << data_size;
	end_of_information = clear + 1;
	available = clear + 2;
	old_code = nullCode;
	code_size = data_size + 1;
	code_mask = (1 << code_size) - 1;
	for (code = 0; code < clear; code++) {
		prefix[code] = 0; // XXX ArrayIndexOutOfBoundsException
		suffix[code] = code;
	}
	// Decode GIF pixel stream.
	datum = bits = first = top = pi = bi = count = 0;
	for (i = 0; i < npix;) {
		if (top == 0) {
			if (bits < code_size) {
				// Load bytes until there are enough bits for a code.
				if (count == 0) {
					// Read a new data block.
					if (!readBlock(dataBlock, &count)) {
						return false;
					}
					if (count <= 0) {
						break;
					}
					bi = 0;
				}
				datum |= ((uint32_t) block[bi]) << bits;
				bits += 8;
				bi++;
				count--;
				continue;
			}
			// Get the next code.
			code = (datum & code_mask);
			datum >>= code_size;
			bits -= code_size;
			//TRACE("%d, %d\n", code, code_size);
			// Interpret the code
			if ((code > available) || (code == end_of_information)) {
				break;
			}
			if (code == clear) {
				// Reset decoder.
				code_size = data_size + 1;
				code_mask = (1 << code_size) - 1;
				available = clear + 2;
				old_code = nullCode;
				continue;
			}
			if (old_code == nullCode) {
				pixelStack[top++] = suffix[code];
				old_code = code;
				first = code;
				continue;
			}
			in_code = code;
			if (code == available) {
				pixelStack[top++] = first;
				code = old_code;
			}
			while (code > clear) {
				pixelStack[top++] = suffix[code];
				code = prefix[code];
			}
			first = (uint32_t)suffix[code];
			// Add a new string to the string table,
			pixelStack[top++] = first;
			if (available < MAX_STACK_SIZE) {
				prefix[available] = old_code;
				suffix[available] = first;
			}
			available++;
			if (((available & code_mask) == 0) && (available < MAX_STACK_SIZE)) {
				code_size++;
				code_mask |= available;
			}
			old_code = in_code;
		}
		// Pop a pixel off the pixel stack.
		top--;
		pixels[pi++] = pixelStack[top];
		i++;
	}
	for (i = pi; i < npix; i++) {
		pixels[i] = 0; // clear missing pixels
	}
	return true;
}

void GifDecoder::setPixels(uint32_t* act)
{
	int32_t pixelNum = width * height;
	uint32_t* dest = new uint32_t[pixelNum];
	// fill in starting image contents based on last image's dispose code
	if (lastDispose > 0) {
		if (lastDispose == 3) {
			// use image before last
			int32_t n = frameCount - 2;
			if (n > 0) {
				lastBitmap = getFrame(n - 1);
			} else {
				lastBitmap = NULL;
			}
		}
		if (lastBitmap != NULL) {
			memcpy(dest, lastBitmap, pixelNum * 4);
			// copy pixels
			if (lastDispose == 2) {
				// fill last image rect area with background color
				int32_t c = 0;
				if (!transparency) {
					c = lastBgColor;
				}
				for (int32_t i = 0; i < lrh; i++) {
					int32_t n1 = (lry + i) * width + lrx;
					int32_t n2 = n1 + lrw;
					for (int32_t k = n1; k < n2; k++) {
						dest[k] = c;
					}
				}
			}
		} else {
			memset(dest, 0, pixelNum * 4);
		}
	} else {
		memset(dest, 0, pixelNum * 4);
	}
	// copy each source line to the appropriate place in the destination
	int32_t pass = 1;
	int32_t inc = 8;
	int32_t iline = 0;
	for (int32_t i = 0; i < ih; i++) {
		int32_t line = i;
		if (interlace) {
			if (iline >= ih) {
				pass++;
				switch (pass) {
				case 2:
					iline = 4;
					break;
				case 3:
					iline = 2;
					inc = 4;
					break;
				case 4:
					iline = 1;
					inc = 2;
					break;
				default:
					break;
				}
			}
			line = iline;
			iline += inc;
		}
		line += iy;
		if (line < height) {
			int32_t k = line * width;
			int32_t dx = k + ix; // start of line in dest
			int32_t dlim = dx + iw; // end of dest line
			if ((k + width) < dlim) {
				dlim = k + width; // past dest edge
			}
			int32_t sx = i * iw; // start of line in source
			while (dx < dlim) {
				// map color and insert in destination
				int32_t index = ((int32_t) pixels[sx++]) & 0xff;
				int32_t c = act[index];
				if (c != 0) {
					dest[dx] = c;
				}
				dx++;
			}
		}
	}
	frames.push_back(GifFrame(dest, delay));
	image = dest;
}

uint32_t GifDecoder::getFrameCount()
{
	return frameCount;
}

const uint32_t* GifDecoder::getFrame(int32_t n)
{
	if (frameCount <= 0)
		return 0;
	n = n % frameCount;
	return frames[n].data;
}

uint32_t GifDecoder::getDelay(int32_t n)
{
	if (frameCount <= 0)
		return 0;
	n = n % frameCount;
	return frames[n].delayMs;
}

uint32_t GifDecoder::getWidth()
{
	return width;
}

uint32_t GifDecoder::getHeight()
{
	return height;
}
