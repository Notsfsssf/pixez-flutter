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
#include <string.h>
#include <vector>
#include <cmath>
#include "BaseGifEncoder.h"
#include "FastGifEncoder.h"
#include "BitWritingBlock.h"

using namespace std;

void worker_thread_process( WorkerThreadData* data )
{
	const int32_t ERROR_PROPAGATION_DIRECTION_NUM = 4;
	const int32_t ERROR_PROPAGATION_DIRECTION_X[] = {1, -1, 0, 1};
	const int32_t ERROR_PROPAGATION_DIRECTION_Y[] = {0, 1, 1, 1};
	const int32_t ERROR_PROPAGATION_DIRECTION_WEIGHT[] = {7, 3, 5, 1};

	uint32_t rowCount = (uint32_t) ((int) ceil( (double) data->height / data->threadCount ));
	uint32_t rowOffset = rowCount * data->threadNum;
	uint32_t ditherRowCount = rowCount;
	bool skipFirstRow = false;

	uint32_t pixelOffset = rowOffset * data->width;

	if (rowOffset > 0 && data->useDither)
	{
		pixelOffset = (rowOffset - 1) * data->width;
		++ditherRowCount;
		skipFirstRow = true;
	}

	volatile uint32_t* pixels = data->pixels + pixelOffset;
	volatile uint8_t* pixelOut = data->palettizedPixels + rowOffset * data->width;
	volatile uint32_t* colorReducedPixelOut = data->lastColorReducedPixels + rowOffset * data->width;

	for (uint32_t y = 0; y < ditherRowCount; ++y) {
		for (uint32_t x = 0; x < data->width; ++x) {
			if (y == 0 && skipFirstRow)
			{
				// For dithering, the first row is from the previous chunk and we use it to calculate dithering for the first actual row
				if ( 0 != (*pixels >> 24))
				{
					volatile Cube *cube = data->cubes;
					uint32_t r = (*pixels) & 0xFF;
					uint32_t g = ((*pixels) >> 8) & 0xFF;
					uint32_t b = ((*pixels) >> 16) & 0xFF;

					volatile Cube *closestColorCube = cube;
					int32_t diffR = cube->color[RED] - r;
					int32_t diffG = cube->color[GREEN] - g;
					int32_t diffB = cube->color[BLUE] - b;
					uint32_t closestDifference = diffR * diffR + diffG * diffG + diffB * diffB;
					volatile Cube *lastCube = cube + data->cubeNum;

					for (volatile Cube *testCube = cube; testCube != lastCube; ++testCube)
					{
						diffR = testCube->color[RED] - r;
						diffG = testCube->color[GREEN] - g;
						diffB = testCube->color[BLUE] - b;
						uint32_t difference = diffR * diffR + diffG * diffG + diffB * diffB;

						if (0 == difference)
						{
							closestColorCube = testCube;
							break;
						}
						else if (difference < closestDifference)
						{
							closestDifference = difference;
							closestColorCube = testCube;
						}
					}

					uint32_t closestColor = closestColorCube - cube;
					cube = &(data->cubes[closestColor]);

					diffR = r - (uint32_t)cube->color[RED];
					diffG = g - (uint32_t)cube->color[GREEN];
					diffB = b - (uint32_t)cube->color[BLUE];
					for (int directionId = 0; directionId < ERROR_PROPAGATION_DIRECTION_NUM; ++directionId)
					{
						volatile uint32_t* pixel = pixels + ERROR_PROPAGATION_DIRECTION_X[directionId] + ERROR_PROPAGATION_DIRECTION_Y[directionId] * data->width;
						if (x + ERROR_PROPAGATION_DIRECTION_X[directionId] >= data->width || y + ERROR_PROPAGATION_DIRECTION_Y[directionId] >= ditherRowCount || 0 == (*pixels >> 24)) {
							continue;
						}
						int32_t weight = ERROR_PROPAGATION_DIRECTION_WEIGHT[directionId];
						int32_t dstR = ((int32_t)((*pixel) & 0xFF) + (diffR * weight + 8) / 16);
						int32_t dstG = (((int32_t)((*pixel) >> 8) & 0xFF) + (diffG * weight + 8) / 16);
						int32_t dstB = (((int32_t)((*pixel) >> 16) & 0xFF) + (diffB * weight + 8) / 16);
						int32_t dstA = (int32_t)(*pixel >> 24);
						int32_t newR = MIN(255, MAX(0, dstR));
						int32_t newG = MIN(255, MAX(0, dstG));
						int32_t newB = MIN(255, MAX(0, dstB));
						*pixel = (dstA << 24) | (newB << 16) | (newG << 8) | newR;
					}
				}
				++pixels;
			}
			else
			{
				if (0 == (*pixels >> 24))
				{
					*pixelOut = 255; //l transparent color
					*colorReducedPixelOut = 0;
				}
				else
				{
					volatile Cube *cube = data->cubes;
					uint32_t r = (*pixels) & 0xFF;
					uint32_t g = ((*pixels) >> 8) & 0xFF;
					uint32_t b = ((*pixels) >> 16) & 0xFF;

					volatile Cube *closestColorCube = cube;
					int32_t diffR = cube->color[RED] - r;
					int32_t diffG = cube->color[GREEN] - g;
					int32_t diffB = cube->color[BLUE] - b;
					uint32_t closestDifference = diffR * diffR + diffG * diffG + diffB * diffB;
					volatile Cube *lastCube = cube + data->cubeNum;

					for (volatile Cube *testCube = cube; testCube != lastCube; ++testCube)
					{
						diffR = testCube->color[RED] - r;
						diffG = testCube->color[GREEN] - g;
						diffB = testCube->color[BLUE] - b;
						uint32_t difference = diffR * diffR + diffG * diffG + diffB * diffB;

						if (0 == difference)
						{
							closestColorCube = testCube;
							break;
						}
						else if (difference < closestDifference)
						{
							closestDifference = difference;
							closestColorCube = testCube;
						}
					}

					uint32_t closestColor = closestColorCube - cube;
					cube = &(data->cubes[closestColor]);
					*pixelOut = closestColor;
					*colorReducedPixelOut = (0xFF000000 | (cube->color[BLUE] << 16) | (cube->color[GREEN] << 8) | cube->color[RED]);
					if (data->useDither)
					{
						diffR = r - (uint32_t)cube->color[RED];
						diffG = g - (uint32_t)cube->color[GREEN];
						diffB = b - (uint32_t)cube->color[BLUE];
						for (int directionId = 0; directionId < ERROR_PROPAGATION_DIRECTION_NUM; ++directionId)
						{
							volatile uint32_t* pixel = pixels + ERROR_PROPAGATION_DIRECTION_X[directionId] + ERROR_PROPAGATION_DIRECTION_Y[directionId] * data->width;
							if (x + ERROR_PROPAGATION_DIRECTION_X[directionId] >= data->width || y + ERROR_PROPAGATION_DIRECTION_Y[directionId] >= ditherRowCount || 0 == (*pixels >> 24)) {
								continue;
							}
							int32_t weight = ERROR_PROPAGATION_DIRECTION_WEIGHT[directionId];
							int32_t dstR = ((int32_t)((*pixel) & 0xFF) + (diffR * weight + 8) / 16);
							int32_t dstG = (((int32_t)((*pixel) >> 8) & 0xFF) + (diffG * weight + 8) / 16);
							int32_t dstB = (((int32_t)((*pixel) >> 16) & 0xFF) + (diffB * weight + 8) / 16);
							int32_t dstA = (int32_t)(*pixel >> 24);
							int32_t newR = MIN(255, MAX(0, dstR));
							int32_t newG = MIN(255, MAX(0, dstG));
							int32_t newB = MIN(255, MAX(0, dstB));
							*pixel = (dstA << 24) | (newB << 16) | (newG << 8) | newR;
						}
					}
				}
				++pixels;
				++pixelOut;
				++colorReducedPixelOut;
			}
		}
	}
}

