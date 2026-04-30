module clock_divider (
    input clk,
    input rst,
    output reg slow_clk
);
//we have a 50MHz=50mln cycles/second and 1 clk cycle=20ns, too fast
reg [25:0] count;//26-bit counter, can count up to67M

always @(posedge clk) begin
    if (rst) begin
        count <= 0;
        slow_clk <= 0;
    end else begin
        count <= count + 1; //increments every clk cycle
        if (count == 50_000_000) begin//after this number is reached, 
            slow_clk <= ~slow_clk; //toggle ouput, led should change each second?
            count <= 0;//reset counter
        end
    end
end

endmodule
