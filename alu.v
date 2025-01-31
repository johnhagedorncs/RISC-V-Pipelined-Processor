module alu(
    input [31:0] a, b,
    input [2:0] f,
    output reg [31:0] result,
    output reg zero,
    output reg overflow,
    output reg carry,
    output reg negative
);

    wire [32:0] temp;
    wire [31:0] sum;
    wire [31:0] slt_result;
    wire [31:0] b_op;

    assign b_op = (f == 3'b001) ? ~b : b;
    assign temp = {1'b0, a} + {1'b0, b_op} + (f == 3'b001 ? 1 : 0);
    assign sum = temp[31:0];

    assign slt_result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;

    always @(*) begin
        case (f)
            3'b000: result = sum;       // ADD
            3'b001: result = sum;       // SUB
            3'b010: result = a & b;     // AND
            3'b011: result = a | b;     // OR
            3'b100: result = slt_result;// SLT
            
            // ---- IoT Custom Instructions ----
            3'b101: result = a * b;     // MAC (Multiply-Accumulate)
            3'b110: result = a & ~b;    // BIT_ANDL (Low Power Bitwise AND)
            3'b111: result = a | ~b;    // BIT_ORL (Low Power Bitwise OR)

            // ---- Low-Power Control ----
            4'b1000: result = 32'b0;   // SLEEP Mode
            4'b1001: result = a;       // WAKEUP

            default: result = 32'b0;
        endcase
    end

    zero = (result == 32'b0);
    negative = result[31];

    if (f == 3'b000 || f == 3'b001) begin
        carry = temp[32];
    end else begin
        carry = 1'b0;
    end

    overflow = 1'b0;
    if (f == 3'b000) begin
        overflow = ((a[31] == b[31]) && (result[31] != a[31]));
    end else if (f == 3'b001) begin
        overflow = ((a[31] != b[31]) && (result[31] != a[31]));
    end
end
endmodule
