module ucsbece154a_controller (
    input               clk, reset,
    input         [6:0] op_i, 
    input         [2:0] funct3_i,
    input               funct7_i,
    input               zero_i,
    output wire         PCWrite_o,
    output reg          MemWrite_o,    
    output reg          IRWrite_o,
    output reg          RegWrite_o,
    output reg    [1:0] ALUSrcA_o,
    output reg          AdrSrc_o,
    output reg    [1:0] ResultSrc_o,
    output reg    [1:0] ALUSrcB_o,
    output reg    [2:0] ALUControl_o,
    output reg    [2:0] ImmSrc_o
);

 `include "ucsbece154a_defines.vh"

 always @ * begin
   case (op_i)
    instr_lw_op:        ImmSrc_o = 3'b000;       
    instr_sw_op:        ImmSrc_o = 3'b001; 
    instr_Rtype_op:     ImmSrc_o = 3'bxxx;  
    instr_beq_op:       ImmSrc_o = 3'b010;  
    instr_ItypeALU_op:  ImmSrc_o = 3'b000; 
    instr_jal_op:       ImmSrc_o = 3'b011; 
    instr_lui_op:       ImmSrc_o = 3'b100;  
    instr_sleep_op:     ImmSrc_o = 3'b101;  // IoT SLEEP Instruction
    instr_wakeup_op:    ImmSrc_o = 3'b110;  // IoT WAKEUP Instruction
    default:            ImmSrc_o = 3'bxxx; 
   endcase
 end

 reg  [1:0] ALUOp;    // these are FFs updated each cycle 
 wire RtypeSub = funct7_i & op_i[5];

 always @ * begin
    case(ALUOp)
       ALUop_mem:                 ALUControl_o = ALUcontrol_add;
       ALUop_beq:                 ALUControl_o = ALUcontrol_sub;
       ALUop_other: 
         case(funct3_i) 
           instr_addsub_funct3: begin
                 if(RtypeSub)     ALUControl_o = ALUcontrol_sub;
                 else             ALUControl_o = ALUcontrol_add;  
           end
           instr_slt_funct3:      ALUControl_o = ALUcontrol_slt;  
           instr_or_funct3:       ALUControl_o = ALUcontrol_or;  
           instr_and_funct3:      ALUControl_o = ALUcontrol_and;  
           instr_mac_funct3:      ALUControl_o = ALUcontrol_mac;  // IoT MAC Instruction
           instr_andl_funct3:     ALUControl_o = ALUcontrol_andl; // IoT Low-power AND
           instr_orl_funct3:      ALUControl_o = ALUcontrol_orl;  // IoT Low-power OR
           default:               ALUControl_o = 3'bxxx;
         endcase
    default:                      ALUControl_o = 3'bxxx;
   endcase
 end

 reg Branch, PCUpdate, SleepMode;   // SleepMode for IoT low-power state

 assign PCWrite_o = Branch & zero_i | PCUpdate; 

 always @(posedge clk) begin
    if (reset) begin
        SleepMode <= 1'b0;  // Ensure processor starts in active mode
    end else if (op_i == instr_sleep_op) begin
        SleepMode <= 1'b1;  // Enter Sleep Mode
    end else if (op_i == instr_wakeup_op) begin
        SleepMode <= 1'b0;  // Exit Sleep Mode
    end
 end

 reg [3:0] state; // FSM FFs encoding the state 
 reg [3:0] state_next;

 always @ * begin
    if (reset) begin
        state_next = state_Fetch;  
    end else begin             
      case (state) 
        state_Fetch:           state_next = state_Decode;  
        state_Decode: begin
          case (op_i) 
            instr_lw_op:       state_next = state_MemAdr;  
            instr_sw_op:       state_next = state_MemAdr;  
            instr_Rtype_op:    state_next = state_ExecuteR;  
            instr_beq_op:      state_next = state_BEQ;  
            instr_ItypeALU_op: state_next = state_ExecuteI;  
            instr_lui_op:      state_next = state_LUI;  
            instr_jal_op:      state_next = state_JAL;  
            instr_sleep_op:    state_next = state_Sleep;  // IoT Sleep Mode
            instr_wakeup_op:   state_next = state_Fetch;  // Resume Fetch after wakeup
            default:           state_next = 4'bxxxx;
          endcase
        end
        state_Sleep:           state_next = state_Sleep;  // Maintain low-power state until wakeup
        state_MemAdr: begin 
          case (op_i)
            instr_lw_op:       state_next = state_MemRead;  
            instr_sw_op:       state_next = state_MemWrite;  
            default:           state_next = 4'bxxxx;
          endcase
        end
        state_MemRead:         state_next = state_MemWB;  
        state_MemWB:           state_next = state_Fetch;  
        state_MemWrite:        state_next = state_Fetch;  
        state_ExecuteR:        state_next = state_ALUWB;  
        state_ALUWB:           state_next = state_Fetch;  
        state_ExecuteI:        state_next = state_ALUWB;  
        state_JAL:             state_next = state_ALUWB;  
        state_BEQ:             state_next = state_Fetch;  
        state_LUI:             state_next = state_Fetch;     
        default:               state_next = 4'bxxxx;
     endcase
   end
 end

 always @(posedge clk) begin
    state <= state_next;
    PCUpdate <= PCUpdate_next;
    Branch <= Branch_next;
    MemWrite_o <= MemWrite_next;
    IRWrite_o <= IRWrite_next;
    RegWrite_o <= RegWrite_next;
    ALUSrcA_o <= ALUSrcA_next;
    ALUSrcB_o <= ALUSrcB_next;
    AdrSrc_o <= AdrSrc_next;
    ResultSrc_o <= ResultSrc_next;
    ALUOp <= ALUOp_next;
end

endmodule
