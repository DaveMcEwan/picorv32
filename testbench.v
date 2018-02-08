// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

`timescale 1 ns / 1 ps

`ifndef VERILATOR
module testbench #(
  parameter AXI_TEST = 0,
  parameter VERBOSE = 0
);
  reg clk = 1;
  reg resetn = 0;
  wire trap;

  always #5 clk = ~clk;

  initial begin
    repeat (100) @(posedge clk);
    resetn <= 1;
  end

  integer dumplevel;
  initial begin
    if ($test$plusargs("vcd")) begin
      if (!$value$plusargs("dumplevel=%d", dumplevel))
        dumplevel = 0;
      if ($test$plusargs("eva")) begin
        $dumpfile("eva.vcd");
        $dumpvars(dumplevel, evmon);
        $dumpoff();
      end else
        $dumpfile("testbench.vcd");
        $dumpvars(dumplevel, testbench);
    end
    repeat (1000000000) @(posedge clk);
    $display("TIMEOUT");
    $finish;
  end

  wire trace_valid;
  wire [35:0] trace_data;
  integer trace_file;

  initial begin
    if ($test$plusargs("trace")) begin
      trace_file = $fopen("testbench.trace", "w");
      repeat (10) @(posedge clk);
      while (!trap) begin
        @(posedge clk);
        if (trace_valid)
          $fwrite(trace_file, "%x\n", trace_data);
      end
      $fclose(trace_file);
      $display("Finished writing testbench.trace.");
    end
  end

  picorv32_wrapper #(
    .AXI_TEST (AXI_TEST),
    .VERBOSE  (VERBOSE)
  ) top (
    .clk(clk),
    .resetn(resetn),
    .trap(trap),
    .trace_valid(trace_valid),
    .trace_data(trace_data)
  );

  riscvsys_evmon evmon ( // {{{
    .i_instr_lui          (top.uut.picorv32_core.instr_lui         ),
    .i_instr_auipc        (top.uut.picorv32_core.instr_auipc       ),
    .i_instr_jal          (top.uut.picorv32_core.instr_jal         ),
    .i_instr_jalr         (top.uut.picorv32_core.instr_jalr        ),
    .i_instr_beq          (top.uut.picorv32_core.instr_beq         ),
    .i_instr_bne          (top.uut.picorv32_core.instr_bne         ),
    .i_instr_blt          (top.uut.picorv32_core.instr_blt         ),
    .i_instr_bge          (top.uut.picorv32_core.instr_bge         ),
    .i_instr_bltu         (top.uut.picorv32_core.instr_bltu        ),
    .i_instr_bgeu         (top.uut.picorv32_core.instr_bgeu        ),
    .i_instr_lb           (top.uut.picorv32_core.instr_lb          ),
    .i_instr_lh           (top.uut.picorv32_core.instr_lh          ),
    .i_instr_lw           (top.uut.picorv32_core.instr_lw          ),
    .i_instr_lbu          (top.uut.picorv32_core.instr_lbu         ),
    .i_instr_lhu          (top.uut.picorv32_core.instr_lhu         ),
    .i_instr_sb           (top.uut.picorv32_core.instr_sb          ),
    .i_instr_sh           (top.uut.picorv32_core.instr_sh          ),
    .i_instr_sw           (top.uut.picorv32_core.instr_sw          ),
    .i_instr_addi         (top.uut.picorv32_core.instr_addi        ),
    .i_instr_slti         (top.uut.picorv32_core.instr_slti        ),
    .i_instr_sltiu        (top.uut.picorv32_core.instr_sltiu       ),
    .i_instr_xori         (top.uut.picorv32_core.instr_xori        ),
    .i_instr_ori          (top.uut.picorv32_core.instr_ori         ),
    .i_instr_andi         (top.uut.picorv32_core.instr_andi        ),
    .i_instr_slli         (top.uut.picorv32_core.instr_slli        ),
    .i_instr_srli         (top.uut.picorv32_core.instr_srli        ),
    .i_instr_srai         (top.uut.picorv32_core.instr_srai        ),
    .i_instr_add          (top.uut.picorv32_core.instr_add         ),
    .i_instr_sub          (top.uut.picorv32_core.instr_sub         ),
    .i_instr_sll          (top.uut.picorv32_core.instr_sll         ),
    .i_instr_slt          (top.uut.picorv32_core.instr_slt         ),
    .i_instr_sltu         (top.uut.picorv32_core.instr_sltu        ),
    .i_instr_xor          (top.uut.picorv32_core.instr_xor         ),
    .i_instr_srl          (top.uut.picorv32_core.instr_srl         ),
    .i_instr_sra          (top.uut.picorv32_core.instr_sra         ),
    .i_instr_or           (top.uut.picorv32_core.instr_or          ),
    .i_instr_and          (top.uut.picorv32_core.instr_and         ),
    .i_instr_rdcycle      (top.uut.picorv32_core.instr_rdcycle     ),
    .i_instr_rdcycleh     (top.uut.picorv32_core.instr_rdcycleh    ),
    .i_instr_rdinstr      (top.uut.picorv32_core.instr_rdinstr     ),
    .i_instr_rdinstrh     (top.uut.picorv32_core.instr_rdinstrh    ),
    .i_instr_ecall_ebreak (top.uut.picorv32_core.instr_ecall_ebreak),
    .i_instr_getq         (top.uut.picorv32_core.instr_getq        ),
    .i_instr_setq         (top.uut.picorv32_core.instr_setq        ),
    .i_instr_retirq       (top.uut.picorv32_core.instr_retirq      ),
    .i_instr_maskirq      (top.uut.picorv32_core.instr_maskirq     ),
    .i_instr_waitirq      (top.uut.picorv32_core.instr_waitirq     ),
    .i_instr_timer        (top.uut.picorv32_core.instr_timer       ),
    .i_instr_trap         (top.uut.picorv32_core.instr_trap        ),
    .i_pc       (top.uut.picorv32_core.reg_pc),
    .i_next_pc  (top.uut.picorv32_core.reg_next_pc),
    .i_dbg_next (top.uut.picorv32_core.dbg_next)
  ); // }}}

