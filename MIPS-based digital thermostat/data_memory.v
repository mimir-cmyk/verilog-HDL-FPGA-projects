
// Pure memory array, word-aligned addressing, 256 words.
// sw_temp (live temperature input) is handled in thermostat_top by intercepting address 0x00.
//
// Memory-mapped defaults (set in initial block):
//   word[1] = 0x04  desired_temp  = 25
//   word[2] = 0x08  critical_temp = 40
//   word[3] = 0x0C  fan_reg= 0
//   word[4] = 0x10  alarm_reg= 0
//   word[0] = 0x00  current_temp  
module data_memory(
    input  wire clk,
    input  wire mem_read,
    input  wire mem_write,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output wire [31:0] read_data,
    output wire fan,
    output wire alarm
);

    reg [31:0] memory [0:255];

    // initialise memory-mapped register defaults
    initial begin
        memory[0] = 32'd0;// 0x00 current_temp  (overridden in top)
        memory[1] = 32'd25;// 0x04 desired_temp
        memory[2] = 32'd40;// 0x08 critical_temp
        memory[3] = 32'd0;// 0x0C fan_reg
        memory[4] = 32'd0;// 0x10 alarm_reg
    end

    //combinational read 
    assign read_data = mem_read ? memory[address[31:2]] : 32'd0;

    //synchronous write
    always @(posedge clk) begin
        if (mem_write)
            memory[address[31:2]] <= write_data;
    end

    // Fan and alarm driven from their memory-mapped words
    assign fan = memory[3][0];   // word at 0x0C
    assign alarm = memory[4][0]; // word at 0x10

endmodule
