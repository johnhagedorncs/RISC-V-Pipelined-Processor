// This code builds upon the multi-cycle processor design
// and adapts it into a pipelined processor design.

module pipelined_riscv_processor (
    input clk,
    input reset
);

// Include the definitions and constants
`include "ucsbece154a_defines.vh"

// Pipeline Registers (between stages)
reg [31:0] IF_ID_instr, IF_ID_pc;
reg [31:0] ID_EX_a, ID_EX_b, ID_EX_imm, ID_EX_pc;
reg [4:0]  ID_EX_rd;
reg [2:0]  ID_EX_ALUControl;
reg [1:0]  ID_EX_ResultSrc;
reg        ID_EX_ALUSrc, ID_EX_RegWrite, ID_EX_MemWrite;
reg [31:0] EX_MEM_aluresult, EX_MEM_b;
reg [4:0]  EX_MEM_rd;
reg [1:0]  EX_MEM_ResultSrc;
reg        EX_MEM_RegWrite, EX_MEM_MemWrite;
reg [31:0] MEM_WB_result;
reg [4:0]  MEM_WB_rd;
reg        MEM_WB_RegWrite;

// PC Register
reg [31:0] pc;
wire [31:0] pc_next;

// Instruction Memory
wire [31:0] instr;
ucsbece154a_instr_mem instr_mem (
    .addr(pc),
    .instr(instr)
);

// Control Signals
wire RegWrite, ALUSrc, MemWrite;
wire [2:0] ImmSrc, ALUControl;
wire [1:0] ResultSrc;
ucsbece154a_controller controller (
    .op_i(IF_ID_instr[6:0]),
    .funct3_i(IF_ID_instr[14:12]),
    .funct7b5_i(IF_ID_instr[30]),
    .zero_i(EX_MEM_aluresult == 0),
    .RegWrite_o(RegWrite),
    .ALUSrc_o(ALUSrc),
    .MemWrite_o(MemWrite),
    .ResultSrc_o(ResultSrc),
    .ALUControl_o(ALUControl),
    .ImmSrc_o(ImmSrc)
);

// Datapath
wire [31:0] imm_ext;
wire [31:0] rd1, rd2, alu_in2, aluresult;

ucsbece154a_rf regfile (
    .clk(clk),
    .we3_i(MEM_WB_RegWrite),
    .a1_i(IF_ID_instr[19:15]),
    .a2_i(IF_ID_instr[24:20]),
    .a3_i(MEM_WB_rd),
    .wd3_i(MEM_WB_result),
    .rd1_o(rd1),
    .rd2_o(rd2)
);

// Immediate Generator
assign imm_ext = (ImmSrc == imm_Itype) ? {{20{IF_ID_instr[31]}}, IF_ID_instr[31:20]} :
                 (ImmSrc == imm_Stype) ? {{20{IF_ID_instr[31]}}, IF_ID_instr[31:25], IF_ID_instr[11:7]} :
                 (ImmSrc == imm_Btype) ? {{19{IF_ID_instr[31]}}, IF_ID_instr[31], IF_ID_instr[7], IF_ID_instr[30:25], IF_ID_instr[11:8], 1'b0} :
                 (ImmSrc == imm_Jtype) ? {{11{IF_ID_instr[31]}}, IF_ID_instr[31], IF_ID_instr[19:12], IF_ID_instr[20], IF_ID_instr[30:21], 1'b0} :
                 (ImmSrc == imm_Utype) ? {IF_ID_instr[31:12], 12'b0} : 32'b0;

// ALU
assign alu_in2 = (ID_EX_ALUSrc) ? ID_EX_imm : ID_EX_b;
ucsbece154a_alu alu (
    .a_i(ID_EX_a),
    .b_i(alu_in2),
    .alucontrol_i(ID_EX_ALUControl),
    .result_o(aluresult)
);

// Data Memory
wire [31:0] readdata;
ucsbece154a_data_mem data_mem (
    .addr(EX_MEM_aluresult),
    .we(EX_MEM_MemWrite),
    .data(EX_MEM_b),
    .readdata(readdata)
);

// PC Update Logic
assign pc_next = pc + 4;

// Pipeline Logic (Sequential Updates)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc <= 0;
        IF_ID_instr <= 0; IF_ID_pc <= 0;
        ID_EX_a <= 0; ID_EX_b <= 0; ID_EX_imm <= 0; ID_EX_pc <= 0;
        ID_EX_rd <= 0; ID_EX_ALUControl <= 0; ID_EX_ResultSrc <= 0;
        ID_EX_ALUSrc <= 0; ID_EX_RegWrite <= 0; ID_EX_MemWrite <= 0;
        EX_MEM_aluresult <= 0; EX_MEM_b <= 0;
        EX_MEM_rd <= 0; EX_MEM_ResultSrc <= 0; EX_MEM_RegWrite <= 0; EX_MEM_MemWrite <= 0;
        MEM_WB_result <= 0; MEM_WB_rd <= 0; MEM_WB_RegWrite <= 0;
    end else begin
        // IF -> ID
        IF_ID_instr <= instr;
        IF_ID_pc <= pc;
        pc <= pc_next;

        // ID -> EX
        ID_EX_a <= rd1;
        ID_EX_b <= rd2;
        ID_EX_imm <= imm_ext;
        ID_EX_pc <= IF_ID_pc;
        ID_EX_rd <= IF_ID_instr[11:7];
        ID_EX_ALUControl <= ALUControl;
        ID_EX_ResultSrc <= ResultSrc;
        ID_EX_ALUSrc <= ALUSrc;
        ID_EX_RegWrite <= RegWrite;
        ID_EX_MemWrite <= MemWrite;

        // EX -> MEM
        EX_MEM_aluresult <= aluresult;
        EX_MEM_b <= ID_EX_b;
        EX_MEM_rd <= ID_EX_rd;
        EX_MEM_ResultSrc <= ID_EX_ResultSrc;
        EX_MEM_RegWrite <= ID_EX_RegWrite;
        EX_MEM_MemWrite <= ID_EX_MemWrite;

        // MEM -> WB
        MEM_WB_result <= (EX_MEM_ResultSrc == ResultSrc_data) ? readdata : EX_MEM_aluresult;
        MEM_WB_rd <= EX_MEM_rd;
        MEM_WB_RegWrite <= EX_MEM_RegWrite;
    end
end

endmodule
