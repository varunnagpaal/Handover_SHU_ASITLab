//--------------------------------------------------------------------
// This confidential and propriety software may be used
// only as authorized by a licensing agreement from
// InSilicon corporation
//
// In the event of publication, the following notice is
// applicable
//
// (C) COPYRIGHT 2007 SYNOPSYS CORPORATION
// ALL RIGHTS RESERVED
//
// the entire notice must be reproduced on all
// authorized copies
//
//--------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#define col_conv 1
int **int_array(int, int);

main(int argc, char **argv)
{
	FILE *fpi, *fpo;
	char buff[200];
	int xsize, ysize, mcu_type;
	int x, y, i, j, linesize, rnd;
	int r, g, b, l, cb, cr;
	int lb[32][64], cbb[32][64], crb[32][64];
	int Hk, Vk;
	unsigned char *band, *wp;
	int *c0, *c1, *c2;
	int temp1, temp2 = 0, temp3, temp4 = 0; /*temp1,temp2,temp3and temp4 are the variables for handle the missing no of bytes                                             and missing no of lines in the x direction and y direction */
	int linebefore[1920][3] = {0};
	int ifmin127;
	int tl, tcb, tcr;
	int pix;
	if (argc < 6)
	{
		fprintf(stderr, "Usage: build <Xsize> <Ysize> <MCU format> <input YUV MCU file> <PPM Imagefile>\n");
		fprintf(stderr, "  MCU format  1 : MCU = 4Y +  Cb +  Cr  [SOF segment: HV(Y) = 22, HV(Cb,Cr) = 11]\n");
		fprintf(stderr, "              2 : MCU =  Y +  Cb +  Cr  [SOF segment: HV(Y) = 11, HV(Cb,Cr) = 11]\n");
		fprintf(stderr, "              3 : MCU = 4Y + 4Cb + 4Cr  [SOF segment: HV(Y) = 22, HV(Cb,Cr) = 22]\n");
		fprintf(stderr, "              4 : MCU = 2Y +  Cb +  Cr  [SOF segment: HV(Y) = 21, HV(Cb,Cr) = 11]\n");
		fprintf(stderr, "              5 : MCU = 2Y +  Cb +  Cr  [SOF segment: HV(Y) = 12, HV(Cb,Cr) = 11]\n");
		fprintf(stderr, "         TRUE 6 : MCU = 4Y +  Cb +  Cr  [SOF segment: HV(Y) = 14, HV(Cb,Cr) = 11]\n");
		fprintf(stderr, "              7 : By Line, 1x64 1:1:1\n");
		fprintf(stderr, "              9 : By Line, 1x64diff 1:1:1\n");
		fprintf(stderr, "              9 : By Line, 1x64diff 1:1:1\n");
		exit(1);
	}
	/* Get the X and Y size */
	sscanf(argv[1], "%d", &xsize);
	sscanf(argv[2], "%d", &ysize);
	/* using the below condition calculatr the no of missing bytes in the 
                                         x direction and y direction */

	if (xsize & 7)
	{
		temp1 = (8 - (xsize % 8));
	}
	else
	{
		temp1 = 0;
	}

	if (ysize & 7)
	{
		temp3 = (8 - (ysize % 8));
	}
	else
	{
		temp3 = 0;
	}

	sscanf(argv[3], "%d", &mcu_type);

	/* Open block file */
	if ((fpi = fopen(argv[4], "rb")) == NULL)
	{
		fclose(fpi);
		printf("Can't open %s\n", argv[4]);
		exit(1);
	}

	/* Open PPM image */
	if ((fpo = fopen(argv[5], "wb")) == NULL)
	{
		fclose(fpo);
		printf("Can't open %s\n", argv[5]);
		exit(1);
	}
	fprintf(fpo, "P6\n");
	fprintf(fpo, "%d %d\n", xsize, ysize);
	fprintf(fpo, "255\n");

	// Setup palette size based on MCU format
	if (mcu_type == 1)
	{
		Hk = 16;
		Vk = 16;
	}
	else if (mcu_type == 3)
	{
		printf(" mcu_type 3 is not allowed in JPEG standard ");
		Hk = 16;
		Vk = 16;
	}
	else if (mcu_type == 2)
	{
		Hk = 8;
		Vk = 8;
	}
	else if (mcu_type == 4)
	{
		Hk = 16;
		Vk = 8;
	}
	else if (mcu_type == 5)
	{
		Hk = 8;
		Vk = 16;
	}
	else if (mcu_type == 6)
	{
		Hk = 32;
		Vk = 8;
	}
	else if (mcu_type == 7 || mcu_type == 9)
	{
		Hk = 64;
		Vk = 1;
	}
	else
	{
		fprintf(stderr, "MCU format type not currently supported!!\n");
		exit(1);
	}

	/* this time verification for multiple of Vk and Hk and added the resultent value to the temp1 and temp2  */
	if ((xsize + temp1) & (Hk - 1))
	{
		temp2 = (xsize + temp1) % Hk;
		temp1 += temp2;
	}
	else
		temp1 += 0;
	if ((ysize + temp3) & (Vk - 1))
	{
		temp4 = (ysize + temp3) % Vk;
		temp3 += temp4;
	}
	else
		temp3 += 0;

	//printf("%d %d", temp1,temp3);

	/* Allocate memory for 3*Vk lines buffer */
	linesize = 3 * (xsize);
	band = (unsigned char *)malloc(Vk * linesize);

	for (y = 0; y < ysize; y += Vk)
	{
		// printf("开始新一行");
		for (x = 0; x < xsize; x += Hk)
		{

			switch (mcu_type)
			{
			case 1:
				// ------ 16 x 16 palette ------
				// Input 4 Y blocks
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);

				for (i = 0; i < 8; i++)
					for (j = 8; j < 16; j++)
						lb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 8; j < 16; j++)
						lb[i][j] = fgetc(fpi);

				// Input Cb block
				for (i = 0; i < 16; i += 2)
					for (j = 0; j < 16; j += 2)
						cbb[i][j] = fgetc(fpi);

				// Up interpolation
				for (i = 0; i < 16; i += 2)
				{
					for (j = 1; j < 15; j += 2)
						cbb[i][j] = (cbb[i][j - 1] + cbb[i][j + 1]) / 2;
					cbb[i][15] = cbb[i][14];
				}
				for (i = 1; i < 15; i += 2)
					for (j = 0; j < 16; j++)
						cbb[i][j] = (cbb[i - 1][j] + cbb[i + 1][j]) / 2;
				for (j = 0; j < 16; j++)
					cbb[15][j] = cbb[14][j];

				// Input Cr block
				for (i = 0; i < 16; i += 2)
					for (j = 0; j < 16; j += 2)
						crb[i][j] = fgetc(fpi);

				// Up interpolation
				for (i = 0; i < 16; i += 2)
				{
					for (j = 1; j < 15; j += 2)
						crb[i][j] = (crb[i][j - 1] + crb[i][j + 1]) / 2;
					crb[i][15] = crb[i][14];
				}
				for (i = 1; i < 15; i += 2)
					for (j = 0; j < 16; j++)
						crb[i][j] = (crb[i - 1][j] + crb[i + 1][j]) / 2;
				for (j = 0; j < 16; j++)
					crb[15][j] = crb[14][j];
				break;

			case 2:
				// ------ 8 x 8 palette ------
				// Input 1 Y block
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);
				// Input 1 Cb block
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						cbb[i][j] = fgetc(fpi);
				// Input 1 Cr block
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						crb[i][j] = fgetc(fpi);
				break;
			case 3:
				// ------ 16 x 16 palette ------
				// Input 4 Y blocks
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);

				for (i = 0; i < 8; i++)
					for (j = 8; j < 16; j++)
						lb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 8; j < 16; j++)
						lb[i][j] = fgetc(fpi);

				// Input 4 Cb blocks
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						cbb[i][j] = fgetc(fpi);

				for (i = 0; i < 8; i++)
					for (j = 8; j < 16; j++)
						cbb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 0; j < 8; j++)
						cbb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 8; j < 16; j++)
						cbb[i][j] = fgetc(fpi);

				// Input 4 Cr blocks
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						crb[i][j] = fgetc(fpi);

				for (i = 0; i < 8; i++)
					for (j = 8; j < 16; j++)
						crb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 0; j < 8; j++)
						crb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 8; j < 16; j++)
						crb[i][j] = fgetc(fpi);
				break;
			case 4:
				// ------ 16 x 8 palette ------
				// Input 2 Y blocks with h2v1 sampling factor
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);

				for (i = 0; i < 8; i++)
					for (j = 8; j < 16; j++)
						lb[i][j] = fgetc(fpi);

				// Input Cb block
				for (i = 0; i < 8; i++)
					for (j = 0; j < 16; j += 2)
						cbb[i][j] = fgetc(fpi);

				// Up interpolation
				for (i = 0; i < 8; i++)
				{
					for (j = 1; j < 15; j += 2)
						cbb[i][j] = (cbb[i][j - 1] + cbb[i][j + 1]) / 2;
					cbb[i][15] = cbb[i][14];
				}

				// Input Cr block
				for (i = 0; i < 8; i++)
					for (j = 0; j < 16; j += 2)
						crb[i][j] = fgetc(fpi);

				// Up interpolation
				for (i = 0; i < 8; i++)
				{
					for (j = 1; j < 15; j += 2)
						crb[i][j] = (crb[i][j - 1] + crb[i][j + 1]) / 2;
					crb[i][15] = crb[i][14];
				}
				break;
			case 5:
				// ------ 8 x 16 palette ------
				// Input 2 Y blocks with h1v2 sampling
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);

				for (i = 8; i < 16; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);

				// Input Cb block
				for (i = 0; i < 16; i += 2)
					for (j = 0; j < 8; j++)
						cbb[i][j] = fgetc(fpi);

				// Up interpolation
				for (i = 1; i < 15; i += 2)
					for (j = 0; j < 8; j++)
						cbb[i][j] = (cbb[i - 1][j] + cbb[i + 1][j]) / 2;
				for (j = 0; j < 8; j++)
					cbb[15][j] = cbb[14][j];

				// Input Cr block
				for (i = 0; i < 16; i += 2)
					for (j = 0; j < 8; j++)
						crb[i][j] = fgetc(fpi);

				// Up interpolation
				for (i = 1; i < 15; i += 2)
					for (j = 0; j < 8; j++)
						crb[i][j] = (crb[i - 1][j] + crb[i + 1][j]) / 2;
				for (j = 0; j < 8; j++)
					crb[15][j] = crb[14][j];
				break;
			case 6:
				// ------ 16 x 8 palette ------
				// Input 2 Y blocks with h2v1 sampling factor
				for (i = 0; i < 8; i++)
					for (j = 0; j < 8; j++)
						lb[i][j] = fgetc(fpi);
				for (i = 0; i < 8; i++)
					for (j = 8; j < 16; j++)
						lb[i][j] = fgetc(fpi);
				for (i = 0; i < 8; i++)
					for (j = 16; j < 24; j++)
						lb[i][j] = fgetc(fpi);
				for (i = 0; i < 8; i++)
					for (j = 24; j < 32; j++)
						lb[i][j] = fgetc(fpi);

				// Input Cb block
				for (i = 0; i < 8; i++)
					for (j = 3; j < 32; j += 4)
						cbb[i][j] = fgetc(fpi);
				// Up interpolation
				for (i = 0; i < 8; i++)
				{
					for (j = 2; j < 32; j += 4)
						cbb[i][j] = cbb[i][j + 1];
				}
				for (i = 0; i < 8; i++)
				{
					for (j = 1; j < 32; j += 4)
						cbb[i][j] = cbb[i][j + 1];
				}
				for (i = 0; i < 8; i++)
				{
					for (j = 0; j < 32; j += 4)
						cbb[i][j] = cbb[i][j + 1];
				}

				// Input Cr block
				for (i = 0; i < 8; i++)
					for (j = 3; j < 32; j += 4)
						crb[i][j] = fgetc(fpi);
				// Up interpolation
				for (i = 0; i < 8; i++)
				{
					for (j = 2; j < 32; j += 4)
						crb[i][j] = crb[i][j + 1];
				}
				for (i = 0; i < 8; i++)
				{
					for (j = 1; j < 32; j += 4)
						crb[i][j] = crb[i][j + 1];
				}
				for (i = 0; i < 8; i++)
				{
					for (j = 0; j < 32; j += 4)
						crb[i][j] = crb[i][j + 1];
				}
				break;
			case 7:
				for (i = 0; i < 1; i++)
					for (j = 0; j < 64; j++)
						lb[i][j] = fgetc(fpi);
				// Input 1 Cb block
				for (i = 0; i < 1; i++)
					for (j = 0; j < 64; j++)
						cbb[i][j] = fgetc(fpi);
				// Input 1 Cr block
				for (i = 0; i < 1; i++)
					for (j = 0; j < 64; j++)
						crb[i][j] = fgetc(fpi);
				break;
			case 9:
				for (i = 0; i < 1; i++)
					for (j = 0; j < 64; j++)
					{
						// pix = fgetc(fpi);
						// lb[i][j] = (pix << 1) - 255 + linebefore[x + j][0];
						// // if (linebefore[x + j][0] == 255)
						// // {
						// // 	getchar();
						// // 	printf("差值=%d,x=%d,j=%d,读入数据=%d,前一行像素=%d,待写出数据=%d", lb[i][j] - linebefore[x + j][0], x, j, pix, linebefore[x + j][0], lb[i][j]);
						// // }
						// lb[i][j] = (lb[i][j] < 0) ? 0 : lb[i][j];
						// lb[i][j] = (lb[i][j] > 255) ? 255 : lb[i][j];
						// linebefore[x + j][0] = lb[i][j];
						lb[i][j] = fgetc(fpi);
						// if (lb[i][j] >= 128)
						// 	lb[i][j] -= 1;
						// else if (lb[i][j] < 128)
						// 	lb[i][j] += 1;
						// lb[i][j] = ((lb[i][j] - 128) << 1);
						// lb[i][j] += linebefore[x + j][0];
						// lb[i][j] = (lb[i][j] < 0) ? 0 : lb[i][j];
						// lb[i][j] = (lb[i][j] > 255) ? 255 : lb[i][j];
						// linebefore[x + j][0] = lb[i][j];
						// lb[i][j] -= 127;
						// lb[i][j] += linebefore[1920 * 0 + x + j];
						// lb[i][j] = (lb[i][j] < 0) ? 0 : lb[i][j];
						// lb[i][j] = (lb[i][j] > 127) ? 127 : lb[i][j];
						// linebefore[1920 * 0 + x + j] = lb[i][j];
						// lb[i][j] <<= 1;
					} // Input 1 Cb block
				for (i = 0; i < 1; i++)
					for (j = 0; j < 64; j++)
					{
						// cbb[i][j] = (fgetc(fpi) << 1) - 255 + linebefore[x + j][1];
						// cbb[i][j] = (cbb[i][j] < 0) ? 0 : cbb[i][j];
						// cbb[i][j] = (cbb[i][j] > 255) ? 255 : cbb[i][j];
						// linebefore[x + j][1] = cbb[i][j];
						cbb[i][j] = fgetc(fpi);
						// if (cbb[i][j] >= 128)
						// 	cbb[i][j] -= 1;
						// else if (cbb[i][j] < 128)
						// 	cbb[i][j] += 1;
						// cbb[i][j] = ((cbb[i][j] - 128) << 1);
						// cbb[i][j] += linebefore[x + j][1];
						// cbb[i][j] = (cbb[i][j] < 0) ? 0 : cbb[i][j];
						// cbb[i][j] = (cbb[i][j] > 255) ? 255 : cbb[i][j];
						// linebefore[x + j][1] = cbb[i][j];
						// cbb[i][j] -= 127;
						// cbb[i][j] += linebefore[1920 * 1 + x + j];
						// cbb[i][j] = (cbb[i][j] < 0) ? 0 : cbb[i][j];
						// cbb[i][j] = (cbb[i][j] > 127) ? 127 : cbb[i][j];
						// linebefore[1920 * 1 + x + j] = cbb[i][j];
						// cbb[i][j] <<= 1;
					} // Input 1 Cr block
				for (i = 0; i < 1; i++)
					for (j = 0; j < 64; j++)
					{
						// crb[i][j] = (fgetc(fpi) << 1) - 255 + linebefore[x + j][2];
						// crb[i][j] = (crb[i][j] < 0) ? 0 : crb[i][j];
						// crb[i][j] = (crb[i][j] > 255) ? 255 : crb[i][j];
						// linebefore[x + j][2] = crb[i][j];
						crb[i][j] = fgetc(fpi);
						// if (crb[i][j] >= 128)
						// 	crb[i][j] -= 1;
						// else if (crb[i][j] < 128)
						// 	crb[i][j] += 1;
						// crb[i][j] = ((crb[i][j] - 128) << 1);
						// crb[i][j] += linebefore[x + j][2];
						// crb[i][j] = (crb[i][j] < 0) ? 0 : crb[i][j];
						// crb[i][j] = (crb[i][j] > 255) ? 255 : crb[i][j];
						// linebefore[x + j][2] = crb[i][j];
						// crb[i][j] -= 127;
						// crb[i][j] += linebefore[1920 * 2 + x + j];
						// crb[i][j] = (crb[i][j] < 0) ? 0 : crb[i][j];
						// crb[i][j] = (crb[i][j] > 127) ? 127 : crb[i][j];
						// linebefore[1920 * 2 + x + j] = crb[i][j];
						// crb[i][j] <<= 1;
					}
				break;
			default:
				fprintf(stderr, "MCU format type not currently supported!!\n");
				exit(1);
			}
			/* Grab a HkxVk block for each component */
			wp = band + 3 * x;

			c0 = &lb[0][0];
			c1 = &cbb[0][0];
			c2 = &crb[0][0];

			for (i = 0; i < Vk; i++)
			{
				for (j = 0; j < Hk; j++)
				{

					r = (*c0 << 16) + 91881 * (*c2 - 128);
					r /= 65536;
					if (r < 0)
						r = 0;
					else if (r > 255)
						r = 255;
					g = (*c0 << 16) - 22554 * (*c1 - 128) - 46802 * (*c2 - 128);
					g /= 65536;
					if (g < 0)
						g = 0;
					else if (g > 255)
						g = 255;
					b = (*c0 << 16) + 116130 * (*c1 - 128);
					b /= 65536;
					if (b < 0)
						b = 0;
					else if (b > 255)
						b = 255;

					if (col_conv)
					{
						/* for the last Vk no of lines if the image is not multiple of 
                                    Vk and Hk, then according to the temp1 and temp2 values the fallowing                                                       expression will control the memory */

						if (y == ((ysize + temp3) - Vk))
						{ // this expression for last vk no of lines

							if (i < (Vk - temp3))
							{ // this expression for missing no of lines

								if (x == ((xsize + temp1) - Hk))
								{ // this expression for last Hk no of bytes

									if (j < (Hk - temp1))
									{ // this expression for missing no of bytes
										*wp++ = (unsigned char)r;
										*wp++ = (unsigned char)g;
										*wp++ = (unsigned char)b;
									}
								}
								else
								{
									*wp++ = (unsigned char)r;
									*wp++ = (unsigned char)g;
									*wp++ = (unsigned char)b;
								}
							}
						}
						else
						{
							if (x == ((xsize + temp1) - Hk))
							{ // this expression for last Hk no of bytes
								if (j < (Hk - temp1))
								{ // this expression for missing no of bytes
									*wp++ = (unsigned char)r;
									*wp++ = (unsigned char)g;
									*wp++ = (unsigned char)b;
								}
							}
							else
							{
								*wp++ = (unsigned char)r;
								*wp++ = (unsigned char)g;
								*wp++ = (unsigned char)b;
							}
						}
					}
					else
					{
						*wp++ = (unsigned char)*c0;
						*wp++ = (unsigned char)*c1;
						*wp++ = (unsigned char)*c2;
					}
					c0++;
					c1++;
					c2++;
				}
				// Increment 16x16 component buffer
				// ptr by 8 bytes when Hk < 16.
				if (Hk < 16)
				{
					c0 += Hk;
					c1 += Hk;
					c2 += Hk;
				}
				if (x == ((xsize + temp1) - Hk)) // the memory allocation when the last Hk no of bytes
					wp += (linesize - ((Hk - temp1) * 3));
				else
					wp += (linesize - (Hk * 3));
			}
		}
		/* Output the line buffer */
		wp = band;
		for (x = 0; x < xsize * 3 * Vk; x++)
			fputc(*wp++, fpo);
	}

	/* Close files */
	fclose(fpi);
	fclose(fpo);
}

/* Allocate 2-D array [Hk][Vk] for individual components */
int **int_array(int width, int height)
{
	int **a;
	int i, j;

	if (!(a = (int **)calloc(height, sizeof(int *))))
	{
		fprintf(stderr, "int_array: calloc error 1\n");
		exit(0);
	}
	for (i = 0; i < (height); i++)
	{
		if (!(a[i] = (int *)calloc(width, sizeof(int))))
		{
			fprintf(stderr, "int_array: calloc error 2\n");
			exit(0);
		}
	}
	return a;
}
