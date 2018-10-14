/* ///////////////////////////////////////////////////////////////////// */
/*  File   : find_face.c                                                 */
/*  Author : Chun-Jen Tsai                                               */
/*  Date   : 02/09/2013                                                  */
/* --------------------------------------------------------------------- */
/*  This program will locate the position of a 32x32 face template       */
/*  in a group photo.                                                    */
/*                                                                       */
/*  This program is designed for the undergraduate course                */
/*  "Introduction to HW-SW Codesign and Implementation" at               */
/*  the department of Computer Science, National Chiao Tung University.  */
/*  Hsinchu, 30010, Taiwan.                                              */
/* ///////////////////////////////////////////////////////////////////// */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>
#include "image.h"

#include "xparameters.h"  /* SDK generated parameters */
#include "xsdps.h"        /* for SD device driver     */
#include "ff.h"
#include "xil_cache.h"
#include "xplatform_info.h"
#include "xtime_l.h"

/* Global Timer is always clocked at half of the CPU frequency */
#define COUNTS_PER_USECOND  (XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ / 2000000)
#define FREQ_MHZ ((XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ+500000)/1000000)
#define XPAR_MY_DMA_0_S00_AXI_BASEADDR (0x43C00000)

/* Declare a microsecond-resolution timer function */
long get_usec_time()
{
	XTime time_tick;

	XTime_GetTime(&time_tick);
	return (long) (time_tick / COUNTS_PER_USECOND);
}

/* function prototypes. */
void median3x3(uint8 *image, int width, int height);
void match(uint8 *im1, uint8 *im2, uint8 *im3, uint8 *im4, uint8 *im5);

/* SD card I/O variables */
static FATFS fatfs;

volatile int *hw_active = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR +  0);
volatile int *src_addr  = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR +  4);
volatile int *is_face   = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR +  8);
volatile int *dst_addr  = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 12);
volatile int *col1 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 16);
volatile int *row1 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 20);
volatile int *sad1 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 24);
volatile int *col2 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 28);
volatile int *row2 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 32);
volatile int *sad2 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 36);
volatile int *col3 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 40);
volatile int *row3 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 44);
volatile int *sad3 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 48);
volatile int *col4 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 52);
volatile int *row4 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 56);
volatile int *sad4 = (int *) (XPAR_MY_DMA_0_S00_AXI_BASEADDR + 60);

int   posx[4], posy[4];
int32 cost[4];

int main(int argc, char **argv)
{
    CImage group, face[4];
    int  width, height;
    long tick;

    /* Initialize the SD card driver. */
	if (f_mount(&fatfs, "0:/", 0))
	{
		return XST_FAILURE;
	}

    printf("1. Reading images ... ");
    tick = get_usec_time();

    /* Read the group image file into the DDR main memory */
    if (read_pnm_image("group.pgm", &group))
    {
        printf("\nError: cannot read the group.pgm image.\n");
    	return 1;
    }
    width = group.width, height = group.height;

    /* Reading the 32x32 target face image into main memory */
    if (read_pnm_image("face.pgm", face))
    {
        printf("\nError: cannot read the face.pgm image.\n");
    	return 1;
    }
    if (read_pnm_image("face10.pgm", face+1))
	{
		printf("\nError: cannot read the face.pgm image.\n");
		return 1;
	}
    if (read_pnm_image("face7.pgm", face+2))
	{
		printf("\nError: cannot read the face.pgm image.\n");
		return 1;
	}
    if (read_pnm_image("face8.pgm", face+3))
	{
		printf("\nError: cannot read the face.pgm image.\n");
		return 1;
	}
    tick = get_usec_time() - tick;
    printf("done in %ld msec.\n", tick/1000);

    /* Perform median filter for noise removal */
    printf("2. Median filtering ... ");
    tick = get_usec_time();
    median3x3(group.pix, width, height);
    tick = get_usec_time() - tick;
    printf("done in %ld msec.\n", tick/1000);

    /* Perform face-matching */
    printf("3. Face-matching ... ");
    tick = get_usec_time();
    *is_face = 1;
    match(group.pix, face[0].pix, face[1].pix, face[2].pix, face[3].pix);
    tick = get_usec_time() - tick;
    printf("done in %ld msec.\n\n", tick/1000);
    for (int i = 0; i < 4; i++) {
    	printf("** Found the face%d at (%d, %d) with cost %ld\n\n", i, posx[i], posy[i], cost[i]);
    }

    /* free allocated memory */
    for (int i = 0; i < 4; i++) {
    	free(face[i].pix);
    }
    free(group.pix);

    return 0;
}

