
module riscvsys_evmon (
  input wire i_instr_lui,
  input wire i_instr_auipc,
  input wire i_instr_jal,
  input wire i_instr_jalr,
  input wire i_instr_beq,
  input wire i_instr_bne,
  input wire i_instr_blt,
  input wire i_instr_bge,
  input wire i_instr_bltu,
  input wire i_instr_bgeu,
  input wire i_instr_lb,
  input wire i_instr_lh,
  input wire i_instr_lw,
  input wire i_instr_lbu,
  input wire i_instr_lhu,
  input wire i_instr_sb,
  input wire i_instr_sh,
  input wire i_instr_sw,
  input wire i_instr_addi,
  input wire i_instr_slti,
  input wire i_instr_sltiu,
  input wire i_instr_xori,
  input wire i_instr_ori,
  input wire i_instr_andi,
  input wire i_instr_slli,
  input wire i_instr_srli,
  input wire i_instr_srai,
  input wire i_instr_add,
  input wire i_instr_sub,
  input wire i_instr_sll,
  input wire i_instr_slt,
  input wire i_instr_sltu,
  input wire i_instr_xor,
  input wire i_instr_srl,
  input wire i_instr_sra,
  input wire i_instr_or,
  input wire i_instr_and,
  input wire i_instr_rdcycle,
  input wire i_instr_rdcycleh,
  input wire i_instr_rdinstr,
  input wire i_instr_rdinstrh,
  input wire i_instr_ecall_ebreak,
  input wire i_instr_getq,
  input wire i_instr_setq,
  input wire i_instr_retirq,
  input wire i_instr_maskirq,
  input wire i_instr_waitirq,
  input wire i_instr_timer,
  input wire i_instr_trap,
  input wire [31:0] i_pc,
  input wire [31:0] i_next_pc,
  input wire i_dbg_next
);
  wire ev_lui           = i_dbg_next && i_instr_lui;
  wire ev_auipc         = i_dbg_next && i_instr_auipc;
  wire ev_jal           = i_dbg_next && i_instr_jal;
  wire ev_jalr          = i_dbg_next && i_instr_jalr;
  wire ev_beq           = i_dbg_next && i_instr_beq;
  wire ev_bne           = i_dbg_next && i_instr_bne;
  wire ev_blt           = i_dbg_next && i_instr_blt;
  wire ev_bge           = i_dbg_next && i_instr_bge;
  wire ev_bltu          = i_dbg_next && i_instr_bltu;
  wire ev_bgeu          = i_dbg_next && i_instr_bgeu;
  wire ev_lb            = i_dbg_next && i_instr_lb;
  wire ev_lh            = i_dbg_next && i_instr_lh;
  wire ev_lw            = i_dbg_next && i_instr_lw;
  wire ev_lbu           = i_dbg_next && i_instr_lbu;
  wire ev_lhu           = i_dbg_next && i_instr_lhu;
  wire ev_sb            = i_dbg_next && i_instr_sb;
  wire ev_sh            = i_dbg_next && i_instr_sh;
  wire ev_sw            = i_dbg_next && i_instr_sw;
  wire ev_addi          = i_dbg_next && i_instr_addi;
  wire ev_slti          = i_dbg_next && i_instr_slti;
  wire ev_sltiu         = i_dbg_next && i_instr_sltiu;
  wire ev_xori          = i_dbg_next && i_instr_xori;
  wire ev_ori           = i_dbg_next && i_instr_ori;
  wire ev_andi          = i_dbg_next && i_instr_andi;
  wire ev_slli          = i_dbg_next && i_instr_slli;
  wire ev_srli          = i_dbg_next && i_instr_srli;
  wire ev_srai          = i_dbg_next && i_instr_srai;
  wire ev_add           = i_dbg_next && i_instr_add;
  wire ev_sub           = i_dbg_next && i_instr_sub;
  wire ev_sll           = i_dbg_next && i_instr_sll;
  wire ev_slt           = i_dbg_next && i_instr_slt;
  wire ev_sltu          = i_dbg_next && i_instr_sltu;
  wire ev_xor           = i_dbg_next && i_instr_xor;
  wire ev_srl           = i_dbg_next && i_instr_srl;
  wire ev_sra           = i_dbg_next && i_instr_sra;
  wire ev_or            = i_dbg_next && i_instr_or;
  wire ev_and           = i_dbg_next && i_instr_and;
  wire ev_rdcycle       = i_dbg_next && i_instr_rdcycle;
  wire ev_rdcycleh      = i_dbg_next && i_instr_rdcycleh;
  wire ev_rdinstr       = i_dbg_next && i_instr_rdinstr;
  wire ev_rdinstrh      = i_dbg_next && i_instr_rdinstrh;
  wire ev_ecall_ebreak  = i_dbg_next && i_instr_ecall_ebreak;
  wire ev_getq          = i_dbg_next && i_instr_getq;
  wire ev_setq          = i_dbg_next && i_instr_setq;
  wire ev_retirq        = i_dbg_next && i_instr_retirq;
  wire ev_maskirq       = i_dbg_next && i_instr_maskirq;
  wire ev_waitirq       = i_dbg_next && i_instr_waitirq;
  wire ev_timer         = i_dbg_next && i_instr_timer;
  wire ev_trap          = i_dbg_next && i_instr_trap;
endmodule
