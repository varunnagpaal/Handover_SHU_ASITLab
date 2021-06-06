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
// File : extract.c
// Abstract :
//   This programs opens a binary colour PPM file
//   and saves it as 8X8 blocks in the MCU format requested.
//   Y, Cr and Cb components are filtered and subsampled.
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
    int x, y, i, j, linesize;
    int r, g, b, l, cb, cr;
    int lb[32][64], cbb[32][64], crb[32][64];
    //int **lb,**cbb,**crb;
    int Hk, Vk;
    unsigned char *band, *wp;
    int *c0, *c1, *c2;
    int zzorder[8][8] = {0, 1, 5, 6, 14, 15, 27, 28,
                         2, 4, 7, 13, 16, 26, 29, 42,
                         3, 8, 12, 17, 25, 30, 41, 43,
                         9, 11, 18, 24, 31, 40, 44, 53,
                         10, 19, 23, 32, 39, 45, 52, 54,
                         20, 22, 33, 38, 46, 51, 55, 60,
                         21, 34, 37, 47, 50, 56, 59, 61,
                         35, 36, 48, 49, 57, 58, 62, 63};

    if (argc < 4)
    {
        fprintf(stderr, "Usage: extract <MCU format> <PPM Imagefile> <Output YUV MCU file>\n");
        fprintf(stderr, "  MCU format  1 : MCU = 4Y +  Cb +  Cr  [SOF segment: HV(Y) = 22, HV(Cb,Cr) = 11]\n");
        fprintf(stderr, "              2 : MCU =  Y +  Cb +  Cr  [SOF segment: HV(Y) = 11, HV(Cb,Cr) = 11]\n");
        fprintf(stderr, "              3 : MCU = 4Y + 4Cb + 4Cr  [SOF segment: HV(Y) = 22, HV(Cb,Cr) = 22]\n");
        fprintf(stderr, "              4 : MCU = 2Y +  Cb +  Cr  [SOF segment: HV(Y) = 21, HV(Cb,Cr) = 11]\n");
        fprintf(stderr, "              5 : MCU = 2Y +  Cb +  Cr  [SOF segment: HV(Y) = 12, HV(Cb,Cr) = 11]\n");
        fprintf(stderr, "         TRUE 6 : MCU = 4Y +  Cb +  Cr  [SOF segment: HV(Y) = 14, HV(Cb,Cr) = 11]\n");
        fprintf(stderr, "              7 : By Line, 1x64 1:1:1\n");
        fprintf(stderr, "              8 : By Line, zz1x64 1:1:1\n");
        exit(1);
    }

    sscanf(argv[1], "%d", &mcu_type);

    /* Open PPM image */
    if ((fpi = fopen(argv[2], "rb")) == NULL)
    {
        fclose(fpi);
        printf("Can't open %s\n", argv[2]);
        exit(1);
    }

    /* Check whether PPM */
    fscanf(fpi, "%s", buff);
    if (strcmp(buff, "P6"))
    {
        fclose(fpi);
        printf("Not a PPM image!\n");
        exit(1);
    }

    fgetc(fpi);
    fgets(buff, 200, fpi);
    while (buff[0] == '#')
        fgets(buff, 200, fpi);

    /* Get the image resolution */
    sscanf(buff, "%d %d", &xsize, &ysize);
    if ((xsize & 63))
    {
        // fclose(fpi);
        printf("The image Y size is not a multiple of 64\n");
        // exit(1);
    }
    //   /* Get the image resolution */
    //   sscanf(buff,"%d %d",&xsize,&ysize);
    //   if((xsize&15) || (ysize&15)){
    //     fclose(fpi);
    //     printf("The image Y or Y size is not a multiple of 16\n");
    //     exit(1);
    //   }

    /* Check if 255 levels */
    fscanf(fpi, "%s", buff);
    if (strcmp(buff, "255"))
    {
        fclose(fpi);
        printf("Not a 255 levels PPM!\n");
        exit(1);
    }
    fgetc(fpi);

    /* Opens the output file */
    if ((fpo = fopen(argv[3], "wb")) == NULL)
    {
        fclose(fpi);
        fclose(fpo);
        printf("Can't open %s\n", argv[3]);
        exit(1);
    }

    // Setup palette size based on MCU format
    if (mcu_type == 1 || mcu_type == 3)
    {
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
    else if (mcu_type == 7 || mcu_type == 8)
    {
        Hk = 64;
        Vk = 1;
    }
    else
    {
        fprintf(stderr, "MCU format type not currently supported!!\n");
        exit(1);
    }

    /* Allocate memory for 3*Vk lines buffer */
    linesize = 3 * xsize;
    band = (unsigned char *)malloc(Vk * linesize);

    /* Process Vk lines at a time */
    for (y = 0; y < ysize; y += Vk)
    {

        /* Read and colour convert */
        wp = band;
        for (i = 0; i < Vk; i++)
        {
            for (x = 0; x < xsize; x++)
            {
                r = fgetc(fpi);
                g = fgetc(fpi);
                b = fgetc(fpi);
                l = 19595 * r + 38470 * g + 7471 * b;
                l += 32768;
                l /= 65536;
                if (l < 0)
                    l = 0;
                else if (l > 255)
                    l = 255;
                cb = -11056 * r - 21712 * g + 32768 * b + 8388608;
                cb += 32768;
                cb /= 65536;
                if (cb < 0)
                    cb = 0;
                else if (cb > 255)
                    cb = 255;
                cr = 32768 * r - 27440 * g - 5328 * b + 8388608;
                cr += 32768;
                cr /= 65536;
                if (cr < 0)
                    cr = 0;
                else if (cr > 255)
                    cr = 255;
                if (col_conv)
                {
                    *wp++ = (unsigned char)l;
                    *wp++ = (unsigned char)cb;
                    *wp++ = (unsigned char)cr;
                }
                else
                {
                    *wp++ = (unsigned char)r;
                    *wp++ = (unsigned char)g;
                    *wp++ = (unsigned char)b;
                }
            }
        } // Colour converted Vk lines of image.

        /* Write as 8X8 blocks based on MCU format */
        for (x = 0; x < xsize; x += Hk)
        {

            /* Grab a Hk * Vk block for each component */
            wp = band + 3 * x;
            c0 = &lb[0][0];
            c1 = &cbb[0][0];
            c2 = &crb[0][0];
            for (i = 0; i < Vk; i++)
            {
                for (j = 0; j < Hk; j++)
                {
                    *c0++ = (int)*wp++;
                    *c1++ = (int)*wp++;
                    *c2++ = (int)*wp++;
                }
                // Increment 16x16 component buffer
                // ptr by 8 bytes when Hk < 16.
                if (Hk < 16)
                {
                    c0 += Hk;
                    c1 += Hk;
                    c2 += Hk;
                }
                wp += (linesize - (Hk * 3));
            }

            switch (mcu_type)
            {
            case 1:
                // ------ 16 x 16 palette ------
                /* Output 4 Y blocks */
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);

                for (i = 0; i < 8; i++)
                    for (j = 8; j < 16; j++)
                        fputc(lb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 8; j < 16; j++)
                        fputc(lb[i][j], fpo);

                // Output Cb block
                for (i = 0; i < 16; i += 2)
                    for (j = 0; j < 16; j += 2)
                    {
                        cb = cbb[i][j] + cbb[i][j + 1] + cbb[i + 1][j] + cbb[i + 1][j + 1] + 2;
                        cb >>= 2;
                        fputc(cb, fpo);
                    }

                // Output Cr block
                for (i = 0; i < 16; i += 2)
                    for (j = 0; j < 16; j += 2)
                    {
                        cr = crb[i][j] + crb[i][j + 1] + crb[i + 1][j] + crb[i + 1][j + 1] + 2;
                        cr >>= 2;
                        fputc(cr, fpo);
                    }
                break;

            case 2:
                // ------ 8 x 8 palette ------
                // Output 1 Y block
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);
                // Output 1 Cb block
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(cbb[i][j], fpo);
                // Output 1 Cr block
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(crb[i][j], fpo);
                break;
            case 3:
                // ------ 16 x 16 palette ------
                /* Output 4 Y blocks */
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);

                for (i = 0; i < 8; i++)
                    for (j = 8; j < 16; j++)
                        fputc(lb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 8; j < 16; j++)
                        fputc(lb[i][j], fpo);

                /* Output 4 Cb blocks */
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(cbb[i][j], fpo);

                for (i = 0; i < 8; i++)
                    for (j = 8; j < 16; j++)
                        fputc(cbb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 0; j < 8; j++)
                        fputc(cbb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 8; j < 16; j++)
                        fputc(cbb[i][j], fpo);

                /* Output 4 Cr blocks */
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(crb[i][j], fpo);

                for (i = 0; i < 8; i++)
                    for (j = 8; j < 16; j++)
                        fputc(crb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 0; j < 8; j++)
                        fputc(crb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 8; j < 16; j++)
                        fputc(crb[i][j], fpo);
                break;
            case 4:
                // ------ 16 x 8 palette ------
                // Output 2 Y blocks with h2v1 sampling
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);

                for (i = 0; i < 8; i++)
                    for (j = 8; j < 16; j++)
                        fputc(lb[i][j], fpo);

                // Output Cb block
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 16; j += 2)
                    {
                        cb = cbb[i][j] + cbb[i][j + 1] + 1;
                        cb >>= 1;
                        fputc(cb, fpo);
                    }

                // Output Cr block
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 16; j += 2)
                    {
                        cr = crb[i][j] + crb[i][j + 1] + 1;
                        cr >>= 1;
                        fputc(cr, fpo);
                    }
                break;
            case 5:
                // ------ 8 x 16 palette ------
                // Output 2 Y blocks with h1v2 sampling
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);

                for (i = 8; i < 16; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);

                // Output Cb block
                for (i = 0; i < 16; i += 2)
                    for (j = 0; j < 8; j++)
                    {
                        cb = cbb[i][j] + cbb[i + 1][j] + 1;
                        cb >>= 1;
                        fputc(cb, fpo);
                    }

                // Output Cr block
                for (i = 0; i < 16; i += 2)
                    for (j = 0; j < 8; j++)
                    {
                        cr = crb[i][j] + crb[i + 1][j] + 1;
                        cr >>= 1;
                        fputc(cr, fpo);
                    }
                break;
            case 6:
                // ------ 8 x 16 palette ------
                // Output 2 Y blocks with h1v2 sampling
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        fputc(lb[i][j], fpo);
                for (i = 0; i < 8; i++)
                    for (j = 8; j < 16; j++)
                        fputc(lb[i][j], fpo);
                for (i = 0; i < 8; i++)
                    for (j = 16; j < 24; j++)
                        fputc(lb[i][j], fpo);
                for (i = 0; i < 8; i++)
                    for (j = 24; j < 32; j++)
                        fputc(lb[i][j], fpo);

                // Output Cb block
                for (i = 0; i < 8; i++)
                    for (j = 3; j < 32; j += 4)
                    {
                        // cb = cbb[i][j] + cbb[i + 1][j] + 1;
                        // cb >>= 1;
                        cb = cbb[i][j];
                        fputc(cb, fpo);
                    }

                // Output Cr block
                for (i = 0; i < 8; i++)
                    for (j = 3; j < 32; j += 4)
                    {
                        // cr = crb[i][j] + crb[i + 1][j] + 1;
                        // cr >>= 1;
                        cr = crb[i][j];
                        fputc(cr, fpo);
                    }
                break;
            case 7:
                for (i = 0; i < 1; i++)
                    for (j = 0; j < 64; j++)
                        fputc(lb[i][j], fpo);

                for (i = 0; i < 1; i++)
                    for (j = 0; j < 64; j++)
                        fputc(cbb[i][j], fpo);

                for (i = 0; i < 1; i++)
                    for (j = 0; j < 64; j++)
                        fputc(crb[i][j], fpo);
                break;
            case 8:
                for (i = 0; i < 1; i++)
                    for (j = 0; j < 64; j++)
                        fputc(lb[i][zzorder[i][j]], fpo);

                for (i = 0; i < 1; i++)
                    for (j = 0; j < 64; j++)
                        fputc(cbb[i][zzorder[i][j]], fpo);

                for (i = 0; i < 1; i++)
                    for (j = 0; j < 64; j++)
                        fputc(crb[i][zzorder[i][j]], fpo);
                break;
            default:
                fprintf(stderr, "MCU format type not currently supported!!\n");
                exit(1);
            }
        }
    }
    /* Close files */
    fclose(fpi);
    fclose(fpo);
}

/* Allocate 2-D array [Hk][Vk] for individual compomemts */
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