endmodule
`endif

module picorv32_wrapper #(
  parameter AXI_TEST = 0,
  parameter VERBOSE = 0
) (
  input clk,
  input resetn,
  output trap,
  output trace_valid,
  output [35:0] trace_data
);
  wire tests_passed;
  reg [31:0] irq;

  always @* begin
    irq = 0;
    irq[4] = uut.picorv32_core.count_cycle == ((1 << 12) - 1); // irq after 4k cycles
    //irq[5] = &uut.picorv32_core.count_cycle[15:0]; // irq every 64k cycles
  end

  wire        mem_axi_awvalid;
  wire        mem_axi_awready;
  wire [31:0] mem_axi_awaddr;
  wire [ 2:0] mem_axi_awprot;

  wire        mem_axi_wvalid;
  wire        mem_axi_wready;
  wire [31:0] mem_axi_wdata;
  wire [ 3:0] mem_axi_wstrb;

  wire        mem_axi_bvalid;
  wire        mem_axi_bready;

  wire        mem_axi_arvalid;
  wire        mem_axi_arready;
  wire [31:0] mem_axi_araddr;
  wire [ 2:0] mem_axi_arprot;

  wire        mem_axi_rvalid;
  wire        mem_axi_rready;
  wire [31:0] mem_axi_rdata;

  axi4_memory #(
    .AXI_TEST (AXI_TEST),
    .VERBOSE  (VERBOSE)
  ) mem (
    .clk             (clk             ),
    .mem_axi_awvalid (mem_axi_awvalid ),
    .mem_axi_awready (mem_axi_awready ),
    .mem_axi_awaddr  (mem_axi_awaddr  ),
    .mem_axi_awprot  (mem_axi_awprot  ),

    .mem_axi_wvalid  (mem_axi_wvalid  ),
    .mem_axi_wready  (mem_axi_wready  ),
    .mem_axi_wdata   (mem_axi_wdata   ),
    .mem_axi_wstrb   (mem_axi_wstrb   ),

    .mem_axi_bvalid  (mem_axi_bvalid  ),
    .mem_axi_bready  (mem_axi_bready  ),

    .mem_axi_arvalid (mem_axi_arvalid ),
    .mem_axi_arready (mem_axi_arready ),
    .mem_axi_araddr  (mem_axi_araddr  ),
    .mem_axi_arprot  (mem_axi_arprot  ),

    .mem_axi_rvalid  (mem_axi_rvalid  ),
    .mem_axi_rready  (mem_axi_rready  ),
    .mem_axi_rdata   (mem_axi_rdata   ),

    .tests_passed    (tests_passed    )
  );

`ifdef RISCV_FORMAL
  wire        rvfi_valid;
  wire [63:0] rvfi_order;
  wire [31:0] rvfi_insn;
  wire        rvfi_trap;
  wire        rvfi_halt;
  wire        rvfi_intr;
  wire [4:0]  rvfi_rs1_addr;
  wire [4:0]  rvfi_rs2_addr;
  wire [31:0] rvfi_rs1_rdata;
  wire [31:0] rvfi_rs2_rdata;
  wire [4:0]  rvfi_rd_addr;
  wire [31:0] rvfi_rd_wdata;
  wire [31:0] rvfi_pc_rdata;
  wire [31:0] rvfi_pc_wdata;
  wire [31:0] rvfi_mem_addr;
  wire [3:0]  rvfi_mem_rmask;
  wire [3:0]  rvfi_mem_wmask;
  wire [31:0] rvfi_mem_rdata;
  wire [31:0] rvfi_mem_wdata;