void* worker_thread(void* threadData)
{
	WorkerThreadData* data = (WorkerThreadData*) threadData;
	bool localShutdown = false;
	bool localRequestProcess = false;

	while ( true )
	{
		pthread_mutex_lock(&(data->threadLock));

		if ( !data->shutdown && !data->requestProcess )
		{
			pthread_cond_wait(&(data->threadCondition), &(data->threadLock));
		}

		localShutdown = data->shutdown;
		localRequestProcess = data->requestProcess;

		if ( localRequestProcess )
		{
			data->isProcessing = true;
		}

		data->shutdown = false;
		data->requestProcess = false;

		pthread_mutex_unlock(&(data->threadLock));

		if ( localShutdown )
		{
			break;
		}

		if ( localRequestProcess )
		{
			worker_thread_process( data );

			pthread_mutex_lock(&(data->threadLock));
			data->isProcessing = false;
			pthread_mutex_unlock(&(data->threadLock));

			pthread_mutex_lock(data->encoderLock);
			pthread_cond_signal(data->encoderCondition);
			pthread_mutex_unlock(data->encoderLock);
		}
	}

	pthread_mutex_lock(&(data->threadLock));
	data->isProcessing = false;
	pthread_mutex_unlock(&(data->threadLock));

	pthread_mutex_lock(data->encoderLock);
	pthread_cond_signal(data->encoderCondition);
	pthread_mutex_unlock(data->encoderLock);

	return NULL;
}

