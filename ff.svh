`ifndef FF_SVH_
`define FF_SVH_

/** Flop macros
 * These are to make the intent of flop inferences easy to determine.
 * Naming convention:
 *  - ff    Infers a collection of flip flops.
 *  - latch Infers a collection of latches.
 *  - cg    Infers a clockgate, often a good idea for power.
 *  - nocg  Does not infer a clockgate.
 *  - arst  Infers asynchronous active-high reset.
 *  - arstn Infers asynchronous active-low reset.
 *  - srst  Infers synchronous active-high reset.
 *  - srstn Infers synchronous active-low reset.
 *  - norst Infers no reset, often a good idea for area.
 *  - upk   Functionally equivalent macros for unpacked vectors.
 *
 * Recommendations:
 *  - Use unpacked arrays where elements don't need to grouped together.
 *    - Keeps code small and tidy.
 *    - Lets synth tools ungroup logic.
 *  - Use clockgates where possible.
 *    - If the synth tool decides it isn't worth it for power then it can
 *      implement the clockgate as a recirculating mux, but it should have the
 *      choice, particularly if the number of flops is parameterized.
 *  - Prefer synchronous resets (srst) instead of asynchronous (arst).
 *    - This prevents huge global asynch resets acting as antennas with lots of
 *      unintended consequences on large designs.
 *  - Prefer non-reset (norst).
 *    - Non-reset flops are smaller on ASIC designs.
 *    - Reset network will be smaller, so less like an antenna.
 *    - Especially useful for datapath where reset value is meaningless.
 *
 * TL;DR:
 *  - ff_cg_norst[_upk]     Datapath
 *  - ff_[no]cg_srst[_upk]  Control path
 */

