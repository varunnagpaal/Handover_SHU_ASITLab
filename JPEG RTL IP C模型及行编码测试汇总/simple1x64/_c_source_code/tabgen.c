/*
 ---------------------------------------------------------
 This confidential and propriety software may be used
 only as authorized by a licensing agreement from
 Synopsys corporation

 In the event of publication, the following notice is
 applicable

 (C) COPYRIGHT 2007 SYNOPSYS INC
 ALL RIGHTS RESERVED

 the entire notice must be reproduced on all
 authorized copies

---------------------------------------------------------
*/

#include <stdio.h>
#include <stdlib.h>
#include "qlook.h"

#define MAX_COMPS_IN_ONE_SCAN 4

//#ifdef _DEBUG
#if 0
#define DEBUG(args...) ({ printf("(D) %s#%d: ",__FILE__,__LINE__); printf(args); printf("\n"); })
#define INFO(args...) ({ printf("(I) %s#%d: ",__FILE__,__LINE__); printf(args); printf("\n"); })
#define WARNING(args...) ({ printf("(W) %s#%d: ",__FILE__,__LINE__); printf(args); printf("\n"); })
#define ERROR(args...) ({ printf("(E) %s#%d: ",__FILE__,__LINE__); printf(args); printf("\n"); })
#else
#define DEBUG(args...) ({ printf(args); printf("\n"); })
#define INFO(args...) ({ printf(args); printf("\n"); })
#define WARNING(args...) ({ printf(args); printf("\n"); })
#define ERROR(args...) ({ printf("(E) %s#%d: ",__FILE__,__LINE__); printf(args); printf("\n"); })
#endif

// jcc -
#define JMARKER(xx, szMak) INFO("Marker 0x%02x - %s", (xx), szMak);

static int hea[64] = {0};               // -> BASE mem (base.dat) - 9 bits array
static int heb[336] = {0};              // -> SYMB mem (symb.dat) - 8 bits array
static int hcode[4][256], hlen[4][256]; // -> Huffman simulation mem values (hmem.sim)
static int min[64];                     // -> min values (min.dat)
static int qt[4][64];                   // QT (qdtable.dat)

// encoder only tables : huffenc & qlook
static int huffenc[384] = {0};