FastGifEncoder::FastGifEncoder() {
	// init width, height to 1, to prevent divide by zero.
	width = 1;
	height = 1;

	threadCount = 1;
	nextThreadCount = 1;

	useDither = true;
	frameNum = 0;
	lastPixels = NULL;
	lastColorReducedPixels = NULL;
	fp = NULL;
	globalCubes = NULL;
	palettizedPixels = NULL;
	workerThreadData = NULL;
	lastRootColor = GREEN;

	primaryThreadData.threadNum = 0;

	pthread_mutex_init(&threadLock, NULL);
	pthread_cond_init(&threadCondition, NULL);
}

FastGifEncoder::~FastGifEncoder() {
	release();

	pthread_cond_destroy(&threadCondition);
	pthread_mutex_destroy(&threadLock);
}

bool FastGifEncoder::init(uint16_t width, uint16_t height, const char* fileName) {
	this->width = width;
	this->height = height;

	fp = fopen(fileName, "wb");
	if (NULL == fp) {
		return false;
	}
	if (NULL != lastPixels) {
		delete[] lastPixels;
	}
	lastPixels = new uint32_t[width * height];
	if (NULL != lastColorReducedPixels) {
		delete[] lastColorReducedPixels;
	}
	lastColorReducedPixels = new uint32_t[width * height];

	if (NULL != globalCubes)
	{
		delete[] globalCubes;
	}
	globalCubes = new Cube[256];
	memset(globalCubes, 0, 256 * sizeof(Cube));

	if (NULL != palettizedPixels)
	{
		delete[] palettizedPixels;
	}
	palettizedPixels = new uint8_t[width * height];
	memset(palettizedPixels, 0, width * height * sizeof(uint8_t));

	if ( NULL != workerThreadData )
	{
		for ( int i = 0; i < threadCount - 1; ++i )
		{
			if ( NULL != workerThreadData[i].workerThread )
			{
				pthread_mutex_lock(&(workerThreadData[i].threadLock));
				workerThreadData[i].shutdown = true;
				pthread_cond_signal(&(workerThreadData[i].threadCondition));
				pthread_mutex_unlock(&(workerThreadData[i].threadLock));
				pthread_join( *(workerThreadData[i].workerThread), NULL );
				delete workerThreadData[i].workerThread;
			}
			pthread_cond_destroy(&(workerThreadData[i].threadCondition));
			pthread_mutex_destroy(&(workerThreadData[i].threadLock));
		}
		delete[] workerThreadData;
	}

	threadCount = nextThreadCount;

	primaryThreadData.threadCount = threadCount;
	workerThreadData = new WorkerThreadData[threadCount - 1];
	for ( int i = 0; i < threadCount - 1; i++ )
	{
		workerThreadData[i].workerThread = new pthread_t();
		workerThreadData[i].threadNum = i + 1;
		workerThreadData[i].threadCount = threadCount;
		workerThreadData[i].shutdown = false;
		workerThreadData[i].requestProcess = false;
		workerThreadData[i].isProcessing = false;
		pthread_mutex_init(&(workerThreadData[i].threadLock), NULL);
		pthread_cond_init(&(workerThreadData[i].threadCondition), NULL);

		workerThreadData[i].encoderLock = &threadLock;
		workerThreadData[i].encoderCondition = &threadCondition;

		pthread_create(workerThreadData[i].workerThread, NULL, worker_thread, &(workerThreadData[i]));
	}

	writeHeader();
	return true;
}