// {{{ `ff_cg_arst (logic [9:0], foo, i_clk, i_cg, i_rst, '0)
`define ff_cg_arst(t, n, clk, cg, rst, rstval) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk or posedge rst) \
        if (rst)     n``_q <= rstval; \
        else if (cg) n``_q <= n``_d; \
        else         n``_q <= n``_q;
// }}}
// {{{ `ff_cg_arstn (logic [9:0], foo, i_clk, i_cg, i_rstn, '0)
`define ff_cg_arstn(t, n, clk, cg, rstn, rstval) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk or negedge rstn) \
        if (!rstn)   n``_q <= rstval; \
        else if (cg) n``_q <= n``_d; \
        else         n``_q <= n``_q;
// }}}
// {{{ `ff_nocg_arst (logic [9:0], foo, i_clk, i_rst, '0)
`define ff_nocg_arst(t, n, clk, rst, rstval) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk or posedge rst) \
        if (rst) n``_q <= rstval; \
        else     n``_q <= n``_d;
// }}}
// {{{ `ff_nocg_arstn (logic [9:0], foo, i_clk, i_rstn, '0)
`define ff_nocg_arstn(t, n, clk, rstn, rstval) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk or negedge rstn) \
        if (!rstn) n``_q <= rstval; \
        else       n``_q <= n``_d;
// }}}
// {{{ `ff_cg_srst (logic [9:0], foo, i_clk, i_cg, i_rst, '0)
`define ff_cg_srst(t, n, clk, cg, rst, rstval) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk) \
        if (rst)     n``_q <= rstval; \
        else if (cg) n``_q <= n``_d; \
        else         n``_q <= n``_q;
// }}}
// {{{ `ff_cg_srstn (logic [9:0], foo, i_clk, i_cg, i_rstn, '0)
`define ff_cg_srstn(t, n, clk, cg, rstn, rstval) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk) \
        if (!rstn)   n``_q <= rstval; \
        else if (cg) n``_q <= n``_d; \
        else         n``_q <= n``_q;
// }}}
// {{{ `ff_nocg_srst (logic [9:0], foo, i_clk, i_rst, '0)
`define ff_nocg_srst(t, n, clk, rst, rstval) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk) \
        if (rst) n``_q <= rstval; \
        else     n``_q <= n``_d;
// }}}
// {{{ `ff_nocg_srstn (logic [9:0], foo, i_clk, i_rstn, '0)
`define ff_nocg_srstn(t, n, clk, rstn, rstval) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk) \
        if (!rstn) n``_q <= rstval; \
        else       n``_q <= n``_d;
// }}}
// {{{ `ff_cg_norst (logic [9:0], foo, i_clk, i_cg)
`define ff_cg_norst(t, n, clk, cg) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk) \
        if (cg) n``_q <= n``_d; \
        else    n``_q <= n``_q;
// }}}
// {{{ `ff_nocg_norst (logic [9:0], foo, i_clk)
`define ff_nocg_norst(t, n, clk) \
    t n``_d, n``_q; \
    always_ff @ (posedge clk) \
        n``_q <= n``_d;
// }}}
// {{{ `latch (logic [9:0], foo, enable)
`define latch(t, n, en) \
    t n``_d, n``_q; \
    always_latch if (en) \
        n``_q <= n``_d;
// }}}

// Now the same macros but including parameter for unpacked vectors.

// {{{ `ff_cg_arst_upk (logic [9:0], foo, [3][4], i_clk, i_cg, i_rst, '0)
`define ff_cg_arst_upk(t, n, u, clk, cg, rst, rstval) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk or posedge rst) \
        if (rst)     n``_q <= rstval; \
        else if (cg) n``_q <= n``_d; \
        else         n``_q <= n``_q;
// }}}
// {{{ `ff_cg_arstn_upk (logic [9:0], foo, [3][4], i_clk, i_cg, i_rstn, '0)
`define ff_cg_arstn_upk(t, n, u, clk, cg, rstn, rstval) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk or negedge rstn) \
        if (!rstn)   n``_q <= rstval; \
        else if (cg) n``_q <= n``_d; \
        else         n``_q <= n``_q;
// }}}
// {{{ `ff_nocg_arst_upk (logic [9:0], foo, [3][4], i_clk, i_rst, '0)
`define ff_nocg_arst_upk(t, n, u, clk, rst, rstval) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk or posedge rst) \
        if (rst) n``_q <= rstval; \
        else     n``_q <= n``_d;
// }}}
// {{{ `ff_nocg_arstn_upk (logic [9:0], foo, [3][4], i_clk, i_rstn, '0)
`define ff_nocg_arstn_upk(t, n, u, clk, rstn, rstval) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk or negedge rstn) \
        if (!rstn) n``_q <= rstval; \
        else       n``_q <= n``_d;
// }}}
// {{{ `ff_cg_srst_upk (logic [9:0], foo, [3][4], i_clk, i_cg, i_rst, '0)
`define ff_cg_srst_upk(t, n, u, clk, cg, rst, rstval) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk) \
        if (rst)     n``_q <= rstval; \
        else if (cg) n``_q <= n``_d; \
        else         n``_q <= n``_q;
// }}}
// {{{ `ff_cg_srstn_upk (logic [9:0], foo, [3][4], i_clk, i_cg, i_rstn, '0)
`define ff_cg_srstn_upk(t, n, u, clk, cg, rstn, rstval) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk) \
        if (!rstn)   n``_q <= rstval; \
        else if (cg) n``_q <= n``_d; \
        else         n``_q <= n``_q;
// }}}
// {{{ `ff_nocg_srst_upk (logic [9:0], foo, [3][4], i_clk, i_rst, '0)
`define ff_nocg_srst_upk(t, n, u, clk, rst, rstval) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk) \
        if (rst) n``_q <= rstval; \
        else     n``_q <= n``_d;
// }}}
// {{{ `ff_nocg_srstn_upk (logic [9:0], foo, [3][4], i_clk, i_rstn, '0)
`define ff_nocg_srstn_upk(t, n, u, clk, rstn, rstval) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk) \
        if (!rstn) n``_q <= rstval; \
        else       n``_q <= n``_d;
// }}}
// {{{ `ff_cg_norst_upk (logic [9:0], foo, [3][4], i_clk, i_cg)
`define ff_cg_norst_upk(t, n, u, clk, cg) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk) \
        if (cg) n``_q <= n``_d; \
        else    n``_q <= n``_q;
// }}}
// {{{ `ff_nocg_norst_upk (logic [9:0], foo, [3][4], i_clk)
`define ff_nocg_norst_upk(t, n, u, clk) \
    t n``_d u; \
    t n``_q u; \
    always_ff @ (posedge clk) \
        n``_q <= n``_d;
// }}}
// {{{ `latch_upk (logic [9:0], foo, [3][4], enable)
`define latch_upk(t, n, u, en) \
    t n``_d u; \
    t n``_q u; \
    always_latch if (en) \
        n``_q <= n``_d;
// }}}

`endif
