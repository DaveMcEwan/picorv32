`timescale 1 ns / 1 ps

`include "ff.svh"

`ifndef TIMEOUT_POW2
`define TIMEOUT_POW2 32
`endif

module riscvsys ( // {{{
  /*verilator tracing_off*/
  input logic i_clk,
  input logic i_rst,
  output logic dumpon
  /*verilator tracing_on*/
);
  always_comb dumpon = tb.dumpon;

  testbench tb (
    .i_clk,
    .i_rst
  );

  wire ev_lui           = tb.evmon.ev_lui;
  wire ev_auipc         = tb.evmon.ev_auipc;
  wire ev_jal           = tb.evmon.ev_jal;
  wire ev_jalr          = tb.evmon.ev_jalr;
  wire ev_beq           = tb.evmon.ev_beq;
  wire ev_bne           = tb.evmon.ev_bne;
  wire ev_blt           = tb.evmon.ev_blt;
  wire ev_bge           = tb.evmon.ev_bge;
  wire ev_bltu          = tb.evmon.ev_bltu;
  wire ev_bgeu          = tb.evmon.ev_bgeu;
  wire ev_lb            = tb.evmon.ev_lb;
  wire ev_lh            = tb.evmon.ev_lh;
  wire ev_lw            = tb.evmon.ev_lw;
  wire ev_lbu           = tb.evmon.ev_lbu;
  wire ev_lhu           = tb.evmon.ev_lhu;
  wire ev_sb            = tb.evmon.ev_sb;
  wire ev_sh            = tb.evmon.ev_sh;
  wire ev_sw            = tb.evmon.ev_sw;
  wire ev_addi          = tb.evmon.ev_addi;
  wire ev_slti          = tb.evmon.ev_slti;
  wire ev_sltiu         = tb.evmon.ev_sltiu;
  wire ev_xori          = tb.evmon.ev_xori;
  wire ev_ori           = tb.evmon.ev_ori;
  wire ev_andi          = tb.evmon.ev_andi;
  wire ev_slli          = tb.evmon.ev_slli;
  wire ev_srli          = tb.evmon.ev_srli;
  wire ev_srai          = tb.evmon.ev_srai;
  wire ev_add           = tb.evmon.ev_add;
  wire ev_sub           = tb.evmon.ev_sub;
  wire ev_sll           = tb.evmon.ev_sll;
  wire ev_slt           = tb.evmon.ev_slt;
  wire ev_sltu          = tb.evmon.ev_sltu;
  wire ev_xor           = tb.evmon.ev_xor;
  wire ev_srl           = tb.evmon.ev_srl;
  wire ev_sra           = tb.evmon.ev_sra;
  wire ev_or            = tb.evmon.ev_or;
  wire ev_and           = tb.evmon.ev_and;
  wire ev_rdcycle       = tb.evmon.ev_rdcycle;
  wire ev_rdcycleh      = tb.evmon.ev_rdcycleh;
  wire ev_rdinstr       = tb.evmon.ev_rdinstr;
  wire ev_rdinstrh      = tb.evmon.ev_rdinstrh;
  wire ev_ecall_ebreak  = tb.evmon.ev_ecall_ebreak;
  wire ev_getq          = tb.evmon.ev_getq;
  wire ev_setq          = tb.evmon.ev_setq;
  wire ev_retirq        = tb.evmon.ev_retirq;
  wire ev_maskirq       = tb.evmon.ev_maskirq;
  wire ev_waitirq       = tb.evmon.ev_waitirq;
  wire ev_timer         = tb.evmon.ev_timer;
  wire ev_trap          = tb.evmon.ev_trap;

endmodule // }}} riscvsys

module testbench ( // {{{
  input logic i_clk,
  input logic i_rst
);

  `ff_nocg_srst(bit [63:0], timetrack, i_clk, 1'b0, 'd0)
  always_comb timetrack_d = timetrack_q + 1;
  always @* begin
    if (timetrack_q[`TIMEOUT_POW2]) begin
      $display("TIMEOUT");
      $finish();
    end
  end

  reg [31:0] irq;
  always @* begin
    irq = 0;
    irq[4] = timetrack_q == ((1 << 12) - 1); // irq after 4k cycles
    //irq[5] = &timetrack_q[15:0]; // irq every 64k cycles
  end


  // PRNG for stalling memory access.
  reg [31:0] x32_q = 314159265;
  reg [31:0] x32_d;
  always @(posedge i_clk)
    if (!i_rst) begin
      x32_d = x32_q;
      x32_d = x32_d ^ (x32_d << 13);
      x32_d = x32_d ^ (x32_d >> 17);
      x32_d = x32_d ^ (x32_d << 5);
      x32_q <= x32_d;
    end

  wire trap;
  wire mem_valid;
  wire mem_instr;
  wire mem_ready;
  wire [31:0] mem_addr;
  wire [31:0] mem_wdata;
  wire [3:0] mem_wstrb;
  wire [31:0] mem_rdata;

  picorv32 #(
    .COMPRESSED_ISA(1),
    .ENABLE_IRQ(1),
    .ENABLE_MUL(1),
    .ENABLE_DIV(1)
  ) uut (
    .clk          (i_clk),
    .resetn       (!i_rst),
    .trap         (trap),

    .mem_valid    (mem_valid  ),
    .mem_instr    (mem_instr  ),
    .mem_ready    (mem_ready  ),
    .mem_addr     (mem_addr   ),
    .mem_wdata    (mem_wdata  ),
    .mem_wstrb    (mem_wstrb  ),
    .mem_rdata    (mem_rdata  ),

    // Look-Ahead Interface
    .mem_la_read  (),
    .mem_la_write (),
    .mem_la_addr  (),
    .mem_la_wdata (),
    .mem_la_wstrb (),

    // IRQ Interface
    .irq          (irq),
    .eoi          (),

    // Trace Interface
    .trace_valid  (),
    .trace_data   ()
  );

  // {{{ memory
  reg dumpon;
  initial dumpon = 1'b0;

  reg [31:0] memory [0:64*1024/4-1] /* verilator public */;
  initial $readmemh("test.hex", memory);

  //assign mem_ready = x32_q[0] && mem_valid;
  assign mem_ready = 1'b1;

  assign mem_rdata = memory[mem_addr >> 2];

  always @(posedge i_clk)
    if (|mem_wstrb && mem_valid && mem_ready) begin
      if (mem_addr < 64*1024) begin
        if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
        if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
        if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
        if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
      end

      else if (mem_addr == 32'h1000_0000) begin
        // print character
        $write("%c", mem_wdata[ 7: 0]);
      end

      else if (mem_addr == 32'h2000_0000) begin
        // {{{ tb control

        if (mem_wdata == 32'hacce5500) begin
          $display("PASS");
          $finish;
        end

        else if (mem_wdata == 32'hacce5501) begin
          $display("FAIL");
          $finish;
        end

        else if (mem_wdata == 32'hacce5502) begin
          $display("dumpoff");
          dumpon = 1'b0;
          //$dumpoff();
        end
        else if (mem_wdata == 32'hacce5503) begin
          $display("dumpon");
          dumpon = 1'b1;
          //$dumpon();
        end
        else if (mem_wdata == 32'hacce5504) begin
          integer fd;
          $display("dump memory.hex");
          fd = $fopen("memory.hex", "w");
          for (int i = 0; i < 64*1024/4; i=i+1)
            $fwrite(fd, "%08x\n", memory[i]);
          $fclose(fd);
        end
        //else if (mem_wdata == 32'hacce5505)
        //  $readmemh("memory.hex", memory);

        $display("timetrack=%d", timetrack_q);

        // }}} tb control
      end

      else begin
        $display("OUT-OF-BOUNDS MEMORY WRITE TO %08x", mem_addr);
        $finish;
      end
    end
  // }}} memory

  riscvsys_evmon evmon ( // {{{
    .i_instr_lui          (uut.instr_lui         ),
    .i_instr_auipc        (uut.instr_auipc       ),
    .i_instr_jal          (uut.instr_jal         ),
    .i_instr_jalr         (uut.instr_jalr        ),
    .i_instr_beq          (uut.instr_beq         ),
    .i_instr_bne          (uut.instr_bne         ),
    .i_instr_blt          (uut.instr_blt         ),
    .i_instr_bge          (uut.instr_bge         ),
    .i_instr_bltu         (uut.instr_bltu        ),
    .i_instr_bgeu         (uut.instr_bgeu        ),
    .i_instr_lb           (uut.instr_lb          ),
    .i_instr_lh           (uut.instr_lh          ),
    .i_instr_lw           (uut.instr_lw          ),
    .i_instr_lbu          (uut.instr_lbu         ),
    .i_instr_lhu          (uut.instr_lhu         ),
    .i_instr_sb           (uut.instr_sb          ),
    .i_instr_sh           (uut.instr_sh          ),
    .i_instr_sw           (uut.instr_sw          ),
    .i_instr_addi         (uut.instr_addi        ),
    .i_instr_slti         (uut.instr_slti        ),
    .i_instr_sltiu        (uut.instr_sltiu       ),
    .i_instr_xori         (uut.instr_xori        ),
    .i_instr_ori          (uut.instr_ori         ),
    .i_instr_andi         (uut.instr_andi        ),
    .i_instr_slli         (uut.instr_slli        ),
    .i_instr_srli         (uut.instr_srli        ),
    .i_instr_srai         (uut.instr_srai        ),
    .i_instr_add          (uut.instr_add         ),
    .i_instr_sub          (uut.instr_sub         ),
    .i_instr_sll          (uut.instr_sll         ),
    .i_instr_slt          (uut.instr_slt         ),
    .i_instr_sltu         (uut.instr_sltu        ),
    .i_instr_xor          (uut.instr_xor         ),
    .i_instr_srl          (uut.instr_srl         ),
    .i_instr_sra          (uut.instr_sra         ),
    .i_instr_or           (uut.instr_or          ),
    .i_instr_and          (uut.instr_and         ),
    .i_instr_rdcycle      (uut.instr_rdcycle     ),
    .i_instr_rdcycleh     (uut.instr_rdcycleh    ),
    .i_instr_rdinstr      (uut.instr_rdinstr     ),
    .i_instr_rdinstrh     (uut.instr_rdinstrh    ),
    .i_instr_ecall_ebreak (uut.instr_ecall_ebreak),
    .i_instr_getq         (uut.instr_getq        ),
    .i_instr_setq         (uut.instr_setq        ),
    .i_instr_retirq       (uut.instr_retirq      ),
    .i_instr_maskirq      (uut.instr_maskirq     ),
    .i_instr_waitirq      (uut.instr_waitirq     ),
    .i_instr_timer        (uut.instr_timer       ),
    .i_instr_trap         (uut.instr_trap        ),
    .i_pc       (uut.reg_pc),
    .i_next_pc  (uut.reg_next_pc),
    .i_dbg_next (uut.dbg_next)
  ); // }}}

endmodule // }}} testbench