void FastGifEncoder::release() {
	if ( NULL != workerThreadData )
	{
		for ( int i = 0; i < threadCount - 1; ++i )
		{
			if ( NULL != workerThreadData[i].workerThread )
			{
				pthread_mutex_lock(&(workerThreadData[i].threadLock));
				workerThreadData[i].shutdown = true;
				pthread_cond_signal(&(workerThreadData[i].threadCondition));
				pthread_mutex_unlock(&(workerThreadData[i].threadLock));
				pthread_join( *(workerThreadData[i].workerThread), NULL );
				delete workerThreadData[i].workerThread;
			}
			pthread_cond_destroy(&(workerThreadData[i].threadCondition));
			pthread_mutex_destroy(&(workerThreadData[i].threadLock));
		}
		delete[] workerThreadData;
		workerThreadData = NULL;
	}

	if (NULL != lastPixels) {
		delete[] lastPixels;
		lastPixels = NULL;
	}

	if (NULL != lastColorReducedPixels) {
		delete[] lastColorReducedPixels;
		lastColorReducedPixels = NULL;
	}

	if (NULL != fp) {
		uint8_t gifFileTerminator = 0x3B;
		fwrite(&gifFileTerminator, 1, 1, fp);
		fclose(fp);
		fp = NULL;
	}

	if (NULL != globalCubes)
	{
		delete[] globalCubes;
		globalCubes = NULL;
	}

	if (NULL != palettizedPixels)
	{
		delete[] palettizedPixels;
		palettizedPixels = NULL;
	}
}

void FastGifEncoder::setDither(bool useDither) {
		this->useDither = useDither;
}

uint16_t FastGifEncoder::getWidth() {
		return width;
}

uint16_t FastGifEncoder::getHeight() {
	return height;
}

void FastGifEncoder::setThreadCount(int32_t threadCount)
{
	nextThreadCount = threadCount;

	if ( nextThreadCount < 1 )
	{
		nextThreadCount = 1;
	}
	else if ( nextThreadCount > MAX_THREADS )
	{
		nextThreadCount = MAX_THREADS;
	}
}

void FastGifEncoder::removeSamePixels(uint8_t* src1, uint8_t* src2, EncodeRect* rect)
{
	int32_t bytesPerLine = width * 4;
	int32_t beginY = 0;
	for (; beginY < height - 1; ++beginY) {
		if (0 != memcmp(src1 + bytesPerLine * beginY, src2 + bytesPerLine * beginY, bytesPerLine)) {
			break;
		}
	}
	int32_t endY = height - 1;
	for (; beginY + 1 <= endY; --endY) {
		if (0 != memcmp(src1 + bytesPerLine * endY, src2 + bytesPerLine * endY, bytesPerLine)) {
			break;
		}
	}
	++endY;

	int32_t lastY = width * height;
	bool isSame = true;
	int32_t beginX = 0;
	for (; beginX < width - 1 && isSame; ++beginX) {
		isSame = true;
		for (int32_t y = 0; y < lastY; y += width) {
			if (((uint32_t*)src1)[y + beginX] != ((uint32_t*)src2)[y + beginX]) {
				isSame = false;
				break;
			}
		}
	}
	--beginX;
	isSame = true;
	int32_t endX = width - 1;
	for (; beginX + 1 <= endX && isSame; --endX) {
		isSame = true;
		for (int32_t y = 0; y < lastY; y += width) {
			if (((uint32_t*)src1)[y + endX] != ((uint32_t*)src2)[y + endX]) {
				isSame = false;
				break;
			}
		}
	}
	++endX;

	rect->x = beginX;
	rect->y = beginY;
	rect->width = endX - beginX + 1;
	rect->height = endY - beginY;
}

