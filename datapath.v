module datapath (
    input clk, reset,
    input [31:0] instr,
    input [31:0] read_data,
    output [31:0] pc,
    output [31:0] alu_result,
    output [31:0] write_data
);

    reg [31:0] regfile [31:0];
    reg [31:0] pc_reg;
    wire [31:0] src_a, src_b;
    wire [31:0] imm_ext;
    wire [2:0] alu_ctrl;
    wire [31:0] alu_out;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 0;
        end else begin
            pc_reg <= pc_reg + 4;
        end
    end

    assign pc = pc_reg;
    assign src_a = regfile[instr[19:15]];
    assign src_b = (instr[6:0] == 7'b0010011) ? imm_ext : regfile[instr[24:20]];
    assign write_data = regfile[instr[24:20]];
    
    alu alu_unit (
        .a(src_a),
        .b(src_b),
        .f(alu_ctrl),
        .result(alu_out)
    );

    always @(posedge clk) begin
        if (instr[6:0] == 7'b0110011) begin // R-type instruction
            regfile[instr[11:7]] <= alu_out;
        end else if (instr[6:0] == 7'b0010011) begin // I-type instruction
            regfile[instr[11:7]] <= alu_out;
        end else if (instr[6:0] == 7'b0000011) begin // Load instruction
            regfile[instr[11:7]] <= read_data;
        end
    end

    assign alu_result = alu_out;
endmodule