`endif

  picorv32_axi #(
`ifndef SYNTH_TEST
`ifdef SP_TEST
    .ENABLE_REGS_DUALPORT(0),
`endif
`ifdef COMPRESSED_ISA
    .COMPRESSED_ISA(1),
`endif
    .ENABLE_MUL(1),
    .ENABLE_DIV(1),
    .ENABLE_IRQ(1),
    .ENABLE_TRACE(1)
`endif
  ) uut (
    .clk            (clk            ),
    .resetn         (resetn         ),
    .trap           (trap           ),
    .mem_axi_awvalid(mem_axi_awvalid),
    .mem_axi_awready(mem_axi_awready),
    .mem_axi_awaddr (mem_axi_awaddr ),
    .mem_axi_awprot (mem_axi_awprot ),
    .mem_axi_wvalid (mem_axi_wvalid ),
    .mem_axi_wready (mem_axi_wready ),
    .mem_axi_wdata  (mem_axi_wdata  ),
    .mem_axi_wstrb  (mem_axi_wstrb  ),
    .mem_axi_bvalid (mem_axi_bvalid ),
    .mem_axi_bready (mem_axi_bready ),
    .mem_axi_arvalid(mem_axi_arvalid),
    .mem_axi_arready(mem_axi_arready),
    .mem_axi_araddr (mem_axi_araddr ),
    .mem_axi_arprot (mem_axi_arprot ),
    .mem_axi_rvalid (mem_axi_rvalid ),
    .mem_axi_rready (mem_axi_rready ),
    .mem_axi_rdata  (mem_axi_rdata  ),
    .irq            (irq            ),
`ifdef RISCV_FORMAL
    .rvfi_valid     (rvfi_valid     ),
    .rvfi_order     (rvfi_order     ),
    .rvfi_insn      (rvfi_insn      ),
    .rvfi_trap      (rvfi_trap      ),
    .rvfi_halt      (rvfi_halt      ),
    .rvfi_intr      (rvfi_intr      ),
    .rvfi_rs1_addr  (rvfi_rs1_addr  ),
    .rvfi_rs2_addr  (rvfi_rs2_addr  ),
    .rvfi_rs1_rdata (rvfi_rs1_rdata ),
    .rvfi_rs2_rdata (rvfi_rs2_rdata ),
    .rvfi_rd_addr   (rvfi_rd_addr   ),
    .rvfi_rd_wdata  (rvfi_rd_wdata  ),
    .rvfi_pc_rdata  (rvfi_pc_rdata  ),
    .rvfi_pc_wdata  (rvfi_pc_wdata  ),
    .rvfi_mem_addr  (rvfi_mem_addr  ),
    .rvfi_mem_rmask (rvfi_mem_rmask ),
    .rvfi_mem_wmask (rvfi_mem_wmask ),
    .rvfi_mem_rdata (rvfi_mem_rdata ),
    .rvfi_mem_wdata (rvfi_mem_wdata ),
`endif
    .trace_valid    (trace_valid    ),
    .trace_data     (trace_data     )
  );

`ifdef RISCV_FORMAL
  picorv32_rvfimon rvfi_monitor (
    .clock          (clk           ),
    .reset          (!resetn       ),
    .rvfi_valid     (rvfi_valid    ),
    .rvfi_order     (rvfi_order    ),
    .rvfi_insn      (rvfi_insn     ),
    .rvfi_trap      (rvfi_trap     ),
    .rvfi_halt      (rvfi_halt     ),
    .rvfi_intr      (rvfi_intr     ),
    .rvfi_rs1_addr  (rvfi_rs1_addr ),
    .rvfi_rs2_addr  (rvfi_rs2_addr ),
    .rvfi_rs1_rdata (rvfi_rs1_rdata),
    .rvfi_rs2_rdata (rvfi_rs2_rdata),
    .rvfi_rd_addr   (rvfi_rd_addr  ),
    .rvfi_rd_wdata  (rvfi_rd_wdata ),
    .rvfi_pc_rdata  (rvfi_pc_rdata ),
    .rvfi_pc_wdata  (rvfi_pc_wdata ),
    .rvfi_mem_addr  (rvfi_mem_addr ),
    .rvfi_mem_rmask (rvfi_mem_rmask),
    .rvfi_mem_wmask (rvfi_mem_wmask),
    .rvfi_mem_rdata (rvfi_mem_rdata),
    .rvfi_mem_wdata (rvfi_mem_wdata)
  );