void FastGifEncoder::writeHeader()
{
	fwrite("GIF89a", 6, 1, fp);
	writeLSD();
}

bool FastGifEncoder::writeLSD()
{
	// logical screen size
	fwrite(&width, 2, 1, fp);
	fwrite(&height, 2, 1, fp);

	// packed fields
	uint8_t gctFlag = 0; // 1 : global color table flag
	uint8_t colorResolution = 8; // only 8 bit
	uint8_t oderedFlag = 0;
	uint8_t gctSize = 0;
	uint8_t packed = (gctFlag << 7) | ((colorResolution - 1) << 4) | (oderedFlag << 3) | gctSize;
	fwrite(&packed, 1, 1, fp);

	uint8_t backgroundColorIndex = 0xFF;
	fwrite(&backgroundColorIndex, 1, 1, fp);

	uint8_t aspectRatio = 0;
	fwrite(&aspectRatio, 1, 1, fp);

	return true;
}

bool FastGifEncoder::writeContents(Cube* cubes, uint8_t* pixels, uint16_t delay, const EncodeRect& encodingRect)
{
	writeNetscapeExt();

	writeGraphicControlExt(delay);
	writeFrame(cubes, pixels, encodingRect);

	return true;
}

bool FastGifEncoder::writeNetscapeExt()
{
	//                                   code extCode,                                                            size,       loop count, end
	const uint8_t netscapeExt[] = {0x21, 0xFF, 0x0B, 'N', 'E', 'T', 'S', 'C', 'A', 'P', 'E', '2', '.', '0', 0x03, 0x01, 0x00, 0x00, 0x00};
	fwrite(netscapeExt, sizeof(netscapeExt), 1, fp);
	return true;
}

bool FastGifEncoder::writeGraphicControlExt(uint16_t delay)
{
	uint8_t disposalMethod = 2; // dispose
	uint8_t userInputFlag = 0; // User input is not expected.
	uint8_t transparencyFlag = 1; // Transparent Index is given.

	uint8_t packed = (disposalMethod << 2) | (userInputFlag << 1) | transparencyFlag;
	//                                                     size, packed, delay(2), transIndex, terminator
	const uint8_t graphicControlExt[] = {0x21, 0xF9, 0x04, packed, (uint8_t)(delay & 0xFF), (uint8_t)(delay >> 8), 0xFF, 0x00};
	fwrite(graphicControlExt, sizeof(graphicControlExt), 1, fp);
	return true;
}

bool FastGifEncoder::writeFrame(Cube* cubes, uint8_t* pixels, const EncodeRect& encodingRect)
{
	uint8_t code = 0x2C;
	fwrite(&code, 1, 1, fp);
	uint16_t ix = encodingRect.x;
	uint16_t iy = encodingRect.y;
	uint16_t iw = encodingRect.width;
	uint16_t ih = encodingRect.height;
	uint8_t localColorTableFlag = 1;
	uint8_t interlaceFlag = 0;
	uint8_t sortFlag = 0;
	uint8_t sizeOfLocalColorTable = 7;
	uint8_t packed = (localColorTableFlag << 7) | (interlaceFlag << 6) | (sortFlag << 5) | sizeOfLocalColorTable;
	fwrite(&ix, 2, 1, fp);
	fwrite(&iy, 2, 1, fp);
	fwrite(&iw, 2, 1, fp);
	fwrite(&ih, 2, 1, fp);
	fwrite(&packed, 1, 1, fp);

	writeLCT(2 << sizeOfLocalColorTable, cubes);
	writeBitmapData(pixels, encodingRect);
	return true;
}

