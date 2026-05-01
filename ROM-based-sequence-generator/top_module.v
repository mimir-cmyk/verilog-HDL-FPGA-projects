module top_module (
    input wire clk,
    input wire rst,
    input wire en,
    output wire [7:0] data_out
);
wire [2:0] addr;//output of counter, input to rom
wire [7:0] rom_data;//output of rom, input to register
//counter, on each rising edge, if rst=1 addr=0 elif en=1 addr++ else hold
counter c1 (
    .clk(clk),
    .rst(rst),
    .en(en),
    .count(addr)
);

//ROM, combinational,output updates immediately when addr changes
rom_3x8 r1 (
    .addr(addr),
    .data(rom_data)
);

//register,on rising edge: if rst=1 data_out=0,elif en=1 data_out = rom_data else → hold

reg8 r2 (
    .clk(clk),
    .rst(rst),
    .en(en),
    .d(rom_data),
    .q(data_out)
);

//addr changes at clock edge, rom_data changes immediately after, data_out updates on next clock edge
//this creates a 1-cycle delay

endmodule
