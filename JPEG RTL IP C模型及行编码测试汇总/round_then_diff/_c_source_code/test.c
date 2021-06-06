#include <stdio.h>

int main()
{
    unsigned char i = 0;
    unsigned char j = 255;
    int outi;
    int outj;
    int pix = 255;
    for (pix = -255; pix <= 255; pix++)
    {

        i = (unsigned char)(((pix & (~1)) >> 1) + 127);
        printf("%d ", i);
    }
    // printf("%d", (-254) >> 1);
    // printf("%d", (254) >> 1);
    // int a = 163;
    // a &= -2;
    // printf("%d", a);
    // int x, j;
    // j >> 3;
    // printf("%d\n", (i - j) >> 2);
    // printf("%d\n", (j - i) >> 2);
    // printf("%d", out);

    // for (x = 0; x < 128; x += 64)
    // {
    //     for (j = 0; j < 64; j++)
    //     {
    //         printf("%d\n", 128 * 0 + x + j);
    //     }
    //     for (j = 0; j < 64; j++)
    //     {
    //         printf("%d\n", 128 * 1 + x + j);
    //     }
    //     for (j = 0; j < 64; j++)
    //     {
    //         printf("%d\n", 128 * 2 + x + j);
    //     }
    // }
}