// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"
#include "fft1024.h"

// Input space filled with deterministically generated samples.
COMPLEX dataInput[N];
COMPLEX dataResult[N];

// Initialise sinewave generator for input space.
short y[3] = { 0, 2500, 0 };
short z[3] = { 0, 4750, 0 };
short A = 32364;
short B = -29203;

// Generate sine samples.
short sinegen(void) // {{{
{
    y[0] = (((int) y[1] * (int) A) >> 14) - y[2];
    y[2] = y[1];
    y[1] = y[0];

    z[0] = (((int) z[1] * (int) B) >> 14) - z[2];
    z[2] = z[1];
    z[1] = z[0];

    return (y[0] + z[0] / 2);
} // }}}

// Put the sine sample in arrays.
void sinewaves(void) // {{{
{
    // Always initialise data exactly the same.
    y[0] = 0;
    y[1] = 2500;
    y[2] = 0;
    z[0] = 0;
    z[1] = 4750;
    z[2] = 0;

    for (int i = 0; i < N; i++)
    {
        sinegen(); // Not quite a dummy call!

        dataInput[i].real = sinegen() / 100;
        dataInput[i].imag = 0;
        dataResult[i].real = dataInput[i].real;
        dataResult[i].imag = 0;
    }

    return;
} // }}}

// Result space.
int dataMag[N];

extern void populate_w(void);
extern void fft1024_radix4(COMPLEX *X, COMPLEX *Y);

void main(void)
{

  // Populate the table of twiddle factors used in FFT.
  populate_w();

  // Zero-initialise result space (global).
  // approx 20k cycles
  for (int i = 0; i < N; i++) dataMag[i] = 0;

  // Generate sinewaves on dataInput.
  // Make some interesting data to perform the FFT on.
  sinewaves();

  // Dump memory contents to file.
  tb_dumpmem();

  // Simulation time: approx 66ms
  //  - iverilog takes a long time.
  // VCD filesize: approx 170MB
  print_str("fft...");
  tb_dumpon();
  fft1024_radix4(dataInput, dataResult);
  tb_dumpoff();
  print_str("Done\n");

  tb_pass();
}

