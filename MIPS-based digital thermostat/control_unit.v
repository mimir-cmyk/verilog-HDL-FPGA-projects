
// reg_dst: selects rd (R-type) vs rt (I-type) as write target
//slt: funct 6'b101010 handled in ALU op 4'b0101
// bne_flag : distinguishes beq vs bne for branch logic in top
module control_unit(
    input  wire [5:0] opcode,
    input  wire [5:0] funct,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg alu_src,
    output reg reg_dst,// 1 = rd (R-type), 0 = rt (I-type)
    output reg branch,
    output reg bne_flag,// 1 when instruction is bne
    output reg jump,
    output reg [3:0]  alu_op
);

    always @(*) begin
        // Safe defaults
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        alu_src= 1'b0;
        reg_dst = 1'b0;
        branch= 1'b0;
        bne_flag  = 1'b0;
        jump= 1'b0;
        alu_op= 4'b0000;

        case (opcode)
            // R-type  
            6'b000000: begin
                reg_write = 1'b1;
                reg_dst= 1'b1;// write to rd
                case (funct)
                    6'b100000: alu_op = 4'b0000;  // add
                    6'b100010: alu_op = 4'b0001;  // sub
                    6'b100100: alu_op = 4'b0010;  // and
                    6'b100101: alu_op = 4'b0011;  // or
                    6'b101010: alu_op = 4'b0101;  // slt
                    default:   alu_op = 4'b0000;
                endcase
            end

            // addi
            6'b001000: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_op= 4'b0000;       // add with immediate
            end

            // lw
            6'b100011: begin
                reg_write = 1'b1;
                mem_read  = 1'b1;
                alu_src= 1'b1;
                alu_op= 4'b0000;// base + offset
            end

            // sw
            
            6'b101011: begin
                mem_write = 1'b1;
                alu_src= 1'b1;
                alu_op= 4'b0000;       // base + offset
            end

            // beq
            6'b000100: begin
                branch= 1'b1;
                bne_flag = 1'b0;
                alu_op= 4'b0001;// a - b; branch if zero
            end

            
            // bne
            
            6'b000101: begin
                branch   = 1'b1;
                bne_flag = 1'b1;
                alu_op= 4'b0001;// a - b; branch if not zero
            end

            // j
            6'b000010: begin
                jump = 1'b1;
            end

        endcase
    end

endmodule
