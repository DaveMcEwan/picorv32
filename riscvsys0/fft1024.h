#ifndef _FFT1024
#define _FFT1024

#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <assert.h>

#define N 1024
#define N_CLOG2 10

struct cmpx
{
    short int real; // real part
    short int imag; // imaginary part
};
typedef struct cmpx COMPLEX;

#endif // _FFT1024 sentinal guard

