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
#include "BaseGifEncoder.h"

using namespace std;

BaseGifEncoder::BaseGifEncoder() {
	width = 1;
	height = 1;
	frameNum = 0;
	lastColorReducedPixels = NULL;
	lastRootColor = 0;
	useDither = true;
}

void BaseGifEncoder::qsortColorHistogram(uint32_t* imageColorHistogram, int32_t maxColor, uint32_t from, uint32_t to)
{
	if (to == from) {
		return ;
	}
	uint32_t middle = from + ((to - from) >> 1);
	uint32_t shift = maxColor << 3;
	uint32_t pivot = ((imageColorHistogram[middle]) >> shift) & 0xFF;
	uint32_t i = from;
	uint32_t k = to;
	while (i <= k) {
		while (((imageColorHistogram[i] >> shift) & 0xFF) < pivot && i <= k) {
			++i;
		}
		while (((imageColorHistogram[k] >> shift) & 0xFF) > pivot && i <= k && 1 < k) {
			--k;
		}
		if (i <= k) {
			uint32_t temp = imageColorHistogram[k];
			imageColorHistogram[k] = imageColorHistogram[i];
			imageColorHistogram[i] = temp;
			++i;
			--k;
		}
	}
	if (from < k && -1 != k) {
		qsortColorHistogram(imageColorHistogram, maxColor, from, k);
	}
	if (i < to) {
		qsortColorHistogram(imageColorHistogram, maxColor, i, to);
	}
}

void BaseGifEncoder::updateColorHistogram(Cube* nextCube, Cube* maxCube, int32_t maxColor, uint32_t* imageColorHistogram)
{
	qsortColorHistogram(imageColorHistogram, maxColor, maxCube->colorHistogramFromIndex, maxCube->colorHistogramToIndex);
	uint32_t median = maxCube->colorHistogramFromIndex + ((maxCube->colorHistogramToIndex - maxCube->colorHistogramFromIndex) >> 1);
	nextCube->colorHistogramFromIndex = maxCube->colorHistogramFromIndex;
	nextCube->colorHistogramToIndex = median;

	if (GET_COLOR(imageColorHistogram[nextCube->colorHistogramFromIndex], maxColor) !=
		GET_COLOR(imageColorHistogram[maxCube->colorHistogramToIndex], maxColor)) {
			if (GET_COLOR(imageColorHistogram[nextCube->colorHistogramFromIndex], maxColor) != GET_COLOR(imageColorHistogram[nextCube->colorHistogramToIndex], maxColor)) {
				if (GET_COLOR(imageColorHistogram[median], maxColor) == GET_COLOR(imageColorHistogram[median + 1], maxColor)) {
					while (GET_COLOR(imageColorHistogram[nextCube->colorHistogramToIndex], maxColor) == GET_COLOR(imageColorHistogram[median], maxColor)) {
						--median;
					}
					nextCube->colorHistogramToIndex = median;
				}
			} else {
				while (GET_COLOR(imageColorHistogram[nextCube->colorHistogramToIndex], maxColor) == GET_COLOR(imageColorHistogram[median], maxColor)) {
					++median;
				}
				nextCube->colorHistogramToIndex = median;
			}
	}
	maxCube->colorHistogramFromIndex = maxCube->colorHistogramToIndex > median + 1 ? median + 1 : maxCube->colorHistogramToIndex;
	nextCube->cMin[maxColor] = GET_COLOR(imageColorHistogram[nextCube->colorHistogramFromIndex], maxColor);
	nextCube->cMax[maxColor] = GET_COLOR(imageColorHistogram[nextCube->colorHistogramToIndex], maxColor);
	maxCube->cMin[maxColor] = GET_COLOR(imageColorHistogram[maxCube->colorHistogramFromIndex], maxColor);
	maxCube->cMax[maxColor] = GET_COLOR(imageColorHistogram[maxCube->colorHistogramToIndex], maxColor);
}

