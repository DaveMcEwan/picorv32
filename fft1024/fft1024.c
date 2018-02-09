#include "fft1024.h"

short d2s(double d) // {{{
{
    d *= 32768;

    if (d >= 32767.0) return 32767;
    if (d <= -32768.0) return -32768;
    return (short)d;
} // }}}

// quantised and scaled twiddle factors.
struct
{
    short sin; // 32767*sin(2*pi*n)
    short cos; // 32767*cos(2*pi*n)
} w[N];

void populate_w(void) // {{{
{
    double E = 6.283185307179586 / (double)N;
    for (int i = 0; i < N; i++)
    {
        w[i].sin = d2s(sin(i * E));
        w[i].cos = d2s(cos(i * E));
    }
} // }}}

// fft radix-4 function using Decimation In Frequency
void fft1024_radix4(COMPLEX * restrict X, COMPLEX * restrict Y) // {{{
{
    int tw_step = 1;

    // Stage loop, log4(N)-1 stages.
    for (int stage_pts = N; stage_pts > 4; stage_pts >>= 2) // {{{
    {
        int diff = stage_pts >> 2; // Difference between dragonfly legs.
        int tw1 = 0; // First group of each stage begins at tw idx 0.

        // Group loop
        for (int group = 0; group < diff; group++)
        {
            int tw2 = (tw1 * 2);
            int tw3 = (tw1 * 3);

            int cos1 = w[tw1].cos;
            int sin1 = w[tw1].sin;
            int cos2 = w[tw2].cos;
            int sin2 = w[tw2].sin;
            int cos3 = w[tw3].cos;
            int sin3 = w[tw3].sin;

            // Dragonfly loop
            for (int lower = group; lower < N; lower += stage_pts)
            {
                int idx0 = lower;
                int idx1 = lower + diff;
                int idx2 = lower + diff * 2;
                int idx3 = lower + diff * 3;

                int r0 = X[idx0].real;
                int r1 = X[idx1].real;
                int r2 = X[idx2].real;
                int r3 = X[idx3].real;

                int i0 = X[idx0].imag;
                int i1 = X[idx1].imag;
                int i2 = X[idx2].imag;
                int i3 = X[idx3].imag;

                // xa+yb-xc-yd
                // xa-xb+xc-xd
                // xa-yb-xc+yd
                // ya-xb-yc+xd
                // ya-yb+yc-yd
                // ya+xb-yc-xd
                int tmp0 = (r0 + i1 - r2 - i3) >> 1;
                int tmp1 = (r0 - r1 + r2 - r3) >> 1;
                int tmp2 = (r0 - i1 - r2 + i3) >> 1;
                int tmp3 = (i0 - r1 - i2 + r3) >> 1;
                int tmp4 = (i0 - i1 + i2 - i3) >> 1;
                int tmp5 = (i0 + r1 - i2 - r3) >> 1;

                // Eq(1)  xa'= xa+xb+xc+xd
                // Eq(2)  ya'= ya+yb+yc+yd
                // Eq(3)  xb'= (xa+yb-xc-yd)Cb + (ya-xb-yc+xd)Sb
                // Eq(6)  yb'= (ya+xb-yc+xd)Cb - (xa+yb-xc-yd)Sb
                // Eq(7)  xc'= (xa-xb+xc-xd)Cc + (ya-yb+yc-yd)Sc
                // Eq(8)  yc'= (ya-yb+yc-yd)Cc - (xa-xb+xc-xd)Sc
                // Eq(9)  xd'= (xa-yb-xc+yd)Cd + (ya+xb-yc-xd)Sd
                // Eq(10) yd'= (ya+xb-yc-xd)Cd - (xa-yb-xc+yd)Sd
                X[idx0].real = (short)((r0 + r1 + r2 + r3) >> 2);
                X[idx0].imag = (short)((i0 + i1 + i2 + i3) >> 2);
                X[idx1].real = (short)((tmp0 * cos1 + tmp3 * sin1) >> 16);
                X[idx1].imag = (short)((tmp3 * cos1 - tmp0 * sin1) >> 16);
                X[idx2].real = (short)((tmp1 * cos2 + tmp4 * sin2) >> 16);
                X[idx2].imag = (short)((tmp4 * cos2 - tmp1 * sin2) >> 16);
                X[idx3].real = (short)((tmp2 * cos3 + tmp5 * sin3) >> 16);
                X[idx3].imag = (short)((tmp5 * cos3 - tmp2 * sin3) >> 16);
            }

            tw1 += tw_step;
        }

        tw_step <<= 2; // tw1 increment between stages is 4x the last stage.
    } // }}} stage

    static const int const3  = 0x00030003;
    static const int constC  = 0x000C000C;
    static const int const30 = 0x00300030;

    int cos1 = w[0].cos;
    int sin1 = w[0].sin;

    // Final Dragonfly loop
    for (int lower = 0; lower < N; lower += 4) // {{{
    {
        int fwd0 = lower;
        int fwd1 = lower + 1;
        int fwd2 = lower + 2;
        int fwd3 = lower + 3;

        int fwd1_fwd0 = (fwd1 << 16) | fwd0;
        int fwd3_fwd2 = (fwd3 << 16) | fwd2;

        int rev1_rev0_a = (fwd1_fwd0 & const3) << 8;
        int rev1_rev0_b = (fwd1_fwd0 & constC) << 4;
        int rev1_rev0_c =  fwd1_fwd0 & const30;
        int rev1_rev0_d = (fwd1_fwd0 >> 4) & constC;
        int rev1_rev0  = ((fwd1_fwd0 >> 8) & const3)
                         | rev1_rev0_a
                         | rev1_rev0_b
                         | rev1_rev0_c
                         | rev1_rev0_d;
        int rev0  = rev1_rev0 & 0x3FF;
        int rev1  = rev1_rev0 >> 16;

        int rev3_rev2_a = (fwd3_fwd2 & const3) << 8;
        int rev3_rev2_b = (fwd3_fwd2 & constC) << 4;
        int rev3_rev2_c =  fwd3_fwd2 & const30;
        int rev3_rev2_d = (fwd3_fwd2 >> 4) & constC;
        int rev3_rev2  = ((fwd3_fwd2 >> 8) & const3)
                         | rev3_rev2_a
                         | rev3_rev2_b
                         | rev3_rev2_c
                         | rev3_rev2_d;
        int rev2  = rev3_rev2 & 0x3FF;
        int rev3  = rev3_rev2 >> 16;

        int r0 = X[fwd0].real;
        int r1 = X[fwd1].real;
        int r2 = X[fwd2].real;
        int r3 = X[fwd3].real;

        int i0 = X[fwd0].imag;
        int i1 = X[fwd1].imag;
        int i2 = X[fwd2].imag;
        int i3 = X[fwd3].imag;

        // xa+yb-xc-yd
        // xa-xb+xc-xd
        // xa-yb-xc+yd
        // ya-xb-yc+xd
        // ya-yb+yc-yd
        // ya+xb-yc-xd
        int tmp0 = (r0 + i1 - r2 - i3) >> 1;
        int tmp1 = (r0 - r1 + r2 - r3) >> 1;
        int tmp2 = (r0 - i1 - r2 + i3) >> 1;
        int tmp3 = (i0 - r1 - i2 + r3) >> 1;
        int tmp4 = (i0 - i1 + i2 - i3) >> 1;
        int tmp5 = (i0 + r1 - i2 - r3) >> 1;

        // Eq(1)  xa'= xa+xb+xc+xd
        // Eq(2)  ya'= ya+yb+yc+yd
        // Eq(3)  xb'= (xa+yb-xc-yd)Cb + (ya-xb-yc+xd)Sb
        // Eq(6)  yb'= (ya+xb-yc+xd)Cb - (xa+yb-xc-yd)Sb
        // Eq(7)  xc'= (xa-xb+xc-xd)Cc + (ya-yb+yc-yd)Sc
        // Eq(8)  yc'= (ya-yb+yc-yd)Cc - (xa-xb+xc-xd)Sc
        // Eq(9)  xd'= (xa-yb-xc+yd)Cd + (ya+xb-yc-xd)Sd
        // Eq(10) yd'= (ya+xb-yc-xd)Cd - (xa-yb-xc+yd)Sd
        Y[rev0].real = (short)((r0 + r1 + r2 + r3) >> 2);
        Y[rev0].imag = (short)((i0 + i1 + i2 + i3) >> 2);
        Y[rev1].real = (short)((tmp0 * cos1 + tmp3 * sin1) >> 16);
        Y[rev1].imag = (short)((tmp3 * cos1 - tmp0 * sin1) >> 16);
        Y[rev2].real = (short)((tmp1 * cos1 + tmp4 * sin1) >> 16);
        Y[rev2].imag = (short)((tmp4 * cos1 - tmp1 * sin1) >> 16);
        Y[rev3].real = (short)((tmp2 * cos1 + tmp5 * sin1) >> 16);
        Y[rev3].imag = (short)((tmp5 * cos1 - tmp2 * sin1) >> 16);
    } // }}}

    return;
} // }}}

