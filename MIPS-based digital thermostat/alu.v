
module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_op,
    output reg [31:0] result,
    output zero
);

    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_op)
            4'b0000: result = a + b;// add
            4'b0001: result = a - b;// sub
            4'b0010: result = a & b;// and
            4'b0011: result = a | b;// or
            4'b0101: result = ($signed(a) < $signed(b)) // slt  (signed)
                              ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end

endmodule
