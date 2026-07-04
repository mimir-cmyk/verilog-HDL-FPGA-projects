
// r0 is hardwired to zero (write ignored)
// Synchronous write, asynchronous read
module register_file(
    input  wire  clk,
    input  wire reset,
    input  wire [4:0] rs,//read address 1
    input  wire [4:0] rt,//ra2
    input  wire [4:0]  rd,// write address (comes from top mux)
    input  wire [31:0] wd,// write data
    input  wire reg_write,//write enable
    output wire [31:0] rd1,
    output wire [31:0] rd2
);

    reg [31:0] regs [0:31];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;// WRITE: reset, fills all registers with 0
        end else if (reg_write && rd != 5'b0) begin
            regs[rd] <= wd;// WRITE: stores wd into register number rd
        end
    end

  
    // READ – combinational, with explicit $zero guard
    // independent of what is stored in regs[0])
    
    assign rd1 = (rs == 5'b0) ? 32'b0 : regs[rs];
    assign rd2 = (rt == 5'b0) ? 32'b0 : regs[rt];
endmodule