main(int argc, char **argv)
{
    FILE *fp, *fpo;
    int i, j, n, v, c, rst, nm, code, hid;
    int dc, ht, abase, bbase, hbase, hb;
    char s[3];
    int l[16];

    char tmp[4];
    int nTemp;

    if (argc < 2)
    {
        fprintf(stderr, "Usage: tabgen <JPEG Imagefile> \n");
        exit(1);
    }

    /* Initialize HuffEnc with default values */
    for (i = 0; i < 384; i++)
        huffenc[i] = 0xfff;
    for (i = 168, j = 0xfd0; i < 176; i++, j++)
        huffenc[i] = j;
    for (i = 344, j = 0xfd0; i < 352; i++, j++)
        huffenc[i] = j;

    ht = nm = rst = 0;
    for (i = 162; i < 174; i++)
        heb[i] = 0;

    for (i = 0; i < 4; i++)
        for (j = 0; j < 256; j++)
            hlen[i][j] = 0;

    for (i = 0; i < 4; i++)
        for (j = 0; j < 64; j++)
            qt[i][j] = 0;

    /* Open file */
    if ((fp = fopen(argv[1], "rb")) == NULL)
    {
        printf("Can't open %s\n", argv[1]);
        exit(1);
    }

    while ((c = fgetc(fp)) != EOF)
    {
        if (c != 0xff)
            continue;

        /* Found a potential marker */
        while ((c = fgetc(fp)) == 0xff)
            ;
        if (c == 0)
        {
            nm++;
            continue; /* It wasn't a marker */
        }

        /* Which marker ? */
    marker:
        switch (c)
        {
        case 0xc0: // Baseline (0, 0)
        case 0xc1: // Ext. Sequential, Huffman (0, 0)
        case 0xc2: // Progressive, Huffman (1, 0)
        case 0xc3: // Lossless, Huffman
        case 0xc5: // Differential Sequential, Huffman
        case 0xc6: // Differential Progressive, Huffman
        case 0xc7: // Differential Lossless, Huffman
        case 0xc9: // Extended Sequential, Arithmetic (0, 1)
        case 0xca: // Progressive, Arithmetic (1, 1)
        case 0xcb: // Lossless, Huffman
        case 0xcd: // Differential Sequential, Arithmetic
        case 0xce: // Differential Progressive, Arithmetic
        case 0xcf: // Differential Lossless, Arithmetic
            fgetc(fp);
            fgetc(fp);
            fgetc(fp);
            fgetc(fp);
            fgetc(fp);
            fgetc(fp);
            fgetc(fp);
            n = fgetc(fp);
            for (i = 0; i < n; i++)
            {
                fgetc(fp);
                fgetc(fp);
                fgetc(fp);
            }
            JMARKER(c, "SOF");
            INFO("\tRead extra %d bytes", c, 8 + (n * 3));
            break;

        case 0xc4:
            /* DHT marker detected */
            printf("---------------------------------\n");
            JMARKER(c, "DHT"); // Huffman Table
            /* Get the lenght of the marker segment */
            // Lh : HT length (16b)
            v = fgetc(fp);
            n = (v << 8) | fgetc(fp);

            printf("Lh %d\n", n);
            /* Reduce marker segment byte count */
            n -= 2;

            while (n)
            {

                /* Get the type of table */
                v = fgetc(fp); // Tc & Th
                // Tc : Table class (4b)
                //      0 = DC or lossless table
                //      1 = AC table
                // Th : HT destination identifier
                // - specifies 1 of 4 possible destinations at the decoder into
                // which HT shall be installed.

                /* Reduce marker segment byte count */
                n--;

                printf("Tc %d\n", v >> 4);
                printf("Th %d\n", v & 15);
                hid = v >> 4 ? 2 : 0;
                hid |= v & 15 ? 1 : 0;
                switch (hid)
                {
                case 1:
                    hbase = 368;
                    break;
                case 2:
                    hbase = 0;
                    break;
                case 3:
                    hbase = 176;
                    break;
                default:
                    hbase = 352;
                    break;
                }
                if ((v >> 4))
                    abase = 0;
                else
                    abase = 1;
                dc = abase;
                ht = v & 15;
                abase |= ht << 1;
                switch (abase)
                {
                case 1:
                case 3:
                    bbase = 162;
                    break;
                case 2:
                    bbase = 174;
                    break;
                default:
                    bbase = 0;
                    break;
                }
                abase <<= 4;
                /* Memory initialization */
                for (i = abase; i < abase + 16; i++)
                    hea[i] = 255;
                /* Get the number of codes for each length */
                // Lj : # of Huffman codes of length i
                // - specifies the # of Huffman codes for each of 16 possible lengths
                // allowed by spec. BITS
                for (i = 0; i < 16; i++)
                {
                    l[i] = fgetc(fp);
                }
                /* Reduce marker segment byte count */

                n -= 16;
                code = 0;
                for (i = 0; i < 16; i++, abase++)
                {
                    min[abase] = code;
                    hea[abase] = bbase - code;
                    if (l[i])
                        // Vi,j : associated with each Huffman code
                        // - specifies, for each i the value associated with each Huffman code
                        // of length i.  HUFFVAL
                        for (j = 0; j < l[i]; j++, bbase++)
                        {
                            v = fgetc(fp);
                            /* Reduce marker segment byte count */
                            n--;
                            hcode[hid][v] = code;
                            hlen[hid][v] = i + 1;
                            if (dc)
                            {
                                huffenc[hbase + v] = (i << 8) | (code & 0xff);
                                v &= 15;
                                if (ht)
                                    v <<= 4;
                                heb[bbase] |= v;
                            }
                            else
                            {
                                if (v == 0)
                                    hb = 160;
                                else if (v == 0xf0)
                                    hb = 161;
                                else
                                    hb = (v >> 4) * 10 + (v & 0xf) - 1;
                                huffenc[hbase + hb] = (i << 8) | (code & 0xff);
                                heb[bbase] = v;
                            }
                            code++;
                        }
                    code <<= 1;
                }
            }
            break;

        case 0xc8:
            printf("---------------------------------\n");
            JMARKER(c, "JPG extensions !!!");
            exit(1);
            break;

        case 0xcc:
            printf("---------------------------------\n");
            JMARKER(c, "DAC !!! (arithmatic coding not supported)");
            exit(1);
            break;

        case 0xd0:
        case 0xd1:
        case 0xd2:
        case 0xd3:
        case 0xd4:
        case 0xd5:
        case 0xd6:
        case 0xd7:
            printf("---------------------------------\n");
            JMARKER(c, "RST");
            printf("reset %d\n", c & 15);
            rst++;
            break;

        case 0xd8:
            JMARKER(c, "SOI");
            break;

        case 0xd9:
            JMARKER(c, "EOI");

            fputc(0xff, fpo);
            fputc(0xd9, fpo);
            break;

        case 0xda:
            printf("---------------------------------\n");
            printf("SOS\n"); // Start of Scan
            tmp[0] = fgetc(fp);
            tmp[1] = fgetc(fp);
            nTemp = (tmp[0] << 8) | (tmp[1]); //Ls (scan header length)
            n = fgetc(fp);                    //Ns (# of image components)
            printf("Ls = 0x%d, Ns = %02x\n", nTemp, n);

            if ((nTemp != (n * 2 + 6)) || (n < 1) || (n > MAX_COMPS_IN_ONE_SCAN))
            {
                ERROR("bad scan length Ls = %d vs. (%d * 2 + 6)\n", nTemp, n);
            }

            for (i = 0; i < n; i++)
            {
                // Cs, Td&Ta
                fgetc(fp);
                fgetc(fp);
            }
            fgetc(fp); //Ss
            fgetc(fp); //Se
            fgetc(fp); //Ah&Al
            fpo = fopen("ecs.bin", "wb");
            for (;;)
            {
                c = fgetc(fp);
                if (c == 0xff)
                {
                    c = fgetc(fp);

                    if ((c != 0x00) && ((c & 0xf8) != 0xd0))
                    {
                        //fclose(fpo);
                        goto marker;
                    }
                    else
                    {
                        fputc(0xff, fpo);
                    }
                }
                fputc(c, fpo);
            }
            break;

        case 0xdb:
            printf("---------------------------------\n");
            JMARKER(c, "DQT"); // Quantization Table
            // Lq : QT Length (16b)
            v = fgetc(fp);
            v = (v << 8) | fgetc(fp);
            printf("Lq %d\n", v);

            // Photoshop生成的jpeg图像，两张量化表只用了一个FFDB标志标记出来
            if (v == 132)
            {
                v = fgetc(fp);
                printf("Pq %d\n", v >> 4);
                printf("Tq %d\n", v & 15);
                n = v & 15;
                for (i = 0; i < 64; i++)
                {
                    // Qk: Quantization table element
                    // k is the index in the zigzag ordering of the DCT coeff
                    // JPC only do 8-bit Qk! (ie, Pq shall be 0)
                    qt[n][i] = fgetc(fp);
                }
                v = fgetc(fp);
                printf("Pq %d\n", v >> 4);
                printf("Tq %d\n", v & 15);
                n = v & 15;
                for (i = 0; i < 64; i++)
                {
                    // Qk: Quantization table element
                    // k is the index in the zigzag ordering of the DCT coeff
                    // JPC only do 8-bit Qk! (ie, Pq shall be 0)
                    qt[n][i] = fgetc(fp);
                }
            }

            else
            {
                v = fgetc(fp);
                // Pq : QT element precision (4b)
                // - specifies the precision of the Qk values.
                //   0 indicates 8-bits Qk values.
                //   1 indicates 16-bits Qk values
                printf("Pq %d\n", v >> 4);
                // Tq : QT destination identifier (4b)
                // - specifies one of 4 possible destnations at the decoder into
                // which the QT shall be installed.
                printf("Tq %d\n", v & 15);
                n = v & 15;
                for (i = 0; i < 64; i++)
                {
                    // Qk: Quantization table element
                    // k is the index in the zigzag ordering of the DCT coeff
                    // JPC only do 8-bit Qk! (ie, Pq shall be 0)
                    qt[n][i] = fgetc(fp);
                }
            }

            break;

        case 0xdd:
            printf("---------------------------------\n");
            JMARKER(c, "DRI"); // Restart Interval Definition
            // Lr : restart interval segment length (16b)
            // - specifies the length of the paramenters in the DRI segment
            v = fgetc(fp);
            v = (v << 8) | fgetc(fp);
            printf("Lr %d\n", v);
            // Ri : restart interval (16b)
            // - specifies the number of MCU in the restart interval.
            v = fgetc(fp);
            v = (v << 8) | fgetc(fp);
            printf("Ri %d\n", v);
            break;

        case 0xe0: /* All these markers are ignored */
        case 0xe1:
        case 0xe2:
        case 0xe3:
        case 0xe4:
        case 0xe5:
        case 0xe6:
        case 0xe7:
        case 0xe8:
        case 0xe9:
        case 0xea:
        case 0xeb:
        case 0xec:
        case 0xed:
        case 0xee:
        case 0xef:
        case 0xf0:
        case 0xf1:
        case 0xf2:
        case 0xf3:
        case 0xf4:
        case 0xf5:
        case 0xf6:
        case 0xf7:
        case 0xf8:
        case 0xf9:
        case 0xfa:
        case 0xfb:
        case 0xfc:
        case 0xfd:
        case 0xfe:
            v = fgetc(fp);
            v = (v << 8) | fgetc(fp);
            v -= 2;
            for (i = 0; i < v; i++)
                fgetc(fp);
            break;

        default:
            printf("Unknown marker %x !\n", c);
            exit(1);
            break;
        }
    }

    /* Close file */
    fclose(fp);
    fclose(fpo); // close the ecs.bin file

    printf("Total RST %d\n", rst);
    printf("Total zeros %d\n", nm);

    /* Outputs the min values */
    fpo = fopen("min.dat", "w");
    for (i = 0; i < 64;)
    {
        v = min[i++] & 1;
        v <<= 2;
        v |= min[i++] & 3;
        v <<= 3;
        v |= min[i++] & 7;
        fprintf(fpo, "%x", v >> 2);
        v <<= 4;
        v |= min[i++] & 15;
        v <<= 5;
        v |= min[i++] & 31;
        v <<= 6;
        v |= min[i++] & 63;
        v <<= 7;
        v |= min[i++] & 127;
        v <<= 8;
        v |= min[i++] & 255;
        fprintf(fpo, "%08x", v);
        v = min[i++] & 255;
        v <<= 8;
        v |= min[i++] & 255;
        v <<= 8;
        v |= min[i++] & 255;
        v <<= 8;
        v |= min[i++] & 255;
        fprintf(fpo, "%08x", v);
        v = min[i++] & 255;
        v <<= 8;
        v |= min[i++] & 255;
        v <<= 8;
        v |= min[i++] & 255;
        v <<= 8;
        v |= min[i++] & 255;
        fprintf(fpo, "%08x\n", v);
    }
    fclose(fpo);

    /* Outputs the BASE mem values */
    fpo = fopen("base.dat", "w");
    for (i = 0; i < 64; i++)
        fprintf(fpo, "%03x\n", hea[i] & 511);
    fclose(fpo);

    /* Outputs the SYMB mem values */
    fpo = fopen("symb.dat", "w");
    for (i = 0; i < 336; i++)
        fprintf(fpo, "%02x\n", heb[i] & 255);
    fclose(fpo);

    /* Outputs the Huffman simulation mem values */
    fpo = fopen("hmem.sim", "w");
    for (i = 0; i < 4; i++)
        for (j = 0; j < 256; j++)
            if (hlen[i][j])
                fprintf(fpo, "%d %d %d %d\n", i, j, hcode[i][j], hlen[i][j]);
    fclose(fpo);

    /* Outputs the quantization table */
    fpo = fopen("qdtable.dat", "w");
    for (i = 0; i < 4; i++)
        for (j = 0; j < 64; j++)
            fprintf(fpo, "%04x\n", qt[i][j]);
    fclose(fpo);

    /* Outputs the encoder quantization table */
    //fpo=fopen("../jcem/qetable.dat","w");
    fpo = fopen("./qetable.dat", "w");
    for (i = 0; i < 4; i++)
        for (j = 0; j < 64; j++)
        {
            fprintf(fpo, "%04x\n", qlook[qt[i][j]]);
        }
    fclose(fpo);

    /* Outputs the quantization table for HP */
    fpo = fopen("qetable_hdr.dat", "w");
    for (i = 0; i < 4; i++)
        for (j = 0; j < 64; j++)
            fprintf(fpo, "%02x\n", qt[i][j]);
    fclose(fpo);

    /* Outputs the quantization table for HP */
    fpo = fopen("qdtable_hdr.dat", "w");
    for (i = 0; i < 4; i++)
        for (j = 0; j < 64; j++)
            fprintf(fpo, "%02x\n", qt[i][j]);
    fclose(fpo);

    /* Outputs th Huffman Encoder table */
    //fpo=fopen("./jcem/htable.dat","w");
    fpo = fopen("./htable.dat", "w");
    for (i = 0; i < 384; i++)
        fprintf(fpo, "%03x\n", huffenc[i]);
    fclose(fpo);
}
