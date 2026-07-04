`timescale 1ns/1ps

module traffic_light_controller_tb;

reg clk;
reg reset;
reg Sa;
reg Sb;
reg ped_req;
reg night_mode;
wire Ga,Ya,Ra;
wire Gb,Yb,Rb;
wire Pwalk;
wire Pstop;

traffic_light_controller DUT(
    .clk(clk),
    .reset(reset),
    .Sa(Sa),
    .Sb(Sb),
    .ped_req(ped_req),
    .night_mode(night_mode),
    .Ga(Ga),
    .Ya(Ya),
    .Ra(Ra),
    .Gb(Gb),
    .Yb(Yb),
    .Rb(Rb),
    .Pwalk(Pwalk),
    .Pstop(Pstop)
);

// clock

always #5 clk = ~clk;
	initial begin
    $monitor(
    "T=%0t  Ga=%b Ya=%b Ra=%b  Gb=%b Yb=%b Rb=%b  Pwalk=%b Pstop=%b",
    $time,
    Ga,Ya,Ra,
    Gb,Yb,Rb,
    Pwalk,Pstop);
		end

    initial begin

    clk= 0;
    reset= 1;
    Sa = 0;
    Sb= 0;
    ped_req= 0;
    night_mode = 0;
    #20;
    reset = 0;
    //scenario 1
    $display("SCENARIO 1");
    #50;
	 
    Sb = 1;
    #100;
    $display("SCENARIO 2");
    Sa= 0;
    Sb = 1;
    #100;

    $display("SCENARIO 3");
    ped_req = 1;
    #10;
    ped_req= 0;
    #120;

    $display("SCENARIO 4");
    night_mode= 1;
    #80;
    night_mode = 0;
    #60;

    $display("SCENARIO 5");
    reset = 1;
    #20;
    reset = 0;
    #50;
    $finish;

	end

	endmodule