`endif

  reg [1023:0] firmware_file;
  initial begin
    if (!$value$plusargs("firmware=%s", firmware_file))
      firmware_file = "test.hex";
    $readmemh(firmware_file, mem.memory);
  end

  integer cycle_counter;
  always @(posedge clk) begin
    cycle_counter <= resetn ? cycle_counter + 1 : 0;
    if (resetn && trap) begin
`ifndef VERILATOR
      repeat (10) @(posedge clk);
`endif
      $display("TRAP after %1d clock cycles", cycle_counter);
      if (tests_passed) begin
        $display("ALL TESTS PASSED.");
        $finish;
      end else begin
        $display("ERROR!");
        if ($test$plusargs("noerror"))
          $finish;
        $stop;
      end
    end
  end
endmodule

module axi4_memory #(
  parameter AXI_TEST = 0,
  parameter VERBOSE = 0
) (
  input             clk,
  input             mem_axi_awvalid,
  output reg        mem_axi_awready = 0,
  input [31:0]      mem_axi_awaddr,
  input [ 2:0]      mem_axi_awprot,

  input            mem_axi_wvalid,
  output reg       mem_axi_wready = 0,
  input [31:0]     mem_axi_wdata,
  input [ 3:0]     mem_axi_wstrb,

  output reg       mem_axi_bvalid = 0,
  input            mem_axi_bready,

  input            mem_axi_arvalid,
  output reg       mem_axi_arready = 0,
  input [31:0]     mem_axi_araddr,
  input [ 2:0]     mem_axi_arprot,

  output reg        mem_axi_rvalid = 0,
  input             mem_axi_rready,
  output reg [31:0] mem_axi_rdata,

  output reg tests_passed
);
  reg [31:0]   memory [0:64*1024/4-1] /* verilator public */;
  reg verbose;
  initial verbose = $test$plusargs("verbose") || VERBOSE;

  reg axi_test;
  initial axi_test = $test$plusargs("axi_test") || AXI_TEST;

  initial tests_passed = 0;

  reg [63:0] xorshift64_state = 64'd88172645463325252;

  task xorshift64_next;
    begin
      // see page 4 of Marsaglia, George (July 2003). "Xorshift RNGs". Journal of Statistical Software 8 (14).
      xorshift64_state = xorshift64_state ^ (xorshift64_state << 13);
      xorshift64_state = xorshift64_state ^ (xorshift64_state >>  7);
      xorshift64_state = xorshift64_state ^ (xorshift64_state << 17);
    end
  endtask

  reg [2:0] fast_axi_transaction = ~0;
  reg [4:0] async_axi_transaction = ~0;
  reg [4:0] delay_axi_transaction = 0;

  always @(posedge clk) begin
    if (axi_test) begin
        xorshift64_next;
        {fast_axi_transaction, async_axi_transaction, delay_axi_transaction} <= xorshift64_state;
    end
  end

  reg latched_raddr_en = 0;
  reg latched_waddr_en = 0;
  reg latched_wdata_en = 0;

  reg fast_raddr = 0;
  reg fast_waddr = 0;
  reg fast_wdata = 0;

  reg [31:0] latched_raddr;
  reg [31:0] latched_waddr;
  reg [31:0] latched_wdata;
  reg [ 3:0] latched_wstrb;
  reg        latched_rinsn;

  task handle_axi_arvalid; begin
    mem_axi_arready <= 1;
    latched_raddr = mem_axi_araddr;
    latched_rinsn = mem_axi_arprot[2];
    latched_raddr_en = 1;
    fast_raddr <= 1;
  end endtask

  task handle_axi_awvalid; begin
    mem_axi_awready <= 1;
    latched_waddr = mem_axi_awaddr;
    latched_waddr_en = 1;
    fast_waddr <= 1;
  end endtask

  task handle_axi_wvalid; begin
    mem_axi_wready <= 1;
    latched_wdata = mem_axi_wdata;
    latched_wstrb = mem_axi_wstrb;
    latched_wdata_en = 1;
    fast_wdata <= 1;
  end endtask

  task handle_axi_rvalid; begin
    if (verbose)
      $display("RD: ADDR=%08x DATA=%08x%s", latched_raddr, memory[latched_raddr >> 2], latched_rinsn ? " INSN" : "");
    if (latched_raddr < 64*1024) begin
      mem_axi_rdata <= memory[latched_raddr >> 2];
      mem_axi_rvalid <= 1;
      latched_raddr_en = 0;
    end else begin
      $display("OUT-OF-BOUNDS MEMORY READ FROM %08x", latched_raddr);
      $finish;
    end
  end endtask

  task handle_axi_bvalid; begin : handle_axi_bvalid
    integer i;
    integer memoryfile;

    if (verbose)
      $display("WR: ADDR=%08x DATA=%08x STRB=%04b", latched_waddr, latched_wdata, latched_wstrb);

    if (latched_waddr < 64*1024) begin
      if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
      if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
      if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
      if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
    end else if (latched_waddr == 32'h1000_0000) begin
      if (verbose) begin
        if (32 <= latched_wdata && latched_wdata < 128)
          $display("OUT: '%c'", latched_wdata[7:0]);
        else
          $display("OUT: %3d", latched_wdata);
      end else begin
        $write("%c", latched_wdata[7:0]);
`ifndef VERILATOR
        $fflush();