void matrix_to_array(uint8 *pix_array, uint8 *ptr, int width)
{
    int  idx, x, y;

    idx = 0;
    for (y = -1; y <= 1; y++)
    {
        for (x = -1; x <= 1; x++)
        {
            pix_array[idx++] = *(ptr+x+width*y);
        }
    }
}

void insertion_sort(uint8 *pix_array, int size)
{
    int idx, jdx;
    uint8 temp;

    for (idx = 1; idx < size; idx++)
    {
        for (jdx = idx; jdx > 0; jdx--)
        {
            if (pix_array[jdx] < pix_array[jdx-1])
            {
                /* swap */
                temp = pix_array[jdx];
                pix_array[jdx] = pix_array[jdx-1];
                pix_array[jdx-1] = temp;
            }
        }
    }
}

void median3x3(uint8 *image, int width, int height)
{
    int   row, col;
    uint8 pix_array[9], *ptr;

    for (row = 1; row < height-1; row++)
    {
        for (col = 1; col < width-1; col++)
        {
            ptr = image + row*width + col;
            matrix_to_array(pix_array, ptr, width);
            insertion_sort(pix_array, 9);
            *ptr = pix_array[4];
        }
    }
}

void match (uint8 *image1, uint8 *image2, uint8 *image3, uint8 *image4, uint8 *image5)
{
	for (int i = 0; i < 4; i++)
		cost[i] = 0xFFFFFF;

	// Face 1
	*src_addr = (int) image2;
	*is_face = 1;
	*dst_addr = (int) (image2+4);

	*hw_active = 1;
	while (*hw_active) ;

	// Face 2
	*src_addr = (int) image3;
	*is_face = 2;
	*dst_addr = (int) (image3+4);

	*hw_active = 1;
	while (*hw_active) ;

	// Face 3
	*src_addr = (int) image4;
	*is_face = 3;
	*dst_addr = (int) (image4+4);

	*hw_active = 1;
	while (*hw_active) ;

	// Face 4
	*src_addr = (int) image5;
	*is_face = 4;
	*dst_addr = (int) (image5+4);

	*hw_active = 1;
	while (*hw_active) ;

	// Group
	*src_addr = (int) image1;
	*is_face = 0;
	*dst_addr = (int) (image1+(1920-32));

	*hw_active = 1;
	while (*hw_active) {
		// Face 1 last column
		for (int row = 0; row < 1080; row++) {
			int tmp_sad = 0;
			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					tmp_sad += abs(image2[i*32+j] - image1[(row+i)*1920+(1888+j)]);
				}
				if (tmp_sad > cost[0]) break;
			}
			if (tmp_sad < cost[0]) cost[0] = tmp_sad, posx[0] = 1888, posy[0] = row;
		}
		// Face 2 last column
		for (int row = 0; row < 1080; row++) {
			int tmp_sad = 0;
			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					tmp_sad += abs(image3[i*32+j] - image1[(row+i)*1920+(1888+j)]);
				}
				if (tmp_sad > cost[1]) break;
			}
			if (tmp_sad < cost[1]) cost[1] = tmp_sad, posx[1] = 1888, posy[1] = row;
		}
		// Face 3 last column
		for (int row = 0; row < 1080; row++) {
			int tmp_sad = 0;
			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					tmp_sad += abs(image4[i*32+j] - image1[(row+i)*1920+(1888+j)]);
				}
				if (tmp_sad > cost[2]) break;
			}
			if (tmp_sad < cost[2]) cost[2] = tmp_sad, posx[2] = 1888, posy[2] = row;
		}
		// Face 4 last column
		for (int row = 0; row < 1080; row++) {
			int tmp_sad = 0;
			for (int i = 0; i < 32; i++) {
				for (int j = 0; j < 32; j++) {
					tmp_sad += abs(image5[i*32+j] - image1[(row+i)*1920+(1888+j)]);
				}
				if (tmp_sad > cost[3]) break;
			}
			if (tmp_sad < cost[3]) cost[3] = tmp_sad, posx[3] = 1888, posy[3] = row;
		}
	}

	if (*sad1 < cost[0]) cost[0] = *sad1, posx[0] = *col1, posy[0] = *row1;
	if (*sad2 < cost[1]) cost[1] = *sad2, posx[1] = *col2, posy[1] = *row2;
	if (*sad3 < cost[2]) cost[2] = *sad3, posx[2] = *col3, posy[2] = *row3;
	if (*sad4 < cost[3]) cost[3] = *sad4, posx[3] = *col4, posy[3] = *row4;
}