bool FastGifEncoder::writeLCT(int32_t colorNum, Cube* cubes)
{
	uint32_t color;
	Cube* cube;
	for (int32_t i = 0; i < colorNum; ++i) {
		cube = cubes + i;
		color = cube->color[RED] | (cube->color[GREEN] << 8) | (cube->color[BLUE] << 16);
		fwrite(&color, 3, 1, fp);
	}
	return true;
}

bool FastGifEncoder::writeBitmapData(uint8_t* pixels, const EncodeRect& encodingRect)
{
	uint8_t* endPixels = pixels + (encodingRect.y + encodingRect.height - 1) * width + encodingRect.x + encodingRect.width;
	uint8_t dataSize = 8;
	uint32_t codeSize = dataSize + 1;
	uint32_t codeMask = (1 << codeSize) - 1;
	BitWritingBlock writingBlock;
	fwrite(&dataSize, 1, 1, fp);

	vector<uint16_t> lzwInfoHolder;
	lzwInfoHolder.resize(MAX_STACK_SIZE * BYTE_NUM);
	uint16_t* lzwInfos = &lzwInfoHolder[0];

	pixels = pixels + width * encodingRect.y + encodingRect.x;
	uint8_t* rowStart = pixels;
	uint32_t clearCode = 1 << dataSize;
	writingBlock.writeBits(clearCode, codeSize);
	uint32_t infoNum = clearCode + 2;
	uint16_t current = *pixels;
	uint8_t endOfImageData = 0;

	++pixels;
	if (encodingRect.width <= pixels - rowStart) {
		rowStart = rowStart + width;
		pixels = rowStart;
	}

	uint16_t* next;
	while (endPixels > pixels) {
		next = &lzwInfos[current * BYTE_NUM + *pixels];
		if (0 == *next || *next >= MAX_STACK_SIZE) {
			writingBlock.writeBits(current, codeSize);

			*next = infoNum;
			if (infoNum < MAX_STACK_SIZE) {
				++infoNum;
			} else {
				writingBlock.writeBits(clearCode, codeSize);
				infoNum = clearCode + 2;
				codeSize = dataSize + 1;
				codeMask = (1 << codeSize) - 1;
				memset(lzwInfos, 0, MAX_STACK_SIZE * BYTE_NUM * sizeof(uint16_t));
			}
			if (codeMask < infoNum - 1 && infoNum < MAX_STACK_SIZE) {
				++codeSize;
				codeMask = (1 << codeSize) - 1;
			}
			if (endPixels <= pixels) {
				break;
			}
			current = *pixels;
		} else {
			current = *next;
		}
		++pixels;
		if (encodingRect.width <= pixels - rowStart) {
			rowStart = rowStart + width;
			pixels = rowStart;
		}
	}
	writingBlock.writeBits(current, codeSize);
	writingBlock.toFile(fp);
	fwrite(&endOfImageData, 1, 1, fp);

	return true;
}