void BaseGifEncoder::computeColorTable(uint32_t* pixels, Cube* cubes, uint32_t pixelNum)
{
	uint32_t colors[COLOR_MAX][Cube::COLOR_RANGE] = {0, };
	uint32_t* pixelBegin = pixels;

	vector<uint32_t> colorHistogramMemory;
	if (0 != frameNum && NULL != lastColorReducedPixels) {
		colorHistogramMemory.resize(pixelNum * 2 * sizeof(uint32_t));
		memcpy(&colorHistogramMemory[0], pixels, pixelNum * sizeof(uint32_t));
		memcpy(&colorHistogramMemory[pixelNum], lastColorReducedPixels, pixelNum * sizeof(uint32_t));
		pixelNum *= 2;
	} else {
		colorHistogramMemory.resize(pixelNum * sizeof(uint32_t));
		memcpy(&colorHistogramMemory[0], pixels, pixelNum * sizeof(uint32_t));
	}
	uint32_t *colorHistogram = &colorHistogramMemory[0];
	pixels = colorHistogram;
	uint32_t* last = colorHistogram + pixelNum;

	while (last != pixels) {
		uint8_t r = (*pixels) & 0xFF;
		uint8_t g = ((*pixels) >> 8) & 0xFF;
		uint8_t b = ((*pixels) >> 16) & 0xFF;
		++colors[RED][r];
		++colors[GREEN][g];
		++colors[BLUE][b];
		++pixels;
	}

	uint32_t cubeIndex = 0;
	Cube* cube = &cubes[cubeIndex];
	for (uint32_t i = 0; i < COLOR_MAX; ++i) {
		cube->cMin[i] = 255;
		cube->cMax[i] = 0;
	}
	for (uint32_t i = 0; i < 256; ++i) {
		for (uint32_t color = 0; color < COLOR_MAX; ++color) {
			if (0 != colors[color][i]) {
				cube->cMax[color] = cube->cMax[color] < i ? i : cube->cMax[color];
				cube->cMin[color] = cube->cMin[color] > i ? i : cube->cMin[color];
			}
		}
	}
	cube->colorHistogramFromIndex = 0;
	cube->colorHistogramToIndex = pixelNum - 1;
	uint32_t comparingColorList[COLOR_MAX] = {GREEN, RED, BLUE};
	for (cubeIndex = 1; cubeIndex < 255; ++cubeIndex) {
		uint32_t maxDiff = 0;
		uint32_t maxColor = GREEN;
		Cube* maxCube = cubes;
		for (uint32_t i = 0; i < cubeIndex; ++i) {
			Cube* cube = &cubes[i];
			for (uint32_t colorIdx = 0; colorIdx < COLOR_MAX; ++colorIdx) {
				uint32_t comparingColor = comparingColorList[colorIdx];
				uint32_t comparingDiff = cube->cMax[comparingColor] - cube->cMin[comparingColor];
				if (comparingColor == lastRootColor) {
					comparingDiff = comparingDiff * 11 / 10; // multiply 110% to reduce color blinking from difference of root color.
				}

				if (comparingDiff > maxDiff) {
					maxDiff = comparingDiff;
					maxColor = comparingColor;
					maxCube = cube;
				}
			}
		}
		if (1 == cubeIndex) {
			lastRootColor = maxColor;
		}
		if (1 >= maxDiff) {
			break;
		}
		Cube* nextCube = &cubes[cubeIndex];
		for (int32_t color = 0; color < COLOR_MAX; ++color) {
			if (color == maxColor) {
				updateColorHistogram(nextCube, maxCube, maxColor, colorHistogram);
			} else {
				nextCube->cMax[color] = maxCube->cMax[color];
				nextCube->cMin[color] = maxCube->cMin[color];
			}
		}
	}
	for (uint32_t i = 0; i < 255; ++i) {
		Cube* cube = &cubes[i];
		for (int32_t color = 0; color < COLOR_MAX; ++color) {
			qsortColorHistogram(colorHistogram, color, cube->colorHistogramFromIndex, cube->colorHistogramToIndex);
			uint32_t median = cube->colorHistogramFromIndex + ((cube->colorHistogramToIndex - cube->colorHistogramFromIndex) >> 1);
			if (median < pixelNum) {
				cube->color[color] = GET_COLOR(colorHistogram[median], color);
			}
		}
	}
}

void BaseGifEncoder::reduceColor(Cube* cubes, uint32_t cubeNum, uint32_t* pixels)
{
	const int32_t ERROR_PROPAGATION_DIRECTION_NUM = 4;
	const int32_t ERROR_PROPAGATION_DIRECTION_X[] = {1, -1, 0, 1};
	const int32_t ERROR_PROPAGATION_DIRECTION_Y[] = {0, 1, 1, 1};
	const int32_t ERROR_PROPAGATION_DIRECTION_WEIGHT[] = {7, 3, 5, 1};

	uint32_t pixelNum = width * height;
	uint32_t* last = pixels + pixelNum;
	uint8_t* pixelOut = (uint8_t*)pixels;
	uint32_t* colorReducedPixelOut = lastColorReducedPixels;
	for (uint32_t y = 0; y < height; ++y) {
		for (uint32_t x = 0; x < width; ++x) {
			if (0 == (*pixels >> 24)) {
				*pixelOut = 255; //l transparent color
				*colorReducedPixelOut = 0;
			} else {
				Cube* cube = cubes;
				uint32_t r = (*pixels) & 0xFF;
				uint32_t g = ((*pixels) >> 8) & 0xFF;
				uint32_t b = ((*pixels) >> 16) & 0xFF;

				Cube* closestColorCube = cube;
				int32_t diffR = cube->color[RED] - r;
				int32_t diffG = cube->color[GREEN] - g;
				int32_t diffB = cube->color[BLUE] - b;
				uint32_t closestDifference = diffR * diffR + diffG * diffG + diffB * diffB;
				Cube* lastCube = cube + cubeNum;

				for (Cube* testCube = cube; testCube != lastCube; ++testCube) {
					diffR = testCube->color[RED] - r;
					diffG = testCube->color[GREEN] - g;
					diffB = testCube->color[BLUE] - b;
					uint32_t difference = diffR * diffR + diffG * diffG + diffB * diffB;

					if (difference < closestDifference) {
						closestDifference = difference;
						closestColorCube = testCube;
					}
				}

				uint32_t closestColor = closestColorCube - cube;
				cube = &cubes[closestColor];
				*pixelOut = closestColor;
				*colorReducedPixelOut = (0xFF000000 | (cube->color[BLUE] << 16) | (cube->color[GREEN] << 8) | cube->color[RED]);
				if (useDither) {
					diffR = r - (uint32_t)cube->color[RED];
					diffG = g - (uint32_t)cube->color[GREEN];
					diffB = b - (uint32_t)cube->color[BLUE];
					for (int directionId = 0; directionId < ERROR_PROPAGATION_DIRECTION_NUM; ++directionId) {
						uint32_t* pixel = pixels + ERROR_PROPAGATION_DIRECTION_X[directionId] + ERROR_PROPAGATION_DIRECTION_Y[directionId] * width;
						if (x + ERROR_PROPAGATION_DIRECTION_X[directionId] >= width ||
							y + ERROR_PROPAGATION_DIRECTION_Y[directionId] >= height || 0 == (*pixels >> 24)) {
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
