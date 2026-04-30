`timescale 1ns/1ps
module tb_top;
reg clk;//reg-manually driven
reg rst;
reg en;
wire [7:0] data_out;//wire-driven by dut
top_module uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .data_out(data_out)
);
//clock generation,  toggles every 5ns
always #5 clk = ~clk;
initial begin
    clk = 0;
    rst = 1;
    en = 0;
	 $display("TIME\tclk\trst\ten\tdata_out");
    $monitor("%0t\t%b\t%b\t%b\t%b", $time, clk, rst, en, data_out);
	 //below register resets to 0. expected: addr = 000 rom_data = 00000001(from ROM[0]), data_out = 00000000
    //reset test
	  $display("\n--- RESET PHASE ---");
    #10 rst = 0;

    //enable counting, now system is running
	    $display("\n--- ENABLE ON ---");
    #10 en = 1;

    // Let it run
    #100;

    // Disable (hold test)
	   $display("\n--- ENABLE OFF ---");
    en = 0;
    #40;//expected waveform:flat lines (no changes) since entire system freezes
    //enable again
	  $display("\n--- ENABLE ON AGAIN ---");
    en = 1;
    #60;//counter should resume from last value and everything be displayed sequentially
 $display("\n--- SIMULATION END ---");
    $stop;
end

endmodule