`endif
      end
    end else if (latched_waddr == 32'h2000_0000) begin
      if      (latched_wdata == 32'hacce5500)
        tests_passed = 1;
      else if (latched_wdata == 32'hacce5501)
        tests_passed = 0;
      else if (latched_wdata == 32'hacce5502)
        $dumpoff();
      else if (latched_wdata == 32'hacce5503)
        $dumpon();
      else if (latched_wdata == 32'hacce5504) begin
        memoryfile = $fopen("memory.hex", "w");
        for (i = 0; i < 64*1024/4; i=i+1)
          $fwrite(memoryfile, "%08x\n", memory[i]);
        $fclose(memoryfile);
      end
      else if (latched_wdata == 32'hacce5505)
        $readmemh("memory.hex", memory);
    end else begin
      $display("OUT-OF-BOUNDS MEMORY WRITE TO %08x", latched_waddr);
      $finish;
    end

    mem_axi_bvalid <= 1;
    latched_waddr_en = 0;
    latched_wdata_en = 0;
  end endtask

  always @(negedge clk) begin
    if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && async_axi_transaction[0]) handle_axi_arvalid;
    if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && async_axi_transaction[1]) handle_axi_awvalid;
    if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && async_axi_transaction[2]) handle_axi_wvalid;
    if (!mem_axi_rvalid && latched_raddr_en && async_axi_transaction[3]) handle_axi_rvalid;
    if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && async_axi_transaction[4]) handle_axi_bvalid;
  end

  always @(posedge clk) begin
    mem_axi_arready <= 0;
    mem_axi_awready <= 0;
    mem_axi_wready <= 0;

    fast_raddr <= 0;
    fast_waddr <= 0;
    fast_wdata <= 0;

    if (mem_axi_rvalid && mem_axi_rready) begin
      mem_axi_rvalid <= 0;
    end

    if (mem_axi_bvalid && mem_axi_bready) begin
      mem_axi_bvalid <= 0;
    end

    if (mem_axi_arvalid && mem_axi_arready && !fast_raddr) begin
      latched_raddr = mem_axi_araddr;
      latched_rinsn = mem_axi_arprot[2];
      latched_raddr_en = 1;
    end

    if (mem_axi_awvalid && mem_axi_awready && !fast_waddr) begin
      latched_waddr = mem_axi_awaddr;
      latched_waddr_en = 1;
    end

    if (mem_axi_wvalid && mem_axi_wready && !fast_wdata) begin
      latched_wdata = mem_axi_wdata;
      latched_wstrb = mem_axi_wstrb;
      latched_wdata_en = 1;
    end

    if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr) && !delay_axi_transaction[0]) handle_axi_arvalid;
    if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr) && !delay_axi_transaction[1]) handle_axi_awvalid;
    if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata) && !delay_axi_transaction[2]) handle_axi_wvalid;

    if (!mem_axi_rvalid && latched_raddr_en && !delay_axi_transaction[3]) handle_axi_rvalid;
    if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en && !delay_axi_transaction[4]) handle_axi_bvalid;
  end
endmodule