void FastGifEncoder::fastReduceColor(Cube* cubes, uint32_t cubeNum, uint32_t* pixels)
{
	// Wait until threads are free
	while ( true )
	{
		bool threadsFree = true;

		pthread_mutex_lock(&threadLock);

		for ( int i = 0; i < threadCount - 1; ++i )
		{
			pthread_mutex_lock(&(workerThreadData[i].threadLock));
			if (workerThreadData[i].requestProcess || workerThreadData[i].isProcessing)
			{
				threadsFree = false;
			}
			pthread_mutex_unlock(&(workerThreadData[i].threadLock));

			if ( !threadsFree )
			{
				break;
			}
		}

		if ( !threadsFree )
		{
			pthread_cond_wait(&threadCondition, &threadLock);

			for ( int i = 0; i < threadCount - 1; ++i )
			{
				pthread_mutex_lock(&(workerThreadData[i].threadLock));
				if ( workerThreadData[i].requestProcess || workerThreadData[i].isProcessing )
				{
					threadsFree = false;
				}
				pthread_mutex_unlock(&(workerThreadData[i].threadLock));

				if ( !threadsFree )
				{
					break;
				}
			}
		}

		pthread_mutex_unlock(&threadLock);

		if ( threadsFree )
		{
			break;
		}
	}

	// Set up the worker threads
	for ( int i = 0; i < threadCount - 1; ++i )
	{
		pthread_mutex_lock(&(workerThreadData[i].threadLock));

		workerThreadData[i].useDither = useDither;
		workerThreadData[i].width = width;
		workerThreadData[i].height = height;
		workerThreadData[i].cubes = cubes;
		workerThreadData[i].cubeNum = cubeNum;
		workerThreadData[i].pixels = pixels;
		workerThreadData[i].lastColorReducedPixels = lastColorReducedPixels;
		workerThreadData[i].palettizedPixels = palettizedPixels;
		workerThreadData[i].requestProcess = true;

		pthread_cond_signal(&(workerThreadData[i].threadCondition));

		pthread_mutex_unlock(&(workerThreadData[i].threadLock));
	}

	// Run the main thread
	primaryThreadData.useDither = useDither;
	primaryThreadData.width = width;
	primaryThreadData.height = height;
	primaryThreadData.cubes = cubes;
	primaryThreadData.cubeNum = cubeNum;
	primaryThreadData.pixels = pixels;
	primaryThreadData.lastColorReducedPixels = lastColorReducedPixels;
	primaryThreadData.palettizedPixels = palettizedPixels;

	worker_thread_process( &primaryThreadData );

	// Wait until threads finish
	while ( true )
	{
		bool threadsFree = true;

		pthread_mutex_lock(&threadLock);

		for ( int i = 0; i < threadCount - 1; ++i )
		{
			pthread_mutex_lock(&(workerThreadData[i].threadLock));
			if (workerThreadData[i].requestProcess || workerThreadData[i].isProcessing)
			{
				threadsFree = false;
			}
			pthread_mutex_unlock(&(workerThreadData[i].threadLock));

			if ( !threadsFree )
			{
				break;
			}
		}

		if ( !threadsFree )
		{
			pthread_cond_wait(&threadCondition, &threadLock);

			for ( int i = 0; i < threadCount - 1; ++i )
			{
				pthread_mutex_lock(&(workerThreadData[i].threadLock));
				if (workerThreadData[i].requestProcess || workerThreadData[i].isProcessing)
				{
					threadsFree = false;
				}
				pthread_mutex_unlock(&(workerThreadData[i].threadLock));

				if ( !threadsFree )
				{
					break;
				}
			}
		}

		pthread_mutex_unlock(&threadLock);

		if ( threadsFree )
		{
			break;
		}
	}

	// Dither the row boundaries again
	if (useDither && threadCount > 1)
	{
		const int32_t ERROR_PROPAGATION_DIRECTION_NUM = 3;
		const int32_t ERROR_PROPAGATION_DIRECTION_X[] = {-1, 0, 1};
		const int32_t ERROR_PROPAGATION_DIRECTION_Y[] = {1, 1, 1};
		const int32_t ERROR_PROPAGATION_DIRECTION_WEIGHT[] = {3, 5, 1};

		uint32_t rowCount = threadCount - 1;
		uint32_t rowSeparation = (uint32_t) ((int) ceil( (double) height / threadCount ));

		uint32_t* ditherPixels = pixels + ( rowSeparation - 1 ) * width;
		uint8_t* ditherPixelOut = palettizedPixels + ( rowSeparation - 1 ) * width;

		for (uint32_t y = 0; y < rowCount; ++y) {
			for (uint32_t x = 0; x < width; ++x) {
				if (0 != (*ditherPixels >> 24))
				{
					Cube *cube = &(cubes[*ditherPixelOut]);
					uint32_t r = (*ditherPixels) & 0xFF;
					uint32_t g = ((*ditherPixels) >> 8) & 0xFF;
					uint32_t b = ((*ditherPixels) >> 16) & 0xFF;

					int32_t diffR = r - (uint32_t)cube->color[RED];
					int32_t diffG = g - (uint32_t)cube->color[GREEN];
					int32_t diffB = b - (uint32_t)cube->color[BLUE];
					for (int directionId = 0; directionId < ERROR_PROPAGATION_DIRECTION_NUM; ++directionId)
					{
						uint32_t* pixel = ditherPixels + ERROR_PROPAGATION_DIRECTION_X[directionId] + ERROR_PROPAGATION_DIRECTION_Y[directionId] * width;
						if (x + ERROR_PROPAGATION_DIRECTION_X[directionId] >= width || y + ERROR_PROPAGATION_DIRECTION_Y[directionId] >= height) {
							continue;
						}
						int32_t weight = ERROR_PROPAGATION_DIRECTION_WEIGHT[directionId];
						int32_t dstR = ((int32_t)((*pixel) & 0xFF) + (diffR * weight + 8) / 16);
						int32_t dstG = (((int32_t)((*pixel) >> 8) & 0xFF) + (diffG * weight + 8) / 16);
						int32_t dstB = (((int32_t)((*pixel) >> 16) & 0xFF) + (diffB * weight + 8) / 16);
						int32_t dstA = (int32_t)(*pixel >> 24);
						int32_t newR = MIN(255, MAX(0, dstR));
						int32_t newG = MIN(255, MAX(0, dstG));
						int32_t newB = MIN(255, MAX(0, dstB));
						*pixel = (dstA << 24) | (newB << 16) | (newG << 8) | newR;

						// After dithering, re-palettize
						uint8_t* pixelOut = ditherPixelOut + ERROR_PROPAGATION_DIRECTION_X[directionId] + ERROR_PROPAGATION_DIRECTION_Y[directionId] * width;

						Cube* cube2 = cubes;
						uint32_t r2 = (*pixel) & 0xFF;
						uint32_t g2 = ((*pixel) >> 8) & 0xFF;
						uint32_t b2 = ((*pixel) >> 16) & 0xFF;

						Cube *closestColorCube = cube2;
						int32_t diffR2 = cube2->color[RED] - r2;
						int32_t diffG2 = cube2->color[GREEN] - g2;
						int32_t diffB2 = cube2->color[BLUE] - b2;
						uint32_t closestDifference = diffR2 * diffR2 + diffG2 * diffG2 + diffB2 * diffB2;
						Cube *lastCube = cube2 + cubeNum;

						for (Cube *testCube = cube2; testCube != lastCube; ++testCube)
						{
							diffR2 = testCube->color[RED] - r2;
							diffG2 = testCube->color[GREEN] - g2;
							diffB2 = testCube->color[BLUE] - b2;
							uint32_t difference = diffR2 * diffR2 + diffG2 * diffG2 + diffB2 * diffB2;

							if (0 == difference)
							{
								closestColorCube = testCube;
								break;
							}
							else if (difference < closestDifference)
							{
								closestDifference = difference;
								closestColorCube = testCube;
							}
						}

						uint32_t closestColor = closestColorCube - cube2;
						*pixelOut = closestColor;
					}
				}
				++ditherPixels;
				++ditherPixelOut;
			}
			ditherPixels += rowSeparation * width;
			ditherPixelOut += rowSeparation * width;
		}
	}
}

void FastGifEncoder::encodeFrame(uint32_t* pixels, int32_t delayMs) {
	uint32_t pixelNum = width * height;
	EncodeRect imageRect;
	imageRect.x = 0;
	imageRect.y = 0;
	imageRect.width = width;
	imageRect.height = height;

	memcpy(lastPixels, pixels, pixelNum * sizeof(uint32_t));

	if (0 == frameNum % 5)
	{
		memset(globalCubes, 0, 256 * sizeof(Cube));
		computeColorTable(pixels, globalCubes, width * height);
	}

	fastReduceColor(globalCubes, 255, pixels);
	writeContents(globalCubes, palettizedPixels, delayMs / 10, imageRect);

	++frameNum;
}
