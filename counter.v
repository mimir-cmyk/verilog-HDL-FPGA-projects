module counter (
    input wire clk,
    input wire rst,
    input wire en,//enable for controlling the system, when en=1-runs else freezes(holds value)
    output reg [2:0] count
);

always @(posedge clk) begin //synchronous, values only change at rising edge
    if (rst)
        count <= 3'b000; //reset overrides everything, non-blocking assignment,all updates happen at clock edge
    else if (en)
        count <= count + 1; // automatically wraps 0->7(mod8), only increment when enabled
end

endmodule
